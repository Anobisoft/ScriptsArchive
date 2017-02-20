cat list | sed 's/SAMSUNG-//;s/\s//g' | grep .  | while read model
do
#echo $model  
psql -hpsql.host.com -Uuser database -F"|" -tAc "
select distinct id, vendor, model, '$model' from dc_phone_model PHM LEFT JOIN dc_phone_model_alias PHMA ON PHMA.phone_model_id=PHM.id where vendor='Samsung' AND phone_model_status_id=0 AND (model like '%$model%' OR PHMA.alias like 'Samsung%$model') AND model<>'$model' AND model<>'GT-$model' AND model<>'SGH-$model' AND model<>'SHV-$model';
"
done | sort | uniq

