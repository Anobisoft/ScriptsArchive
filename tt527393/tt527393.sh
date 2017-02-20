cat list | sed 's/SAMSUNG-//;s/\s//g' | grep .  | while read model
do
echo -n "$model "
if [[ `grep -c $model top` -gt 0 ]]
then
	echo -e "\tTOP"
	top="_"
	ordinary=""
else
	echo -e "\tordinary"
	top=""
	ordinary="AND T.creation_time > '2011-01-01'"
fi
psql -hpsql.host.com -Uuser database -F"|" -Ac "
SELECT	DISTINCT T.id,
	T.name,
	TP.value as syncname,
	WU.name as copyrighter,
	copyrighter_id as CR_id,
	T.creation_time::date as date,
	(SELECT STRING_AGG( TAG.name, ',')
		FROM dc_tag_titles TT LEFT JOIN dc_tag TAG ON TAG.id=TT.tag_id
		WHERE T.id=TT.title_id ) as tags,
	(SELECT replace(value, E'\n', ' ') from dc_title_parameters where id=T.id and name='description') as description
FROM dc_content C
	JOIN dc_title T ON C.title_id=T.id
	JOIN dc_title_parameters TP ON TP.id=T.id
	JOIN dc_title_copyrighter TCR ON T.id=TCR.title_id
	JOIN dc_web_user WU ON WU.id=TCR.copyrighter_id
	JOIN dc_content_phone_models CPHM ON C.id=CPHM.content_id
	JOIN dc_phone_model PHM ON PHM.id=CPHM.phone_model_id
	LEFT JOIN dc_phone_model_alias PHMA ON PHMA.phone_model_id=PHM.id
WHERE vendor='Samsung'
	AND phone_model_status_id=0
	AND (model like '%$model%' OR PHMA.alias like 'Samsung%$model')
	AND T.type_id in (select id from dc_title_type where content_type='game')
	$ordinary	
	AND T.hidden=FALSE
	AND erotic_level='ZERO'
	AND TP.name='syncname'
	AND (WU.name <> 'Gameloft2' and WU.name <> 'gameloft_mts_sub')
	AND (TP.value NOT LIKE '%kids_JC_1061' and TP.value NOT LIKE '%JC' and TP.value NOT LIKE '%covers_JC_945' and TP.value NOT LIKE '%JC_70p')
	;
" > ${model}${top}.csv
done

#SELECT	DISTINCT 'http://host.com/content/title/titleForm.jsp?id='||T.id
