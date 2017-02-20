>mysql_test_research.log
for server in `cat mysql_server_list.txt | sed 's/srv-mysql-//'`
do
	nohup ./mysql_test_research.sh $server > ${server}.out &
	echo -e "\e[00;31m${server}\e[00m research started"
	sleep 0.2;
done
