#!/bin/bash
# スリープログ(pmset -g log)のうち、ディスプレイのON/OFFを勤怠に使う
# その日の最初の"Display is turned on"→勤務開始
# その日の最後の"Display is turned off"→勤務終了

# 設定
## ファイルの最大行数
max_row=200
## ログファイル
logfile="/tmp/monthly-kintai.log"

yesterday=$(date -v -1d +"%Y-%m-%d")
# 昨日のディスプレイのON/OFFログを取得する
logs=`pmset -g log | grep "Display is turned" | grep $yesterday | cut -d ' ' -f -15`
echo "$logs" > /tmp/daily-kintai.log

# ファイルの行数を取得
file_row=`cat $logfile | wc -l | /usr/bin/awk '{print $1}'`

if [ $file_row -ge $max_row ]; then
    sed -i -e '1,2d' $logfile
    echo "$logs" | grep "Display is turned on" | head -n 1 | cut -d ' ' -f -2 >> $logfile
    echo "$logs" | grep "Display is turned off" | tail -n 1 | cut -d ' ' -f -2 >> $logfile
else
    echo "$logs" | grep "Display is turned on" | head -n 1 | cut -d ' ' -f -2 >> $logfile
    echo "$logs" | grep "Display is turned off" | tail -n 1 | cut -d ' ' -f -2 >> $logfile
fi

