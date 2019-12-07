SELECT
  m.id AS master_id,
m.module_info_id AS module_info_id,
  TO_CHAR(m.posting_date, 'dd/MM/yyyy') AS transaction_date,
  m.ref_transaction_no AS transaction_no,
  m.voucher_no AS voucher_no,
  CASE
    WHEN m.particulars IS NOT NULL THEN m.particulars
    ELSE m.description
  END AS particulars,
  (SELECT
    SUM(debit)
  FROM acc_journal_details
  WHERE
    journal_master_id = m.id) AS amount,
  p.project_ref_code AS for_project_code,
  b.organization_branch_id AS for_area_code,
  b.office_name AS area_acc_desc
FROM acc_journal_master m
  INNER JOIN acc_journal_details d ON
    m.id = d.journal_master_id
  LEFT JOIN acc_project_setup p ON
    p.id = d.to_project_id
  LEFT JOIN app_organization_branch b ON
    b.id = d.control_branch_id
WHERE
  $X{IN,m.module_info_id,moduleIds}
  AND m.app_organization_branch_id = $P{organizationBranch}
  AND d.project_id =  $P{project_id}
  AND m.is_posted = TRUE
  AND TO_DATE(TO_CHAR(m.posting_date,'dd/MM/yyyy'),'dd/MM/yyyy')
  BETWEEN TO_DATE($P{fromDate},'dd/MM/yyyy') AND TO_DATE($P{toDate},'dd/MM/yyyy')
GROUP BY
  m.id,
  p.project_ref_code,
  b.organization_branch_id,
  b.office_name
ORDER BY
  TO_DATE(TO_CHAR(m.posting_date,'dd/MM/yyyy'),'dd/MM/yyyy'),
  m.created_on