SELECT t_journal.voucher_no voucherno
     , t_journal.journal_no postedVoucherNo
     , to_char(t_journal.posting_date, 'DD/MM/YYYY') posted_date
     , t_journal.payment_type
     , to_char(t_journal.date, 'DD/MM/YYYY') voucherdate
     , aob.NAME branchname
     , org.NAME orgname
     , t_journal.particulars
     , t_journal.debit
     , t_journal.credit
     , t_journal.remarks description
     , CONCAT(COALESCE(prosup.project_ref_code, prosup.project_code), ' - ', prosup.name) projectName
     , coa.chart_of_account_code_auto "accountsCode"
     , coa.chart_of_account_name "headsOfAccounts"
     , CASE WHEN sl.NAME != ''
                THEN CONCAT(sl.code, '-', sl.NAME)
            ELSE ''
    END "subAccountsHead"
     , t_journal.ref_transaction_no
     , ap.full_name "maker"
FROM ( SELECT ajm.app_organization_branch_id
            , ajd.project_id
            , ajm.organization_id
            , ajd.area_code
            , ajd.chart_of_accounts_id
            , ajd.subsidiary_ledger_id
            , ajm.voucher_no voucher_no
            , ajm.journal_no journal_no
            , ajm.posting_date posting_date
            , ajm.payment_type payment_type
            , ajm.date date
            , ajm.particulars particulars
            , ajd.debit debit
            , ajd.credit credit
            , ajd.remarks remarks
            , ajm.ref_transaction_no ref_transaction_no
            , ajm.created_by_id created_by_id
       FROM acc_journal_master ajm
                INNER JOIN acc_journal_details ajd
                           ON ajm.id = ajd.journal_master_id
                               AND ajm.app_organization_branch_id = 391
                               AND ajm.voucher_no = 'DV00000188/19'
                INNER JOIN acc_project_chart_of_accounts_mapping apcoam
                           ON apcoam.project_setup_id = ajd.project_id
                               AND apcoam.chart_of_accounts_id = ajd.chart_of_accounts_id
       WHERE apcoam.overhead_coa_type != 'CAHO' OR apcoam.overhead_coa_type ISNULL OR apcoam.overhead_coa_type = ''

       UNION ALL

       SELECT ajm.app_organization_branch_id
            , ajd.project_id
            , ajm.organization_id
            , ajd.area_code
            , ajd.chart_of_accounts_id
            , ajd.subsidiary_ledger_id
            , MAX(ajm.voucher_no) voucher_no
            , MAX(ajm.journal_no) journal_no
            , MAX(ajm.posting_date) posting_date
            , MAX(ajm.payment_type) payment_type
            , MAX(ajm.date) date
            , MAX(ajm.particulars) particulars
            , SUM(ajd.debit) debit
            , SUM(ajd.credit) credit
            , MAX(ajd.remarks) remarks
            , MAX(ajm.ref_transaction_no) ref_transaction_no
            , MAX(ajm.created_by_id) created_by_id
       FROM acc_journal_master ajm
                INNER JOIN acc_journal_details ajd
                           ON ajm.id = ajd.journal_master_id
                               AND ajm.app_organization_branch_id = 391
                               AND ajm.voucher_no = 'DV00000188/19'
                INNER JOIN acc_project_chart_of_accounts_mapping apcoam
                           ON apcoam.project_setup_id = ajd.project_id
                               AND apcoam.chart_of_accounts_id = ajd.chart_of_accounts_id WHERE apcoam.overhead_coa_type = 'CAHO'

       GROUP BY ajm.app_organization_branch_id
              , ajd.project_id
              , ajm.organization_id
              , ajd.area_code
              , ajd.chart_of_accounts_id
              , ajd.subsidiary_ledger_id ) t_journal
         INNER JOIN app_organization_branch aob
                    ON aob.id = t_journal.app_organization_branch_id
         INNER JOIN organization org
                    ON org.id = t_journal.organization_id
         INNER JOIN acc_project_setup prosup
                    ON prosup.id = t_journal.project_id
         INNER JOIN chart_of_accounts coa
                    ON coa.id = t_journal.chart_of_accounts_id
         LEFT JOIN acc_subsidiary_ledger sl
                   ON sl.id = t_journal.subsidiary_ledger_id
         LEFT JOIN application_user ap
                   ON ap.id = t_journal.created_by_id

ORDER BY t_journal.debit DESC;