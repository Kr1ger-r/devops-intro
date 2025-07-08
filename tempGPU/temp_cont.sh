#!/bin/bash

# Получение значений температуры
mapfile temp_gpu < <(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)
mapfile temp_gpu_index < <(nvidia-smi --query-gpu=index --format=csv,noheader)

TEMPHIGHT=0
for  (( i = 0; i < "${#temp_gpu[@]}"; i++ ));do
 if [ "${temp_gpu[$i]}" -gt 82 ];then
     echo " Перегрев GPU модуля с индексом ${temp_gpu_index[$i]}"
     TEMPHIGHT=1
     mes=" Перегрев модуля ${temp_gpu_index[$i]}, его температура ${temp_gpu[$i]} "
    ./send_telegram.sh "$mes"
 else
     echo " Температура модулей в норме "
 fi
done

if [ $TEMPHIGHT -eq 1 ];then
 systemctl stop docker && systemctl stop docker.socket
 exit 1
elif [ $TEMPHIGHT -eq 0 ];then
 mes="Температура модулей в норме"
 ./send_telegram.sh "$mes"
fi

#temp_gpu+=(40 32 55 222 23 55)
#temp_gpu_index+=(0 1 2 3 4 5)
#echo ${temp_gpu[@]}
