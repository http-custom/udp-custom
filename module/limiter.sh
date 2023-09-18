#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

droppids(){
  port_dropbear=`ps aux|grep 'dropbear'|awk NR==1|awk '{print $17;}'`
  log=/var/log/auth.log
  loginsukses='Password auth succeeded'
  pids=`ps ax|grep 'dropbear'|grep " $port_dropbear"|awk -F " " '{print $1}'`
  for pid in $pids; do
    pidlogs=`grep $pid $log |grep "$loginsukses" |awk -F" " '{print $3}'`
    i=0
    for pidend in $pidlogs; do
      let i=i+1
    done
    if [ $pidend ];then
       login=`grep $pid $log |grep "$pidend" |grep "$loginsukses"`
       PID=$pid
       user=`print_center -ama $login |awk -F" " '{print $10}' | sed -r "s/'/ /g"`
       waktu=`print_center -ama $login |awk -F" " '{print $2"-"$1,$3}'`
       while [ ${#waktu} -lt 13 ]; do
           waktu=$waktu" "
       done
       while [ ${#user} -lt 16 ]; do
           user=$user" "
       done
       while [ ${#PID} -lt 8 ]; do
           PID=$PID" "
       done
       print_center -ama "$user $PID $waktu"
    fi
  done
}

sshmonitor(){
  h=1
  unlimit=$(cat /etc/unlimit)
    for i in `print_center -ama "$user_type"`; do

        user="$i"
        s2ssh="$(cat /etc/passwd|grep -w "$i"|awk -F ':' '{print $5}'|cut -d ',' -f1)"

        if [[ "$(cat /etc/passwd| grep -w $user| wc -l)" = "1" ]]; then
          sqd="$(ps -u $user | grep sshd | wc -l)"
        else
          sqd=00
        fi
        [[ "$sqd" = "" ]] && sqd=0

        if [[ -e /etc/openvpn/openvpn-status.log ]]; then
          ovp="$(cat /etc/openvpn/openvpn-status.log | grep -E ,"$user", | wc -l)"
        else
          ovp=0
        fi

        if netstat -nltp|grep 'dropbear'> /dev/null;then
          drop="$(droppids | grep -w "$user" | wc -l)"
        else
          drop=0
        fi

        cnx=$(($sqd + $drop))
        conex=$(($cnx + $ovp))

        if [[ "$conex" -gt "$s2ssh" ]]; then
        	pkill -u $user
        	droplim=`droppids|grep -w "$user"|awk '{print $2}'` 
        	kill -9 $droplim &>/dev/null
        	usermod -L $user
        	print_center -ama "$user $(printf '%(%H:%M:%S)T') $conex/$s2ssh" >> /etc/limit.log
          [[ $unlimit -le 0 ]] && continue || at now +${unlimit} minutes <<< "usermod -U $user" &>/dev/null
        fi
      done
      touch /etc/limit
      timer=$(cat /etc/limit)
      [[ -z ${timer} ]] && timer="3"
      at now +${timer} minutes <<< "/etc/limiter.sh" &>/dev/null
      [[ -z $(cat "/var/spool/cron/crontabs/root"|grep "limiter.sh") ]] && print_center -ama "@reboot root /etc/limiter.sh" >> /var/spool/cron/crontabs/root
}

expired(){
    while read line; do
      userDate=$(chage -l "$line"|sed -n '4p'|awk -F ': ' '{print $2}')
      if [[ $(date '+%s') -gt $(date '+%s' -d "$userDate") ]]; then
        if [[ $(passwd --status $line|cut -d ' ' -f2) = "P" ]]; then  
          usermod -L $line
          print_center -ama "$line $(printf '%(%H:%M:%S)T') expired" >> /etc/limit.log
        fi    
      fi
    done <<< $(print_center -ama "$user_type")
}

all_user=$(cat /etc/passwd|grep 'home'|grep 'false'|grep -v 'syslog'|grep -v '::/')
case $1 in
    -s|--ssh)user_type=$(print_center -ama "$all_user"|grep -v 'hwid\|token'|awk -F ':' '{print $1}') && expired;;
   -h|--hwid)user_type=$(print_center -ama "$all_user"|grep -w 'hwid'|awk -F ':' '{print $1}') && expired;;
  -t|--token)user_type=$(print_center -ama "$all_user"|grep -w 'token'|awk -F ':' '{print $1}') && expired;;
           *)user_type=$(print_center -ama "$all_user"|grep -v 'hwid\|token'|awk -F ':' '{print $1}') && sshmonitor;;
esac
