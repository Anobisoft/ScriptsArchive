if [ -z "$1" ]
then
  echo -e "Задайте имя сервера (srv-mysql-\e[00;31m\$1\e[00m)!"
  exit 1
fi

echo '0' > mysql_test_$1_result

while true
do
	>mysql_test_$1_error
	prev=`cat mysql_test_$1_result`
	mysql -hsrv-mysql-$1 -uprocesslist -ppassword -e "SHOW STATUS;" 2> mysql_test_$1_error | grep Aborted_connects | awk '{print $2}' > mysql_test_$1_result
	res=`cat mysql_test_$1_result`
	err=`cat mysql_test_$1_error | wc -l`

	if [ $err -gt 0 ]
	then
		sleeptime=5
	        date +'%F %X MSK' | tr '\n' '\t' >> mysql_test_research.log
		echo "srv-mysql-$1" | tr '\n' '\t' >> mysql_test_research.log
		cat mysql_test_$1_error >> mysql_test_research.log
	else
		sleeptime=60
		if [ $res -gt $prev ]
		then
			date +'%F %X MSK' | tr '\n' '\t' >> mysql_test_research.log
			echo "srv-mysql-$1" | tr '\n' '\t' >> mysql_test_research.log
			echo "Aborted_connects $res" >> mysql_test_research.log
			prev=$res
		fi 
	fi
	
	sleep $sleeptime
	date +'%F %X MSK'
done

