REM @ECHO OFF
CLS
REM ----------------------------
REM Date Time Variables to Log
SET NOW1=%DATE:~0,2%_%DATE:~3,2%_%DATE:~6,4%_%TIME:~0,2%_%TIME:~3,2%_%TIME:~6,2%
REM ----------------------------
CD "c:\Program Files\Amazon\AWSCLI"
aws configure set AWS_ACCESS_KEY_ID XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
aws configure set AWS_SECRET_ACCESS_KEY XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
aws configure set default.region us-east-1
aws s3 sync b:\mssql\backup s3://mdic-sqld-b/CLSRV.BCL03N-H > b:\awslogs\%NOW1%.txt
REM ----------------------------
SET NOW2=%DATE:~0,2%_%DATE:~3,2%_%DATE:~6,4%_%TIME:~0,2%_%TIME:~3,2%_%TIME:~6,2%
REM ----------------------------
echo FIM - %NOW2% >> b:\awslogs\%NOW1%.txt
exit
