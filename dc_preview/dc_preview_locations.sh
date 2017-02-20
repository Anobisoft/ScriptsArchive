cd /mnt/atatat-nfs/preview/
while read i
do
	t=`echo $i | awk -F"|" '{print $1}'`
	l=`echo $i | awk -F"|" '{print $2}'`
if [ ! -e t_$t ]
  then mkdir t_$t
fi 
cp $l t_$t`echo $l | sed -e 's/^t_.*\//\//g'`

done < /home/pletnev/wrong_preview_locations
