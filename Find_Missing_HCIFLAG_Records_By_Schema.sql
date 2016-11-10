-- =============================================================================
-- File: Find_Missing_HCIFLAG_Records_By_Schema.sql
-- Desc: This is to check and see if there are any missing records in the HCIFLAG
--       table that in the FLG_DM_1 table.
--
-- Directions
-- #1: Replace <SCHEMA_NAME> with target schema name
-- #2: Run the script
-- #3: Close script without saving
-- 
-- History:
-- Date      Developer       Description
-- -------- ---------------- --------------------------------------------------
-- =============================================================================
clear screen
set serveroutput on

ALTER SESSION SET CURRENT_SCHEMA=<SCHEMA_NAME>;

SELECT FD.BATCHDATE
     , FD.BATCHID
     , FD.BATCHDATE
     , FD.BATCHSEQ
     , count(*)
  FROM FLG_DM_1 FD
       LEFT OUTER JOIN HCIFLAG F ON F.FLAGSEQ = FD.FLAGSEQ
 WHERE F.FLAGSEQ IS NULL                                                 
 GROUP BY FD.BATCHDATE
     , FD.BATCHID
     , FD.BATCHDATE
     , FD.BATCHSEQ
 ORDER BY FD.BATCHDATE
     , FD.BATCHID
     , FD.BATCHDATE
     , FD.BATCHSEQ
;
 