-- =============================================================================
-- File: OI-FLAG_PM-MetricsWorkFlow.sql
-- Desc: This script will ask for the schema name and then display the metric 
--       information for that client from midnight the current day and forward
-- 
-- Directions
-- #1: Run the script
-- #2: If you see a "End Time" that is empty or a "P/F" that is "F", then uncomment 
--     line #36 and re-run to see the error.  
-- #3: Close script without saving
-- 
-- History:
-- Date      Developer       Description
-- -------- ---------------- --------------------------------------------------
-- =============================================================================
clear screen
set serveroutput on;
set verify off;
-- SET LINESIZE 400;
--SET PAGESIZE 400;
 
SELECT SUBSTR(MP.Schema_Name, 1, 5) "Schema"
     , SUBSTR(LPAD(' ', (NVL(MPS.PROCESS_LEVEL, 1) - 1) * 3) || MP.Process_Name, 1, 60) "Process Name"
     , TO_CHAR(MPS.Record_Count, '99,999,999') "RecCount"
     , SUBSTR(TO_CHAR(CAST(MPS.Start_Timestamp AS DATE), 'Mon-DD hh24:mi:ss'), 1, 15) "Start Time"
     , SUBSTR(TO_CHAR(CAST(MPS.End_Timestamp AS DATE), 'Mon-DD hh24:mi:ss'), 1, 15) "End Time"
     , CASE 
           WHEN MPS.End_Timestamp IS NOT NULL THEN TO_CHAR((CAST(MPS.End_Timestamp AS DATE) - CAST(MPS.Start_Timestamp AS DATE)) * 86400, '99,999')
           ELSE null
       END "Seconds"
     , SUBSTR(TO_CHAR(CASE 
                          WHEN MPS.End_Timestamp IS NOT NULL THEN MPS.End_Timestamp - MPS.Start_Timestamp 
                          ELSE null
       END), 12, 11) "Duration"
     , SUBSTR(MPS.PROCESS_RESULT, 1, 1) "P/F"
--     , SUBSTR(MPS.PROCESS_ERROR, 1, 400) "Process Error"       
  FROM PROCESS_MONITOR.MONITOR_PROCESSES MP
         INNER JOIN PROCESS_MONITOR.MONITOR_PROCESS_STATS MPS ON MP.PROCESS_ID = MPS.PROCESS_ID
 WHERE 1 = 1
   AND TRIM(MP.Schema_Name) IN TRIM(UPPER(('&Schema_Name'))) 
   AND CAST(MPS.Start_Timestamp AS DATE) > TRUNC(SYSDATE) - (6/24) -- Example(Last 12 hours: "SYSDATE - (12/24)"

--   AND TO_CHAR(CAST(MPS.Start_Timestamp AS DATE), 'YYYYMMDD') = '20160916'
--   AND MP.Process_Name IN ('PAD_LINE_FACT_DAILY')
--   AND MP.Process_Name IN ('PAD_LINE_FACT_DAILY', 'PAD_FLAG_FACT_DAILY', 'PAD_LIN_AGG_DAILY', 'PAD_FACT_DIM_LOAD_DAILY', 'PAD_FRAUD_TRIG_FACT_DAILY', 'PAD_INVOICE_FACT_DAILY' )
--   AND MPS.PROCESS_LEVEL = 1
 ORDER BY MPS.CLIENT_CODE ASC, MPS.PROC_STAT_ID  ASC
;