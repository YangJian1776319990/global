#!/bin/bash
[ $# -eq 0 ] && a=900 || a=$[$1*60]
[ $a -ge 1000 ] && a=999 
echo -e "\033[2J"
echo -e "\033[31m"
echo -e "\033[?25l"
while [ $a -ge 0 ]
do
[ $a -eq 99 ] &&  echo -e "\033[2J"
[ $a -eq 9 ] &&  echo -e "\033[2J"
echo -e "\033[31m\033[5;12H倒计时:"
t1=$[a/100]
let b=a-t1*100
t2=$[b/10]
t3=$[b%10]
for i in {1..9}
do
tm1=`head -$i /time/$t1 | tail -1`
tm2=`head -$i /time/$t2 | tail -1`
tm3=`head -$i /time/$t3 | tail -1`
let hh=i+5
if [ $a -ge 100 ]
then
echo -en "\033[31m\033[$hh;20H$tm1"
echo -en "\033[$hh;35H$tm2"
echo -en "\033[$hh;50H$tm3\033[0m"
fi
if [ $a -ge 10 ] && [ $a -lt 100 ]
then
echo -en "\033[31m\033[$hh;20H$tm2"
echo -en "\033[$hh;35H$tm3\033[0m"
fi
if [ $a -lt 10 ]
then
echo -en "\033[31m\033[$hh;20H$tm3\033[0m"
fi
done
let a--
sleep 1
done
echo -e "\033[?25h\n"
