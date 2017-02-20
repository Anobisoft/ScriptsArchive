>mysql_test_research.log
for server in `cat mysql_server_list.txt | sed 's/srv-mysql-//'`
do
	nohup ./mysql_test_research.sh $server > ${server}.out &
	echo $server research started
	sleep 2;
done
