-- =============================================================================
-- File: Find_Missing_DM_Records_By_Schema.sql
-- Desc: This is to check and see if there are any missing records in the FLG_DM_1
--       table that are in the HCIFLAG table.
--
-- Directions
-- #1: Replace <SCHEMA_NAME> with target schema name
-- #2: Run the script
-- #3: Close script without saving
-- 
-- History:
-- Date      Developer       Description
-- -------- ---------------- --------------------------------------------------
-- 20160909 Jonathan Dean    Added v_sch variable to easier switching between schemas.
-- =============================================================================

clear screen
set serveroutput on
SET VERIFY OFF
SET DEFINE ON

DEFINE v_sch = <SCHEMA_NAME>

ALTER SESSION SET CURRENT_SCHEMA=&v_sch.;

WITH LastRunTime AS 
( 
    SELECT Log.ClientCode
         , MAX( Log.Run_Beg ) AS Last_RunDate
      FROM DBA_MONITOR.Rpt_Cube_Log_1 Log
     WHERE Log.DM_Table = 'Flg'
       AND Log.ClientCode IN ('&v_sch.')
     GROUP BY Log.ClientCode
)
SELECT DISTINCT 
       C.CLASEQ          HCICLA_CLASEQ
     , C.CLASUB          HCICLA_CLASUB
     , B.BATCHDATE       HCIBATCH_BATCHDATE
     , F.FLAGSEQ         HCIFLAG_FLAGSEQ
     , 'Fields To Check -->'
     , (SELECT CLIENTCODE FROM LastRunTime)  CLIENTCODE
     , (SELECT TO_CHAR(LAST_RUNDATE - (4/24), 'MM/DD HH24:MI:SS') FROM LastRunTime) DM_PROCESSED
     , TO_CHAR(C.CREATED, 'MM/DD HH24:MI:SS')  HCICLA_CREATED
     , TO_CHAR(C.LAST_UPDATED, 'MM/DD HH24:MI:SS')    HCICLA_LAST_UPDATED
     , TO_CHAR(F.CREATED, 'MM/DD HH24:MI:SS')  HCIFLAG_CREATED
     , TO_CHAR(F.LAST_UPDATED, 'MM/DD HH24:MI:SS')    HCIFLAG_LAST_UPDATED
     , F.SUB_PRODUCT     FLAG_SUB_PRODUCT
     , B.ACTIVE          BATCH_ACTIVE
     , F.EDITTYPE        FLAG_EDITTYPE
     , App.STATUS        APPEAL_STATUS
     , ALI.REASONCODE    APPEALLINE_REASONCODE
     , ALI.RESULT        APPEALLINE_RESULT
     , EDI.*
     , 'HCIFLAG Data -->'
     , F.*
  FROM HCIFLAG F
       INNER JOIN HCICLA C ON F.CLASEQ = C.CLASEQ                             
                          AND F.CLASUB = C.CLASUB 
       INNER JOIN HCIBATCH B ON C.BATCHSEQ = B.BATCHSEQ
       INNER JOIN HCILIN L ON C.CLASEQ = L.CLASEQ
                          AND C.CLASUB = L.CLASUB
       LEFT OUTER JOIN FLG_DM_1 FD ON F.FLAGSEQ = FD.FLAGSEQ
       LEFT OUTER JOIN HciUser.HciAppealLine Ali ON C.ClaSeq = Ali.ClaSeq 
                                                AND C.ClaSub = Ali.ClaSub 
       LEFT JOIN HciUser.HciAppeal App ON Ali.AppealSeq = App.AppealSeq 
       INNER JOIN Repository.Edit Edi ON Edi.EditFlg = F.EditFlg
 WHERE F.EditType <> 'M'                                               
   AND f.sub_product = 'V'                                              
   AND B.active IN ( 'T', 'H', 'F')                                       
   AND FD.FLAGSEQ IS NULL                                                 
   AND B.batchdate >= SYSDATE - 30 --TO_DATE('20140815 00:00:00', 'YYYYMMDD HH24:MI:SS') 
   AND B.EndTime <= (SELECT LAST_RUNDATE FROM LastRunTime)
