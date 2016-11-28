-- Update the UNKNOWN_TOC_REG column for cu_ids that may have been impacted
-- by the managed group migration

spool cmd_d_unknown_upd2
set feedback on
set echo off

SELECT /*+ parallel 8 */
       COUNT( *)
FROM  cmd_d_customers
WHERE unknown_toc_reg = 'Y';

-- customers that have a registration

-- 

--UPDATE cmd_d_customers c
--SET   unknown_toc_reg               = 'Y'
--WHERE c.cu_id IN (SELECT /*+ parallel 8 */
--                         r.cu_id
--                  FROM  cmd_d_hist_reg r
--                  WHERE (r.reg_date < TO_DATE('16-sep-2008'
--                                             ,'dd-mon-yyyy'
--                                             )
--                  AND    r.retailer_code = 'VT'
--                  AND    r.first_env_id = 2
--                  AND    r.first_env_id = r.last_env_id)
--                  OR    (r.reg_date < TO_DATE('01-mar-2011'
--                                             ,'dd-mon-yyyy'
--                                             )
--                  AND    r.retailer_code = 'SWT'
--                  AND    r.first_env_id = 8
--                  AND    r.first_env_id = r.last_env_id));

commit;

SELECT /*+ parallel 8 */
       COUNT( *)
FROM  cmd_d_customers
WHERE unknown_toc_reg = 'Y';

-- customers without a registration

-- 4404051 rows

UPDATE cmd_d_customers c
SET   unknown_toc_reg               = 'Y'
WHERE c.cu_id IN (SELECT /*+ parallel 8 */
                         c2.cu_id
                  FROM  cmd_d_customers c2
                       ,tcs_customers tc
                  WHERE c2.cu_id NOT IN (SELECT r.cu_id
                                         FROM  tcs_customer_registrations r)
                  AND   c2.cu_id = tc.id
                  AND   ((tc.cmd_date_created < TO_DATE('16-sep-2008'
                                                      ,'dd-mon-yyyy'
                                                      )
                  AND    c2.retailer_code = 'VT'
                  AND    tc.registration_env_id = 2)
                  OR    (tc.cmd_date_created < TO_DATE('01-mar-2011'
                                                      ,'dd-mon-yyyy'
                                                      )
                  AND    c2.retailer_code = 'SWT'
                  AND    tc.registration_env_id = 8)));


SELECT /*+ parallel 8 */
       COUNT( *)
FROM  cmd_d_customers
WHERE unknown_toc_reg = 'Y';

commit;

spool off
exit
