#Имя файла с таблицей результатов
result="subs_try-n-buy.csv"
outlog="subs_try-n-buy`date +%F`.log"
input="subs_try-n-buy_act_list.txt"

{
date '+%F %T'
tempinput=`mktemp /tmp/subs_list.XXX`
tempfile=`mktemp /tmp/subsinfo.XXX`
#Убираем пустые строки и все пробелы
cat $input | sort | uniq | grep -vP "^\s*$" | sed 's/\s//g' > $tempinput
#Подменяем входной файл на исправленный
mv $tempinput $input

#Генерируем даты начала и конца периода
date_tmp=`date +%Y-%m`-01
date_begin=`date +%F -d "$date_tmp -1 month"`
date_end=`date +%F -d "$date_tmp -1 day"`
echo "Начало периода $date_begin, конец $date_end" > $outlog


#Заголовки таблицы
echo "subs;subname;copyrighter;count;count7;price;service;" > $result

#Вспомогательные переменные с параметрами подключения к СУБД
psql_param="-hpsql.host.com -Usubscriber -tAc"
mysql_param="-hmysql.host.com -uuser database -ppassword --default-character-set=utf8 -Ne"

cat $input | while read subs
do
	echo $subs
	#Данные по акциям с БД подписочной витрины. Влево все join т.к. влом думать =)
	mysql $mysql_param "
		select distinct
			subs_services.name,
			subs_units.name,
			copyrighters.name,
			subs_services.price_text
		from	subs_units
			left join cnt on cnt_id=cnt.id
			left join copyrighters on copyrighters.id=copyrighters
			left join subs_unit_to_services on subs_units.id=unit_id
			left join subs_services on service_id=subs_services.id
		where subs_units.id='$subs';" > $tempfile
	#В лог
	cat $tempfile
	#Считаем тупо общее количество пробилленых подписок за период
	count=`psql $psql_param "
		select	count(s.id)
		from	ss_subscription s,
			ss_paid_period p
		where	p.subscription_id=s.id
			and s.action_id='$subs'
			and p.billing_status='BILLED'
			and p.billing_time::date between '$date_begin' and '$date_end';" `
	#То же только для партнера 7
	count7=`psql $psql_param "
		select	count(s.id)
		from	ss_subscription s,
			ss_paid_period p
		where	p.subscription_id=s.id
			and s.action_id='$subs'
			and p.billing_status='BILLED'
			and p.billing_time::date between '$date_begin' and '$date_end'
			and partner_id='7';"`
	#Распарсим первую строку
	info=`head -1 $tempfile`
	service=`echo "$info" | awk -F"\t" '{print $1}'`
	subname=`echo "$info" | awk -F"\t" '{print $2}'`
	copyrighter=`echo "$info" | awk -F"\t" '{print $3}'`
	price=`echo "$info" | awk -F"\t" '{print $4}'`
	first=true
	#Пишем все в результат
	echo "$subs;$subname;$copyrighter;$count;$count7;$price;$service;" >> $result
	#Теперь в цикле пишем только цену и сервис, т.к. остальне одинаковое
	while read info
	do
		#Первую строку уже записали - пропускаем
		if $first
		then
			first=false
			continue
		fi
		service=`echo "$info" | awk -F"\t" '{print $1}'`
		price=`echo "$info" | awk -F"\t" '{print $4}'`
		echo ";;;;;$price;$service;" >> $result
	done < $tempfile
	#Тупо, но эффективно =)
done

rm $tempfile

date '+%F %T'

} > $outlog 2>&1



