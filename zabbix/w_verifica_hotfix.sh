#!/bin/bash

VAL="1.1.1.1;10052"

#for i in `echo $VAL`
for i in `cat hostsw08.csv | grep -v '^10'`

do

  ip=`echo $i | cut -d ';' -f 1`
  port=`echo $i | cut -d ';' -f 2`
  #echo IP=$ip
  #timeout 10 zabbix_get -s $ip -p $port -k "system.run[powershell -c Get-Service  | findstr SQL]"
  #timeout 10 zabbix_get -s $ip -p $port -k "system.run[powershell -c Get-Service -name *MSSQL* -ErrorAction SilentlyContinue]" | grep -q 'Running'
  zabbix_get -s $ip -p $port -k "system.run[wmic qfe list]" | grep -q 'KB4499164\|KB4499175'
  if [ $? == 0 ]; then
   echo $ip:$port
  fi
done
