#!/bin/bash

# Получение значений температуры
mapfile temp_gpu < <(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)
for  (( i = 0; i < "${#temp_gpu[@]}"; i++ ));do
 if [ "${temp_gpu[$i]}" -gt 82 ];then
     echo "Перегев вырубай"
     systemctl stop docker && systemctl stop docker.socket
     exit 1
 else
     echo "${temp_gpu[$i]}"
 fi
done