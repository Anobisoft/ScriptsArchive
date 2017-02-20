#Имя файла с таблицей результатов
result="mts_msisdn.csv"
outlog="mts_msisdn`date +%F`.log"

#Генерируем даты начала и конца периода
date_tmp=`date +%Y-%m`-01
date_begin=`date +%F -d "$date_tmp -1 month"`
date_end=`date +%F -d "$date_tmp -1 day"`
echo "Начало периода $date_begin, конец $date_end" > $outlog

#Заголовки таблицы
echo "MSISDN; Оператор; Тайтл" > $result

#Содержимое =)
psql -h192.168.200.156 -Udominic -F";" -tAc "
select	ORD.user_address,
	OP.name,
	TITLE.name
from	dc_order ORD
	full join dc_title TITLE on TITLE.id = ORD.title_id
	full join dc_abonent ABON on ABON.id = ORD.abonent_id
	full join dc_operator OP on OP.id = ABON.operator_id
where	ORD.creation_time::date between '$date_begin' and '$date_end'
	and partner_id = 16751" >> $result

#В лог писать тут нечего =)




