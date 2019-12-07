SELECT
  asset_group.group_name,
  category.category_name,
  SUM(details.unit_price)                                                            AS unit_price,
  (COALESCE(SUM(details.unit_price), 0) + COALESCE(SUM(addition_total.addition), 0)) AS addition_unit_price,
  COALESCE(SUM(addition_total.addition), 0)                                          AS addition,
  COALESCE(SUM(depreciation.accumulated_dep), 0)                                     AS dep_amount,
  (COALESCE(SUM(details.unit_price), 0) +
   (CASE WHEN COALESCE(SUM(addition_total.addition), 0) > 0
     THEN COALESCE(SUM(addition_total.addition), 0)
    ELSE 0 END) -
   (CASE WHEN COALESCE(SUM(depreciation.accumulated_dep), 0) > 0
     THEN COALESCE(SUM(depreciation.accumulated_dep), 0)
    ELSE 0 END))                                                                     AS written_down,
count(profile.asset_serial) as serial_count

FROM
  fa_asset_group AS asset_group
  INNER JOIN fa_asset_category AS category ON asset_group.id = category.asset_group_id
  INNER JOIN fa_asset_sub_category AS sub_category ON sub_category.asset_category_id = category.id
  INNER JOIN fa_asset AS asset ON asset.asset_sub_category_id = sub_category.id
  INNER JOIN fa_asset_registration_details AS details ON details.asset_id = asset.id
  INNER JOIN fa_asset_registration registration ON registration.id = details.asset_registration_id
  INNER JOIN fa_asset_profile AS profile ON profile.asset_registration_details_id = details.id
  LEFT JOIN (SELECT
               additions.fa_asset_profile_id,
               sum(additions.item_price) AS addition
             FROM (SELECT
                     inventory.status,
                     inventory.fa_asset_profile_id,
                     inventory.item_price
                   FROM fa_asset_addition_from_inventory inventory
                   WHERE inventory.status = 'APPROVED'
                   UNION ALL SELECT
                               vendor.status,
                               vendor.fa_asset_profile_id,
                               vendor.amount
                             FROM fa_asset_addition_from_vendor vendor
                             WHERE vendor.status = 'APPROVED') additions
             GROUP BY additions.fa_asset_profile_id) addition_total
    ON addition_total.fa_asset_profile_id = profile.id
  LEFT JOIN fa_asset_depreciation AS depreciation
    ON depreciation.asset_profile_id = (SELECT asset_profile_id
                                        FROM fa_asset_depreciation dep
                                        WHERE profile.id = dep.asset_profile_id
                                        ORDER BY dep.id DESC
                                        LIMIT 1)

WHERE profile.current_branch_id = $P{organizationBranch}

AND
CASE WHEN $P{office} is not null THEN profile.current_branch_id = $P{office}
WHEN $P{office} IS NULL THEN 1=1
END

AND
CASE WHEN $P{project} IS NOT NULL THEN profile.current_project_id = $P{project}
WHEN $P{project} IS NULL THEN 1=1
END

AND
CASE WHEN $P{sourceOfFund} IS NOT NULL THEN registration.source_of_fund_id = $P{sourceOfFund}
WHEN $P{sourceOfFund} IS NULL THEN 1=1
END

AND
CASE WHEN $P{group} IS NOT NULL THEN asset_group.id = $P{group}
WHEN $P{group} IS NULL THEN 1=1
END

AND
CASE WHEN ($P{toDate} IS NULL OR $P{fromDate} IS NULL )  THEN  1=1
ELSE (DATE(registration.approval_date) BETWEEN DATE($P{fromDate}) AND DATE($P{toDate}) )END

GROUP BY asset_group.group_name,
category.category_name,asset_group.id

ORDER BY asset_group.id ASC