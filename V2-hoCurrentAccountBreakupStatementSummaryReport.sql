/*

SELECT
    rc.recon_code AS recon_code,
    rc.recon_name AS recon_name,
    br.office_name AS area_name,
    d.area_code AS area_ac,
    sum(d.debit) AS debit,
    sum(d.credit) AS credit,
    p.project_ref_code project_code
FROM acc_journal_master m
         INNER JOIN acc_journal_details d ON  m.id = d.journal_master_id
    inner JOIN acc_recon_code rc ON
    d.recon_code_id = rc.id
    LEFT JOIN app_organization_branch br ON
    br.id = d.control_branch_id
    LEFT JOIN acc_project_setup p ON
    p.id = d.to_project_id
WHERE
  m.app_organization_branch_id = 391
  AND d.app_organization_branch_id = 391
  AND d.project_id =  2
  AND d.chart_of_accounts_id = 296
  AND m.is_posted = TRUE
  AND TO_DATE(TO_CHAR(m.posting_date,'dd/MM/yyyy'),'dd/MM/yyyy')
  BETWEEN TO_DATE('17/09/2019','dd/MM/yyyy') AND TO_DATE('17/09/2019','dd/MM/yyyy')
  AND rc.recon_code IN (11, 38)
GROUP BY p.project_ref_code,
         rc.recon_code,
         rc.recon_name,
         br.office_name,
         m.voucher_no,
         d.area_code;

  */



SELECT

    recon_code,
    recon_name,
    area_name,
    area_ac,
    project_code,
    CASE
        WHEN debit - credit >= 0 THEN debit - credit
        ELSE 0
        END AS debit,
    CASE
        WHEN debit - credit < 0 THEN credit - debit
        ELSE 0
        END AS credit

FROM (
         (SELECT
              rc.recon_code AS recon_code,
              rc.recon_name AS recon_name,
              br.office_name AS area_name,
              d.area_code AS area_ac,
              SUM(d.debit) AS debit,
              SUM(d.credit) AS credit ,
              p.project_ref_code project_code
          FROM acc_journal_master m
                   INNER JOIN acc_journal_details d ON
                      m.id = d.journal_master_id
                  AND m.app_organization_branch_id = 391
              AND d.app_organization_branch_id = 391
              AND d.project_id =  2
              AND d.chart_of_accounts_id =  296
              AND m.is_posted = TRUE
              AND TO_DATE(TO_CHAR(m.posting_date,'dd/MM/yyyy'),'dd/MM/yyyy')
              BETWEEN TO_DATE('17/09/2019','dd/MM/yyyy') AND TO_DATE('17/09/2019','dd/MM/yyyy')
              INNER JOIN acc_recon_code rc ON
              d.recon_code_id = rc.id AND rc.recon_code NOT IN (11,38, 16,21)

              LEFT JOIN app_organization_branch br ON
              br.id = d.control_branch_id
              LEFT JOIN acc_project_setup p ON
              p.id = d.to_project_id
          GROUP BY
              rc.recon_code,
              rc.recon_name,
              br.office_name,
              d.area_code,
              p.project_ref_code )

         UNION ALL

         (SELECT
              rc.recon_code AS recon_code,
              rc.recon_name AS recon_name,
              br.office_name AS area_name,
              d.area_code AS area_ac,
              SUM(d.debit) AS debit,
              SUM(d.credit) AS credit,
              p.project_ref_code project_code
          FROM acc_journal_master m
                   INNER JOIN acc_journal_details d ON
                  m.id = d.journal_master_id
                   INNER JOIN acc_recon_code rc ON d.recon_code_id = rc.id
                   LEFT JOIN app_organization_branch br ON
                  br.id = d.control_branch_id
                   LEFT JOIN acc_project_setup p ON
                  p.id = d.to_project_id
          WHERE
                  m.app_organization_branch_id = 391
            AND d.app_organization_branch_id = 391
            AND d.project_id =  2
            AND d.chart_of_accounts_id = 296
            AND m.is_posted = TRUE
            AND TO_DATE(TO_CHAR(m.posting_date,'dd/MM/yyyy'),'dd/MM/yyyy')
              BETWEEN TO_DATE('17/09/2019','dd/MM/yyyy') AND TO_DATE('17/09/2019','dd/MM/yyyy')
            AND rc.recon_code IN (11, 38)
          GROUP BY p.project_ref_code,
                   rc.recon_code,
                   rc.recon_name,
                   br.office_name,
                   m.voucher_no,
                   d.area_code)

             UNION ALL

         (SELECT
              rc.recon_code AS recon_code,
              CASE
                  WHEN rc.recon_code = 16 THEN 'Expenditure Received/Transfer'
                  WHEN rc.recon_code = 21 THEN 'Loan and Sav Received/Transfer'
                  ELSE 'recon name not found'
                  END AS recon_name,
              br.office_name AS area_name,
              d.area_code AS area_ac,
              SUM(d.debit) AS debit,
              SUM(d.credit) AS credit ,
              p.project_ref_code project_code
          FROM acc_journal_master m
                   INNER JOIN acc_journal_details d ON
                      m.id = d.journal_master_id
                  AND m.app_organization_branch_id = 391
              AND d.app_organization_branch_id =391
              AND d.project_id = 2
              AND d.chart_of_accounts_id =  296
              AND m.is_posted = TRUE
              AND TO_DATE(TO_CHAR(m.posting_date,'dd/MM/yyyy'),'dd/MM/yyyy')
              BETWEEN TO_DATE('17/09/2019','dd/MM/yyyy') AND TO_DATE('17/09/2019','dd/MM/yyyy')
              INNER JOIN acc_recon_code rc ON
              d.recon_code_id = rc.id
              AND rc.recon_code IN (16,21)
              LEFT JOIN app_organization_branch br ON
              br.id = d.control_branch_id
              LEFT JOIN acc_project_setup p ON
              p.id = d.to_project_id
          GROUP BY
              rc.recon_code,
              br.office_name,
              d.area_code,
              p.project_ref_code)

         )
         ORDER BY
             recon_code, area_ac


