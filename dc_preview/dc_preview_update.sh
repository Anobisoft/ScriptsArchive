while read i
do
	t=`echo $i | awk -F"|" '{print $1}'`
	p=`echo $i | awk -F"|" '{print $2}'`
	l=`echo $i | awk -F"|" '{print $3}'`

n=t_$t`echo $l | sed -e 's/^t_.*\//\//g'`
psql -hpsql.host.com -Uuser database -tAc "begin; update dc_preview set location = '$n' where id='$p'; end;"

done < wrong_preview_locations
