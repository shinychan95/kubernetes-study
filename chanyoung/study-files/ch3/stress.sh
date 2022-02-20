#!/bin/bash

TPS=$1
URL=$2

LOG=./result.log

for((i=0;;i++))
do
  echo -en "\r$i sec"
  for _ in `seq 1 $TPS`
  do
    curl -o /dev/null -s -w '%{http_code}\t%{time_total}' "${URL}" | awk 1  >> ${LOG} &
  done
  sleep 1
done
