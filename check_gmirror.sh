#!/bin/sh
# NRPE check for gmirror
# Written by: Søren Klintrup <github at klintrup.dk>

unset ERRORSTRING OKSTRING ERR DEVICES DEVICE DEVICESTRING

PATH="/sbin:/bin:/usr/sbin:/usr/bin"
if [ -x "/sbin/gmirror" ]
then
 # shellcheck disable=SC2086
 DEVICES="$(gmirror list|grep "Geom name"|sed -Ee 's/Geom name: //')"
else
 ERRORSTRING="gmirror binary does not exist on system"
 ERR=3
fi

for DEVICE in ${DEVICES}
do
 # shellcheck disable=SC2086
 DEVICESTRING="$(gmirror list ${DEVICE}|grep -e "^State"|sed -e 's/State: //')"
 # shellcheck disable=SC2086
 if [ "$(echo ${DEVICESTRING}|tr '[:upper:]' '[:lower:]'|sed -Ee 's/.*(complete|degraded|starting).*/\1/')" = "" ]
 then
  ERRORSTRING="${ERRORSTRING} / ${DEVICE}: unknown state"
  if ! [ "${ERR}" = 2 ];then ERR=3;fi
 else
  case $(echo ${DEVICESTRING}|tr '[:upper:]' '[:lower:]'|sed -Ee 's/.*(complete|degraded|starting).*/\1/') in
   degraded)
    if [ $(gmirror list ${DEVICE}|grep "^   Flags"|grep -q "SYNCHRONIZING") ]
    then
     if ! [ "${ERR}" = 2 ] || [ "${ERR}" = 3 ]; then ERR=1;fi
     ERRORSTRING="${ERRORSTRING} / ${DEVICE}: rebuilding"
    else
     ERR=2
     ERRORSTRING="${ERRORSTRING} / ${DEVICE}: DEGRADED"
    fi
    ;;
   starting)
    ERR=3
    ERRORSTRING="${ERRORSTRING} / ${DEVICE}: starting"
    ;;
   complete)
    OKSTRING="${OKSTRING} / ${DEVICE}: ok"
    ;;
   esac
 fi
done

if [ "${1}" ]
then
 if [ "${ERRORSTRING}" ]
 then
  echo "${ERRORSTRING} ${OKSTRING}"|sed s/"^\/ "//|mail -s "$(hostname -s): ${0} reports errors" -E "${@}"
 fi
else
 if [ "${ERRORSTRING}" ] || [ "${OKSTRING}" ]
 then
  echo "${ERRORSTRING} ${OKSTRING}"|sed s/"^\/ "//
  exit ${ERR}
 else
  echo no raid volumes found
  exit 3
 fi
fi
