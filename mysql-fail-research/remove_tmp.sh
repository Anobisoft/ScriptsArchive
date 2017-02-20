for server in `cat mysql_server_list.txt | sed 's/srv-mysql-//'`
do
   rm *${server}*
done
