#!/bin/bash

# Получение значений температуры
#mapfile temp_gpu < <(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)
temp_gpu+=(45 44 39 83 43 43 42)
echo ${temp_gpu[@]}
for  (( i = 0; i < "${#temp_gpu[@]}"; i++ ));do
 if [ "${temp_gpu[$i]}" -gt 82 ];then
     echo "Перегев отрубай"
     systemctl stop docker && systemctl stop docker.socket
     exit 1
 else
     echo "${temp_gpu[$i]}"
 fi
done
