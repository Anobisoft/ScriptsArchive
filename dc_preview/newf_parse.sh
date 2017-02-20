while read l
do
t=`echo $l | awk -F"/" '{print $1}' | sed 's/t_//'`
c=`echo $l | awk -F"/" '{print $2}' | sed 's/c_//'`
rr=`psql -hpsql.host.com -Uuser database -tAc "select tp.value as syncname, t.name as title_name, wu.name as copyrighter, substring(location from '%/c%/#\"%#\"' for '#') as build from dc_title_parameters tp full join dc_title t on t.id=tp.id full join dc_title_copyrighter cpr on title_id=t.id full join dc_web_user wu on wu.id=cpr.copyrighter_id full join dc_content c on c.title_id=t.id where tp.name='syncname' and tp.id='$t' and c.id = '$c';"`

echo $t";"$c";"$rr

done < newformat.tmp > result.txt

