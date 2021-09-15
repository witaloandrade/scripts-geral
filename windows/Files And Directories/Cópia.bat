@ECHO OFF
SETLOCAL

SET _source=\Users\Administrator\Desktop\teste1

SET _dest=\Users\Administrator\Desktop\teste2

SET _what=/COPYALL /B /SEC /MIR
:: /COPYALL :: COPY ALL file info
:: /B :: copy files in Backup mode. 
:: /SEC :: copy files with SECurity
:: /MIR :: MIRror a directory tree 

SET _options=/R:0 /W:0 /LOG:MyLogfile.txt /NFL /NDL
:: /R:n :: number of Retries
:: /W:n :: Wait time between retries
:: /LOG :: Output log file
:: /NFL :: No file logging
:: /NDL :: No dir logging

ROBOCOPY %_source% %_dest% %_what% %_options%