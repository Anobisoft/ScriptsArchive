X=1

prev=`cat mysql_test_result`
mysql -hsrv-mysql-wurfl -uprocesslist -ppassword -e "SHOW STATUS;" 2> mysql_test_error | grep Aborted_connects | awk '{print $2}' > mysql_test_result
res=`cat mysql_test_result`
err=`cat mysql_test_error | wc -l`

if [ $err -gt 0 ]
then
	cat mysql_test_error
else
	if [ $(($res-$prev)) -gt $X ]
	then
		echo “Current Aborted_connects: $res”
		echo “Previous Aborted_connects: $prev”
	else
		echo “OK”
	fi 
fi

