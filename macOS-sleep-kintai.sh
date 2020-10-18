#!/bin/bash -e
# スリープログ(pmset -g log)のうち、ディスプレイのON/OFFを勤怠に使う
# その日の最初の"Display is turned on"→勤務開始
# その日の最後の"Display is turned off"→勤務終了

IFS=$'\n'
# 設定
## ファイルの最大行数
max_row=10
## ログファイル
logfile="/tmp/monthly-kintai.log"
dlog="/tmp/daily-kintai.log"

# 昨日のディスプレイのON/OFFログを取得する
#logs=`pmset -g log | grep "Display is turned" | grep $yesterday | cut -d ' ' -f -15`
dates=`pmset -g log | grep "Display is turned" | cut -d ' ' -f -1 | uniq`

sort $logfile > $logfile

for date in $dates;
do
    logs=`pmset -g log | grep "Display is turned" | grep $date | cut -d ' ' -f -15`
    start=`echo "$logs" | grep "Display is turned on" | head -n 1 | cut -d ' ' -f -2`
    end=`echo "$logs" | grep "Display is turned off" | tail -n 1 | cut -d ' ' -f -2`

    cat $logfile | grep $start > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo $start start >> $logfile
    fi

    cat $logfile | grep $end > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo $end end >> $logfile
    fi
done

# ファイルの行数を取得
#file_row=`cat $logfile | wc -l | /usr/bin/awk '{print $1}'`
#if [ $file_row -ge $max_row ]; then
#    row=`expr $file_row - $max_row`
#    echo $row
#    str=1,$row
#    str2=d
#    str=$str$str2
#    sed -i -e $str $logfile
#fi

