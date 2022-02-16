#!/bin/bash -e
# スリープログ(pmset -g log)のうち、ディスプレイのON/OFFを勤怠に使う
# その日の最初の"Display is turned on"→勤務開始
# その日の最後の"Display is turned off"→勤務終了

IFS=$'\n'
# 設定
## ファイルの最大行数
max_row=200
## ログファイル
logfile="/Library/Logs/monthly-kintai.log"
##dlog="/tmp/daily-kintai.log"

if [ ! -e $logfile ]; then
    touch $logfile
fi

# ディスプレイのON/OFFログを取得して重複排除
dates=(`pmset -g log | grep "Display is turned" | cut -d ' ' -f -1 | uniq`)

sort $logfile > $logfile
today=`date +'%Y-%m-%d'`

for date in ${dates[@]};
do
    # 本日分は除外し、昨日までのデータを処理
    if [ $date != $today ]; then
        logs=`pmset -g log | grep "Display is turned" | grep ${date} | cut -d ' ' -f -15`

        start=`echo "$logs" | grep "Display is turned on" | head -n 1 | cut -d ' ' -f -2`
        end=`echo "$logs" | grep "Display is turned off" | tail -n 1 | cut -d ' ' -f -2`

        # 開始時間
        cat $logfile | grep $start > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo $start start
            echo $start start >> $logfile
        fi

        # 終了時間
        cat $logfile | grep $end > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo $end end
            echo $end end >> $logfile
        fi
    fi
done

# ファイルの最大行数をコントロール
file_row=`cat $logfile | wc -l | /usr/bin/awk '{print $1}'`
if [ $file_row -ge $max_row ]; then
    row=`expr $file_row - $max_row`
    str="1,${row}d"
    sed -i -e $str $logfile
fi

