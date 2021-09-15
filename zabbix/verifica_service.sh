#!/bin/bash

VAL="1.1.1.1;8000"

#for i in `echo $VAL`
for i in `cat hostsw08.csv | grep -v '^10'`

do

  ip=`echo $i | cut -d ';' -f 1`
  port=`echo $i | cut -d ';' -f 2`
  #echo IP=$ip
  #timeout 10 zabbix_get -s $ip -p $port -k "system.run[powershell -c Get-Service  | findstr SQL]"
  zabbix_get -s $ip -p $port -k "system.run[powershell -c Get-Service -name MSSQLSERVER -ErrorAction SilentlyContinue]" &> /dev/null

  if [ $? == 0  ]; then
    echo $ip:$port
  fi

done
