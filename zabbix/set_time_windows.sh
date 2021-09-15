#!/bin/bash

while read line

 do

   IP=`echo -e $line | awk '{print $1}'`
   PORT=`echo -e $line | awk '{print $2}'`

   nc -w 4 -zv $IP $PORT &> /dev/null

   if [ $? == "0" ]; then

      HOST1=`zabbix_get -s $IP -p $PORT -k agent.hostname`
      echo "Executando set_time em $HOST1"

      echo "Baixando ScriptHora em $HOST1-$1"
      zabbix_get -s $IP -p $PORT -k 'system.run[powershell -c Invoke-WebRequest -Uri http://tools.anysite.net/hora/ScriptHora_1.ps1 -OutFile C:/Windows/ScriptHora_1.ps1]'

      echo "Executando ScriptHora em $HOST1-$1"
      RES=`zabbix_get -s $IP -p $PORT -k 'system.run[powershell -c C:/Windows/ScriptHora_1.ps1]' | grep "completed" | awk '{print $3}'`
      echo $RES

      if [ $RES == "completed" ]; then

        echo $1:$2,$HOST1,OK >> /root/output.csv

      else

        echo $1:$2,$HOST1,ERRO >> /root/output.csv

      fi

   else

      echo $1:$2,$HOST1,ERRO >> /root/output.csv

   fi
done < imput_csv
