\set ON_ERROR_STOP on

\echo 'START Phase 9.2 - Create Snapshot Run Function'

CREATE SCHEMA IF NOT EXISTS snapshot;

DROP FUNCTION IF EXISTS snapshot.run_bc_daily_snapshot(date, text, text);

CREATE OR REPLACE FUNCTION snapshot.run_bc_daily_snapshot(
    p_snapshot_date date,
    p_snapshot_cutoff_label text,
    p_source_type text
)
RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
    v_snapshot_run_id bigint;
    v_snapshot_timestamp timestamp without time zone;
    v_total_clean_bc_rows integer;
    v_total_snapshot_rows integer;
    v_total_issue_history_rows integer;
BEGIN
    v_snapshot_timestamp := CURRENT_TIMESTAMP;

    SELECT COUNT(*)
    INTO v_total_clean_bc_rows
    FROM clean.clean_bc;

    INSERT INTO snapshot.snapshot_run_log (
        snapshot_date,
        snapshot_timestamp,
        snapshot_cutoff_label,
        source_type,
        source_file_name,
        total_clean_bc_rows,
        snapshot_status,
        validation_result,
        risk_level,
        notes,
        created_at
    )
    SELECT
        p_snapshot_date,
        v_snapshot_timestamp,
        p_snapshot_cutoff_label,
        p_source_type,
        STRING_AGG(DISTINCT source_file_name, ', ' ORDER BY source_file_name),
        v_total_clean_bc_rows,
        'RUNNING',
        'NEEDS REVIEW',
        'MEDIUM',
        'Snapshot run started from clean.clean_bc',
        CURRENT_TIMESTAMP
    FROM clean.clean_bc;

    SELECT currval(pg_get_serial_sequence('snapshot.snapshot_run_log', 'snapshot_run_id'))
    INTO v_snapshot_run_id;

    UPDATE snapshot.bc_daily_status_snapshot
    SET is_latest_snapshot_of_day = false
    WHERE snapshot_date = p_snapshot_date;

    INSERT INTO snapshot.bc_daily_status_snapshot (
        snapshot_run_id,
        snapshot_date,
        snapshot_timestamp,
        snapshot_cutoff_label,
        is_latest_snapshot_of_day,
        source_row_no,
        bc_number,
        event_name,
        customer_name,
        pic_internal_code,
        event_category,
        event_status,
        billing_status,
        invoice_number,
        event_start_date,
        event_end_date,
        recording_period_date,
        latest_invoice_date,
        snapshot_year_month,
        event_end_year_month,
        invoice_year_month,
        event_value_amount,
        rab_budget_amount,
        total_invoiced_amount,
        umk_released_amount,
        umk_issued_amount,
        handling_fee,
        invoice_completion_ratio,
        invoice_completion_bucket,
        bc_closing_status,
        unbilled_aging_days,
        aging_bucket,
        closing_duration_days,
        closing_duration_bucket,
        is_open_unbilled,
        is_closed_fully_invoiced,
        is_reported_excluded,
        is_partial_invoice,
        is_over_invoiced_review,
        is_unclassified_pic,
        open_rab_exposure_amount,
        invoice_gap_amount,
        remaining_invoice_amount,
        high_risk_flag,
        urgent_flag,
        risk_level,
        needs_manual_review_flag,
        data_quality_flag,
        data_quality_issue_count,
        billing_remarks,
        document_status_or_missing_notes,
        ar_deadline_or_merge_invoice_notes,
        pic_user_contact,
        po_status_or_po_number,
        umk_status,
        issue_source_text,
        detected_issue_category,
        detected_blocker,
        responsibility_type,
        issue_confidence_level,
        classification_method,
        source_file_name,
        source_row_hash,
        record_hash,
        loaded_at,
        cleaned_at,
        created_at
    )
    WITH base AS (
        SELECT
            cb.*,
            CASE
                WHEN cb.rab_budget_amount IS NULL OR cb.rab_budget_amount = 0 THEN NULL
                ELSE cb.total_invoiced_amount / NULLIF(cb.rab_budget_amount, 0)
            END AS calc_invoice_completion_ratio
        FROM clean.clean_bc cb
    ),
    derived AS (
        SELECT
            b.*,

            CASE
                WHEN b.calc_invoice_completion_ratio IS NULL THEN 'NOT_INVOICED'
                WHEN b.calc_invoice_completion_ratio >= 1.05 THEN 'OVER_INVOICED_REVIEW'
                WHEN b.calc_invoice_completion_ratio >= 0.98 THEN 'FULLY_INVOICED'
                WHEN b.calc_invoice_completion_ratio >= 0.90 THEN 'SUBSTANTIALLY_INVOICED'
                WHEN b.calc_invoice_completion_ratio > 0 THEN 'PARTIALLY_INVOICED'
                ELSE 'NOT_INVOICED'
            END AS calc_invoice_completion_bucket,

            CASE
                WHEN b.billing_status = 'REPORTED' THEN true
                ELSE false
            END AS calc_is_reported_excluded,

            CASE
                WHEN b.billing_status = 'BILLED'
                 AND b.invoice_number IS NOT NULL
                 AND b.calc_invoice_completion_ratio >= 0.98
                THEN true
                ELSE false
            END AS calc_is_closed_fully_invoiced,

            CASE
                WHEN b.calc_invoice_completion_ratio > 0
                 AND b.calc_invoice_completion_ratio < 0.98
                THEN true
                ELSE false
            END AS calc_is_partial_invoice,

            CASE
                WHEN b.calc_invoice_completion_ratio > 1.05 THEN true
                ELSE false
            END AS calc_is_over_invoiced_review,

            CASE
                WHEN b.pic_internal_code = 'UNCLASSIFIED' THEN true
                ELSE false
            END AS calc_is_unclassified_pic,

            CASE
                WHEN b.unbilled_aging_days <= 30 THEN 'NORMAL'
                WHEN b.unbilled_aging_days BETWEEN 31 AND 60 THEN 'WATCH LIST'
                WHEN b.unbilled_aging_days BETWEEN 61 AND 90 THEN 'NEED FOLLOW-UP ACTION'
                WHEN b.unbilled_aging_days > 90 THEN 'HIGH RISK'
                ELSE 'UNKNOWN'
            END AS calc_aging_bucket,

            CASE
                WHEN b.closing_duration_days <= 30 THEN 'GOOD'
                WHEN b.closing_duration_days BETWEEN 31 AND 45 THEN 'MONITOR'
                WHEN b.closing_duration_days BETWEEN 46 AND 60 THEN 'WATCH LIST'
                WHEN b.closing_duration_days BETWEEN 61 AND 90 THEN 'DELAYED'
                WHEN b.closing_duration_days > 90 THEN 'CRITICAL DELAY'
                ELSE 'UNKNOWN'
            END AS calc_closing_duration_bucket
        FROM base b
    ),
    final_calc AS (
        SELECT
            d.*,

            CASE
                WHEN d.calc_is_reported_excluded = true THEN false
                WHEN d.calc_is_closed_fully_invoiced = true THEN false
                WHEN d.billing_status = 'UNBILL' THEN true
                WHEN COALESCE(d.calc_invoice_completion_ratio, 0) < 0.98 THEN true
                ELSE false
            END AS calc_is_open_unbilled,

            CASE
                WHEN d.calc_is_reported_excluded = true THEN 'REPORTED_EXCLUDED'
                WHEN d.calc_is_closed_fully_invoiced = true THEN 'CLOSED_FULLY_INVOICED'
                WHEN d.calc_is_partial_invoice = true THEN 'PARTIAL_INVOICE'
                ELSE 'OPEN_UNBILLED'
            END AS calc_bc_closing_status,

            CASE
                WHEN d.calc_is_reported_excluded = true THEN 0
                WHEN d.calc_is_closed_fully_invoiced = true THEN 0
                ELSE COALESCE(d.rab_budget_amount, 0)
            END AS calc_open_rab_exposure_amount,

            GREATEST(COALESCE(d.rab_budget_amount, 0) - COALESCE(d.total_invoiced_amount, 0), 0) AS calc_invoice_gap_amount,

            CASE
                WHEN d.calc_is_reported_excluded = true THEN 0
                WHEN d.calc_is_closed_fully_invoiced = true THEN 0
                ELSE GREATEST(COALESCE(d.rab_budget_amount, 0) - COALESCE(d.total_invoiced_amount, 0), 0)
            END AS calc_remaining_invoice_amount,

            CASE
                WHEN d.unbilled_aging_days > 60
                 AND COALESCE(d.rab_budget_amount, 0) >= 3000000000
                 AND d.calc_is_reported_excluded = false
                THEN true
                ELSE false
            END AS calc_high_risk_flag,

            CASE
                WHEN d.unbilled_aging_days > 60
                 AND COALESCE(d.rab_budget_amount, 0) >= 3000000000
                 AND d.calc_is_reported_excluded = false
                THEN 'HIGH'
                WHEN d.unbilled_aging_days > 90
                 AND d.calc_is_reported_excluded = false
                THEN 'HIGH'
                WHEN d.unbilled_aging_days BETWEEN 61 AND 90
                 AND d.calc_is_reported_excluded = false
                THEN 'MEDIUM'
                ELSE 'LOW'
            END AS calc_risk_level,

            CASE
                WHEN d.unbilled_aging_days > 60
                 AND COALESCE(d.rab_budget_amount, 0) >= 3000000000
                 AND d.calc_is_reported_excluded = false
                THEN true
                ELSE false
            END AS calc_urgent_flag,

            CONCAT_WS(
                ' | ',
                d.billing_remarks,
                d.document_status_or_missing_notes,
                d.po_status_or_po_number,
                d.umk_status
            ) AS calc_issue_source_text
        FROM derived d
    )
    SELECT
        v_snapshot_run_id,
        p_snapshot_date,
        v_snapshot_timestamp,
        p_snapshot_cutoff_label,
        true AS is_latest_snapshot_of_day,
        f.source_row_no,
        f.bc_number,
        f.event_name,
        f.customer_name,
        f.pic_internal_code,
        f.event_category,
        f.event_status,
        f.billing_status,
        f.invoice_number,
        f.event_start_date,
        f.event_end_date,
        f.recording_period_date,
        f.latest_invoice_date,
        TO_CHAR(p_snapshot_date, 'YYYY-MM') AS snapshot_year_month,
        TO_CHAR(f.event_end_date, 'YYYY-MM') AS event_end_year_month,
        TO_CHAR(f.latest_invoice_date, 'YYYY-MM') AS invoice_year_month,
        f.event_value_amount,
        f.rab_budget_amount,
        f.total_invoiced_amount,
        f.umk_released_amount,
        f.umk_issued_amount,
        f.handling_fee,
        f.calc_invoice_completion_ratio,
        f.calc_invoice_completion_bucket,
        f.calc_bc_closing_status,
        f.unbilled_aging_days,
        f.calc_aging_bucket,
        f.closing_duration_days,
        f.calc_closing_duration_bucket,
        f.calc_is_open_unbilled,
        f.calc_is_closed_fully_invoiced,
        f.calc_is_reported_excluded,
        f.calc_is_partial_invoice,
        f.calc_is_over_invoiced_review,
        f.calc_is_unclassified_pic,
        f.calc_open_rab_exposure_amount,
        f.calc_invoice_gap_amount,
        f.calc_remaining_invoice_amount,
        f.calc_high_risk_flag,
        f.calc_urgent_flag,
        f.calc_risk_level,
        CASE
            WHEN f.calc_is_unclassified_pic = true THEN true
            WHEN f.calc_is_over_invoiced_review = true THEN true
            WHEN f.billing_status IS NULL THEN true
            WHEN f.bc_number IS NULL THEN true
            ELSE false
        END AS needs_manual_review_flag,
        CASE
            WHEN f.bc_number IS NULL THEN 'ISSUE'
            WHEN f.billing_status IS NULL THEN 'ISSUE'
            WHEN f.calc_is_unclassified_pic = true THEN 'REVIEW'
            WHEN f.calc_is_over_invoiced_review = true THEN 'REVIEW'
            ELSE 'PASS'
        END AS data_quality_flag,
        (
            CASE WHEN f.bc_number IS NULL THEN 1 ELSE 0 END
          + CASE WHEN f.billing_status IS NULL THEN 1 ELSE 0 END
          + CASE WHEN f.calc_is_unclassified_pic = true THEN 1 ELSE 0 END
          + CASE WHEN f.calc_is_over_invoiced_review = true THEN 1 ELSE 0 END
        ) AS data_quality_issue_count,
        f.billing_remarks,
        f.document_status_or_missing_notes,
        f.ar_deadline_or_merge_invoice_notes,
        f.pic_user_contact,
        f.po_status_or_po_number,
        f.umk_status,
        f.calc_issue_source_text,
        CASE
            WHEN f.calc_is_reported_excluded = true THEN 'REPORTED_EXCLUDED'
            WHEN f.calc_is_closed_fully_invoiced = true THEN 'FULLY_INVOICED'
            ELSE 'UNKNOWN_ISSUE'
        END AS detected_issue_category,
        CASE
            WHEN f.calc_is_reported_excluded = true THEN 'REPORTED_EXCLUDED'
            WHEN f.calc_is_closed_fully_invoiced = true THEN 'NONE'
            ELSE 'UNKNOWN_BLOCKER'
        END AS detected_blocker,
        CASE
            WHEN f.calc_is_reported_excluded = true THEN 'EXCLUDED'
            ELSE 'UNKNOWN'
        END AS responsibility_type,
        CASE
            WHEN f.calc_is_reported_excluded = true THEN 'HIGH'
            WHEN f.calc_is_closed_fully_invoiced = true THEN 'HIGH'
            ELSE 'LOW'
        END AS issue_confidence_level,
        'SQL_RULE_BASELINE_V1' AS classification_method,
        f.source_file_name,
        md5(CONCAT_WS('|', f.source_file_name, f.source_row_no::text, f.bc_number)) AS source_row_hash,
        md5(CONCAT_WS('|',
            p_snapshot_date::text,
            f.bc_number,
            f.pic_internal_code,
            f.billing_status,
            COALESCE(f.rab_budget_amount, 0)::text,
            COALESCE(f.total_invoiced_amount, 0)::text,
            COALESCE(f.unbilled_aging_days, 0)::text
        )) AS record_hash,
        f.loaded_at,
        f.cleaned_at,
        CURRENT_TIMESTAMP
    FROM final_calc f;

    GET DIAGNOSTICS v_total_snapshot_rows = ROW_COUNT;

    INSERT INTO snapshot.bc_daily_issue_history (
        snapshot_run_id,
        snapshot_date,
        snapshot_timestamp,
        bc_number,
        pic_internal_code,
        billing_status,
        event_status,
        invoice_completion_bucket,
        bc_closing_status,
        raw_remarks,
        raw_missing_document_notes,
        raw_po_status,
        raw_umk_status,
        issue_source_text,
        detected_issue_category,
        detected_blocker,
        responsibility_type,
        issue_confidence_level,
        classification_method,
        needs_manual_review_flag,
        created_at
    )
    SELECT
        snapshot_run_id,
        snapshot_date,
        snapshot_timestamp,
        bc_number,
        pic_internal_code,
        billing_status,
        event_status,
        invoice_completion_bucket,
        bc_closing_status,
        billing_remarks,
        document_status_or_missing_notes,
        po_status_or_po_number,
        umk_status,
        issue_source_text,
        detected_issue_category,
        detected_blocker,
        responsibility_type,
        issue_confidence_level,
        classification_method,
        needs_manual_review_flag,
        CURRENT_TIMESTAMP
    FROM snapshot.bc_daily_status_snapshot
    WHERE snapshot_run_id = v_snapshot_run_id;

    GET DIAGNOSTICS v_total_issue_history_rows = ROW_COUNT;

    UPDATE snapshot.snapshot_run_log
    SET
        total_snapshot_rows = v_total_snapshot_rows,
        total_issue_history_rows = v_total_issue_history_rows,
        snapshot_status = 'COMPLETED',
        validation_result = CASE
            WHEN v_total_clean_bc_rows = v_total_snapshot_rows
             AND v_total_snapshot_rows = v_total_issue_history_rows
            THEN 'PASS'
            ELSE 'NEEDS REVIEW'
        END,
        risk_level = CASE
            WHEN v_total_clean_bc_rows = v_total_snapshot_rows
             AND v_total_snapshot_rows = v_total_issue_history_rows
            THEN 'LOW'
            ELSE 'MEDIUM'
        END,
        notes = 'Snapshot completed by snapshot.run_bc_daily_snapshot',
        completed_at = CURRENT_TIMESTAMP
    WHERE snapshot_run_id = v_snapshot_run_id;

    RETURN v_snapshot_run_id;
END;
$$;

\echo 'Running Phase 9.2 function validation...'

SELECT
    'snapshot.run_bc_daily_snapshot(date,text,text)' AS function_name,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM pg_proc p
            JOIN pg_namespace n
                ON p.pronamespace = n.oid
            WHERE n.nspname = 'snapshot'
              AND p.proname = 'run_bc_daily_snapshot'
              AND pg_get_function_identity_arguments(p.oid) = 'p_snapshot_date date, p_snapshot_cutoff_label text, p_source_type text'
        )
        THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result;

\echo 'END Phase 9.2 - Create Snapshot Run Function'
