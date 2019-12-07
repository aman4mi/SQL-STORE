SELECT temptbl.*, p.project_ref_code,
       b.organization_branch_id,
       b.office_name
FROM (
SELECT
    m.id AS master_id,
    m.module_info_id AS module_info_id,
    TO_CHAR(m.posting_date, 'dd/MM/yyyy') AS transaction_date,
    m.ref_transaction_no AS transaction_no,
    m.voucher_no AS voucher_no,
    CASE WHEN m.particulars IS NOT NULL THEN m.particulars ELSE m.description END AS particulars,
    d.control_branch_id,
    d.to_project_id,
    d.area_code,
    (SELECT SUM(debit) FROM acc_journal_details WHERE journal_master_id = m.id) AS amount

FROM acc_journal_master m
         INNER JOIN acc_journal_details d ON
        m.id = d.journal_master_id

WHERE
    m.voucher_type = 'Debit Voucher'
    AND m.app_organization_branch_id = 427
    AND d.project_id =  1
    AND d.debit > 0
    AND m.is_posted = TRUE
    AND TO_DATE(TO_CHAR(m.posting_date,'dd/MM/yyyy'),'dd/MM/yyyy')
    BETWEEN TO_DATE('07/10/2019','dd/MM/yyyy') AND TO_DATE('07/10/2019','dd/MM/yyyy')

 GROUP BY
     m.id,
    m.ref_transaction_no,
    m.voucher_no,
    d.control_branch_id,
    d.to_project_id,
    d.area_code

UNION ALL

SELECT
    m.id AS master_id,
    m.module_info_id AS module_info_id,
    TO_CHAR(m.posting_date, 'dd/MM/yyyy') AS transaction_date,
    m.ref_transaction_no AS transaction_no,
    m.voucher_no AS voucher_no,
    CASE WHEN m.particulars IS NOT NULL THEN m.particulars ELSE m.description END AS particulars,
    d.control_branch_id,
    d.to_project_id,
    d.area_code,
    (SELECT SUM(debit) FROM acc_journal_details WHERE journal_master_id = m.id) AS amount

FROM acc_journal_master m
         INNER JOIN acc_journal_details d ON
        m.id = d.journal_master_id

WHERE
        m.voucher_type = 'Credit Voucher'
  AND m.app_organization_branch_id = 427
  AND d.project_id =  1
  AND d.credit > 0
  AND m.is_posted = TRUE
  AND TO_DATE(TO_CHAR(m.posting_date,'dd/MM/yyyy'),'dd/MM/yyyy')
    BETWEEN TO_DATE('07/10/2019','dd/MM/yyyy') AND TO_DATE('07/10/2019','dd/MM/yyyy')

GROUP BY
    m.id,
    m.ref_transaction_no,
    m.voucher_no,
    d.control_branch_id,
    d.to_project_id,
    d.area_code

UNION ALL

SELECT
    m.id AS master_id,
    m.module_info_id AS module_info_id,
    TO_CHAR(m.posting_date, 'dd/MM/yyyy') AS transaction_date,
    m.ref_transaction_no AS transaction_no,
    m.voucher_no AS voucher_no,
    CASE WHEN m.particulars IS NOT NULL THEN m.particulars ELSE m.description END AS particulars,
    d.control_branch_id,
    d.to_project_id,
    d.area_code,
    (SELECT SUM(debit) FROM acc_journal_details WHERE journal_master_id = m.id) AS amount

FROM acc_journal_master m
         INNER JOIN acc_journal_details d ON
        m.id = d.journal_master_id

WHERE
        m.voucher_type = 'Journal Voucher'
  AND m.app_organization_branch_id = 427
  AND d.project_id =  1
  AND d.chart_of_accounts_id != 296
  AND m.is_posted = TRUE
  AND TO_DATE(TO_CHAR(m.posting_date,'dd/MM/yyyy'),'dd/MM/yyyy')
    BETWEEN TO_DATE('07/10/2019','dd/MM/yyyy') AND TO_DATE('07/10/2019','dd/MM/yyyy')

GROUP BY
    m.id,
    m.ref_transaction_no,
    m.voucher_no,
    d.control_branch_id,
    d.to_project_id,
    d.area_code
    )temptbl
                  LEFT JOIN acc_project_setup p ON
        p.id = temptbl.to_project_id
                  LEFT JOIN app_organization_branch b ON
        b.id = temptbl.control_branch_id