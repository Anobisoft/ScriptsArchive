top=`cat top | sed 's/SAMSUNG-//' | sed -e "s/$/%' OR model like '%/" | tr -d '\n' | sed "s/^/model like '%/;s/.................$//"`

count=`psql -hpsql.host.com -Uuser database -tAc "select count(1) from dc_phone_model where ($top) and vendor='Samsung' and phone_model_status_id=0;"`
echo $count

psql -hpsql.host.com -Uuser database -F";" -Ac "
SELECT T.id, T.name, TP.value as syncname, copyrighter_id, WU.name as copyrighter, (
        SELECT STRING_AGG( TAG.name, ',')
                FROM dc_tag_titles TT LEFT JOIN dc_tag TAG ON TAG.id=TT.tag_id
                WHERE T.id=TT.title_id
        ) as tags, count(C.id) as valid
FROM dc_content C
        JOIN dc_title T ON C.title_id=T.id
        JOIN dc_title_parameters TP ON TP.id=T.id
        JOIN dc_title_copyrighter TCR ON T.id=TCR.title_id
        JOIN dc_web_user WU ON WU.id=TCR.copyrighter_id
        JOIN dc_content_phone_models CPHM ON C.id=CPHM.content_id
WHERE   CPHM.phone_model_id in (select id from dc_phone_model where ($top) and vendor='Samsung' and phone_model_status_id=0)
        AND T.creation_time > '2011-01-01'
	AND T.type_id in (select id from dc_title_type where content_type='game')
        AND T.hidden=FALSE
        AND erotic_level='ZERO'
        AND TP.name='syncname'
GROUP BY 1, 2, 3, 4, 5, 6 ORDER BY 7 DESC;
"

