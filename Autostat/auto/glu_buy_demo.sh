#Подсчет данных по загрузкам из демо-игр GLU с разбивкой по витринам
#Имя файла с таблицей результатов
result="glu_buy_demo.csv"
outlog="glu_buy_demo`date +%F`.log"
input="glu_buy_demo_sync_list"
{
date '+%F %T'
#Генерируем даты начала и конца периода
date_tmp=`date +%Y-%m`-01
date_begin=`date +%F -d "$date_tmp -1 month"` 
date_end=`date +%F -d "$date_tmp -1 day"`
echo "Начало периода $date_begin, конец $date_end"


#Заголовки таблицы
echo "Syncname demo версии;ID Тайтла;Имя тайтла;Syncname;Кол-во загрузок;Витрина" > $result

#Вспомогательная переменная с параметрами подключения к СУБД
psql_param="-h192.168.200.156 -Udominic dominic -tAc"

#Уникалим синкнеймы, удаляя пустые строки и передаем в основной цикл в переменную $syncname_demo
cat $input | grep -vP "^\s*$" | sort | uniq | while read syncname_demo
do 
	#Экранируем апострофы для sql
	syncname_sql=`echo $syncname_demo| sed 's/'"'"'/'"'"''"'"'/g'`
	#Выбираем ID тайтла полной версии по синкнейму укороченной демки 
	title_id=`psql $psql_param "
		select DG.title_id
		from dc_title_parameters TP
			join dc_shortcut_demo_game SDG on TP.id=demo_title_id
			join dc_demo_game DG on DG.id=SDG.id
		where TP.name='syncname' and TP.value='$syncname_sql';"`
	#Если не нашли тайтл, значит синкнейм не правильный, попробуем альтернативу
	if [[ $title_id -eq '' ]]
	then
		#Замещаем все не буквенно числовые символы на % - маска любого количество любых символов
		syncname_sql_alt=`echo $syncname_sql | sed 's/[^a-zA-Z0-9]/%/g; s/%\{2,\}/%/g'`
		#Пишем это в лог
		echo "Альтернативный маскированный syncname $syncname_sql_alt"
		#Точно та же выбираем тайтл полной версии.
		#Разница в том, что вместо полного совпадения syncname демки, ищем нечто подобное =) like '%$syncname_sql_alt%'
		title_id=`psql $psql_param "
			select DG.title_id
			from dc_title_parameters TP
				join dc_shortcut_demo_game SDG on TP.id=demo_title_id
				join dc_demo_game DG on DG.id=SDG.id
			where TP.name='syncname' and TP.value like '%$syncname_sql_alt%';"`
		#Если совсем ничего подобного не нашли
		if [[ $title_id -eq '' ]]
		then
			echo "ОШИБКА: тайтл с таким syncname_demo='$syncname_demo' или похожим (см. альтернативный) не найден."
			#Пропускаем вывод результата
			continue
		else
			#Если таки нашли пишем в лог, чтобы потом можно было проверить правильность находки
			echo "ВНИМАНИЕ! syncname='$syncname_demo' не найден, но найден альтернативный. Пожалуйста, убедитесь, что найдена правильная полная версия."
		fi
	fi

	#Проверяем скрытый тайтл или нет
	hidden=`psql $psql_param "select hidden from dc_title where id='$title_id';"`
	#Если скрытый - считать количество бесполезно. Делаем пометку в лог и в результирующую таблицу вместо подсчетов пишем "Тайтл скрыт!"
	if [[ "$hidden" == "t" ]]
	then 
		echo -n "ВНИМАНИЕ! Тайтл скрыт! "
		brand="Тайтл скрыт!"
		nobrand="Тайтл скрыт!"
	#Иначе считаем количества
	else 	
		#Брендовая витрина (4651,3923,7)
		brand=`psql $psql_param "
			select sum (count)
			from (	select b.id, count(*)
				from dc_order
					join dc_web_user as b on dc_order.partner_id=b.id
				where	title_id='$title_id'
					and buy_from_demo_game=1
					and dc_order.creation_time::date between '$date_begin' and '$date_end'
					and dc_order.state=3 
				group by 1 HAVING b.id in (4651,3923,7)) z;"`
		#Все остальные (не 4651,3923,7)
		nobrand=`psql $psql_param "
			select sum (count)
			from (	select b.id, count(*)
				from dc_order
					join dc_web_user as b on dc_order.partner_id=b.id
				where	title_id='$title_id'
					and buy_from_demo_game=1
					and dc_order.creation_time::date between '$date_begin' and '$date_end'
					and dc_order.state=3
				group by 1 HAVING b.id not in (4651,3923,7)) z;"`
	fi
	#На всякий случай берем имя тайтла полной версии и syncname
	title_name=`psql $psql_param "select name from dc_title where id='$title_id';"`
	syncname=`psql $psql_param "select value from dc_title_parameters where name='syncname' and id='$title_id';"`
	#Пишем в лог основную информацию
	echo "syncname_demo='$syncname_demo' title_id='$title_id' title_name='$title_name' syncname='$syncname'"
	#В таблицу результата пишем 2 строки: бренд и небренд
	echo $syncname_demo";"$title_id";"$title_name";"$syncname";"$brand";бренд" >> $result
	echo $syncname_demo";"$title_id";"$title_name";"$syncname";"$nobrand";небренд" >> $result
#stdout дописываем в лог
done
date '+%F %T'
} > $outlog 2>&1

