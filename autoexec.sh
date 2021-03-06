#!/bin/bash
# 20170116~20170203 by Wei-Lun Chao
#
export PS1='\[\e[1;33m\]\u@\w> \[\e[0m\]'
export LANG=zh_TW.UTF-8
export SETFILE=$HOME/autoexec.set

function default {
  echo -e "\033[32m"
  echo "####################################"
  echo "# 基於 Fedora Linux 的自動執行系統 #"
  echo "####################################"
  echo -e "\033[33m用法：\033[0m"
  echo -e '\tautoexec reboot 100 [10]'
  echo -e '\tautoexec rtcwake 50 [10]'
  echo -e '\tautoexec suspend 20 [10]'
  echo -e '\tautoexec poweroff 10 [10]'
  echo -e "\033[36m修改 $HOME/autoexec 中 default 函式內容以自訂功能\033[0m"
  echo
  echo -e "\033[33m應用：\033[0m"
  echo -e '\thwqv #硬體資訊快速檢視'
  echo -e '\twakethemup #發送網路喚醒訊號'
  echo -e '\tdd if=/dev/sda | gzip -c > /opt/sata-or-usb.dd.gz'
  echo -e '\tdd if=/dev/mmcblk0 | zip /opt/emmc-or-sd.img.zip -'
  echo -e '\tgunzip -c /opt/sata-or-usb.dd.gz | dd of=/dev/sda'
  echo -e '\tunzip -p /opt/emmc-or-sd.img.zip | dd of=/dev/mmcblk0'
  echo -e "\033[36m"
  ip addr | grep -A 1 link/ether
  echo -e "\033[0m"
}

function autorun {
  if [ -f $SETFILE ] ; then
    source $SETFILE
    rm -f $SETFILE
    sync
    let COUNT=COUNT+1
    if [ $COUNT -le $TOTAL ] ; then
      echo -e "等待 $INTERVAL 秒以執行 ${COMMAND^^}: $COUNT/$TOTAL ..."
      sleep $INTERVAL
      echo COMMAND=$COMMAND > $SETFILE
      echo TOTAL=$TOTAL >> $SETFILE
      echo COUNT=$COUNT >> $SETFILE
      echo INTERVAL=$INTERVAL >> $SETFILE
      echo $COUNT: `date +%c` >> $HOME/autoexec.log
      sync      
      case $COMMAND in
        reboot)
          reboot
          ;;
        rtcwake)
          rtcwake -m mem -s 4 &>/dev/null
          autorun
          ;;
        suspend)
          systemctl suspend
          sleep 1
          autorun
          ;;
        poweroff)
          systemctl poweroff
          sleep 1
          ;;
      esac
    else
      default
      exec bash
    fi
  else
    default
    exec bash
  fi
}

if [ -z "$1" ] ; then
  COMMAND=""
  TOTAL=0
  COUNT=0
  autorun
else
  if [ "$1" = reboot -o "$1" = rtcwake -o "$1" = suspend -o "$1" = poweroff -a "$2" -gt 0 &>/dev/null ] ; then
    echo COMMAND=$1 > $SETFILE
    echo TOTAL=$2 >> $SETFILE
    echo COUNT=0 >> $SETFILE
    echo INTERVAL=${3:-10} >> $SETFILE
    echo "${1^^}: 重複 $2 次，等待 ${3:-10} 秒" > $HOME/autoexec.log
    autorun
  else
    default
    exec bash
  fi
fi
