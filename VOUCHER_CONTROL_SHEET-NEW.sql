SELECT
    m.id AS master_id,
    d.project_id,
    m.module_info_id AS module_info_id,
    TO_CHAR(m.posting_date, 'dd/MM/yyyy') AS transaction_date,
    m.ref_transaction_no AS transaction_no,
    m.voucher_no AS voucher_no,
    CASE
        WHEN m.particulars IS NOT NULL THEN m.particulars
        ELSE m.description
        END AS particulars,
    (SELECT SUM(debit)
     FROM acc_journal_details
     WHERE journal_master_id = m.id) AS amount,
    CASE WHEN p.project_ref_code NOTNULL THEN p.project_ref_code ELSE 'k' END AS for_project_code,
    d.project_id AS project,
    CASE WHEN b.organization_branch_id NOTNULL THEN b.organization_branch_id ELSE 'kk' END AS for_area_code,
    CASE WHEN b.office_name NOTNULL THEN b.office_name ELSE 'kkk' END AS area_acc_desc

FROM acc_journal_master m
         INNER JOIN acc_journal_details d ON
        m.id = d.journal_master_id
         LEFT JOIN acc_project_setup p ON
        p.id = d.to_project_id
         LEFT JOIN app_organization_branch b ON
        b.id = d.control_branch_id
WHERE m.module_info_id in (4,5,9)
  AND m.app_organization_branch_id = 391
  AND d.project_id = 1
  AND m.is_posted = TRUE
  AND TO_DATE(TO_CHAR(m.posting_date,'dd/MM/yyyy'),'dd/MM/yyyy')
  BETWEEN TO_DATE('17/09/2019','dd/MM/yyyy') AND TO_DATE('17/09/2019','dd/MM/yyyy')
  AND p.project_ref_code ='060'

GROUP BY
    m.id,
    p.project_ref_code,
    b.organization_branch_id,
    b.office_name,
    d.project_id

ORDER BY
    TO_DATE(TO_CHAR(m.posting_date,'dd/MM/yyyy'),'dd/MM/yyyy'),
    m.created_on;

/*SELECT  id, areaacccode, areaaccdes, projectcode
FROM con_com_areaaccountcodeinfo
WHERE project_id = 1 AND office_id = 391*/












/*select m.voucher_no, m.ref_voucher_no, m.ref_transaction_no ref_transaction_no,* FROM acc_journal_master m
                  INNER JOIN acc_journal_details d ON
        m.id = d.journal_master_id
         where m.voucher_no ='DV00000017/19'  AND m.app_organization_branch_id = 591;*/