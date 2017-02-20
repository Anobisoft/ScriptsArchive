
#Имя файла с таблицей результатов
result="broma.csv"
outlog="broma`date +%F`.log"
{
date +'%F %T'
#Генерируем даты начала и конца периода
date_tmp=`date +%Y-%m`-01
date_begin=`date +%F -d "$date_tmp -1 month"`
date_end=`date +%F -d "$date_tmp -1 day"`
echo "Начало периода $date_begin, конец $date_end"


#Заголовки таблицы
echo "Grid;Название тайтла;дата;время;MSISDN;Оператор PM;Оператор GC;Макрорегион; КН для продажи" > $result

#Суппер-дуппер запрос, я его исправил: возле каждого join добавил full так наверняка убирается недостчет.
#Приводить к нормальному виду влом.
psql -h192.168.200.156 -Udominic -F ";" -tAc "
select	TITLE_PARAM.value,
	TITLE.name,
	ORD.creation_time::date,
	ORD.creation_time::time,
	OPERATOR.name,
	ORD.user_address,
	PaymentMethodSN.short_num,
	MOPaymentMethod.short_num,
	MTPaymentMethod.source_address
from	dc_order ORD
	full join dc_microbilling MicroBilling ON ORD.id = MicroBilling.order_id
	full join dc_title TITLE ON TITLE.id = ORD.title_id
	full join dc_title_copyrighter COPYRIGHTER ON COPYRIGHTER.title_id = TITLE.id
	full join dc_title_parameters TITLE_PARAM ON (TITLE_PARAM.id = TITLE.id and TITLE_PARAM.name in ('Grid','broma_id'))
	full join dc_payment_method PaymentMethod ON PaymentMethod.id = ORD.payment_method_id
	full join dc_operator OPERATOR ON OPERATOR.id = PaymentMethod.operator_id
	full join dc_foreign_payment_method_short_nums PaymentMethodSN ON PaymentMethodSN.id = PaymentMethod.id
	full join dc_mo_payment_method MOPaymentMethod ON MOPaymentMethod.id = PaymentMethod.id
	full join dc_mt_payment_method MTPaymentMethod ON MTPaymentMethod.id = PaymentMethod.id
where	ORD.paid_time::date between '$date_begin' AND '$date_end'
	and MicroBilling.order_id is null
	and ORD.billing_state in ('1','3')
	and ORD.state = 3
	and COPYRIGHTER.copyrighter_id = '12235'; 
" | while read dominic_info #Перенаправляем сразу в цикл, в котором добавляем инфу из гейтконфа
do
	#В лог
	echo "Dominic 	$dominic_info"
	#Отдельно берем оператора
	op_dominic=`echo $dominic_info | awk -F";" 'BEGIN{OFS = ";"}{print $5}'`
	#Оператор бывает пустым
	if [[ $op_dominic == "" ]]
	then 
		op_dominic="unknown"
	fi
	#Отдельно берем msisdn, у него бывает вместо 7 (Россия) XS
	msisdn=`echo $dominic_info | awk 'BEGIN{FS=";"}{print$6}' | sed 's/XS/7/'`
	#По msisdn берем из гейтконфа оператора и макрорегион
	gateconf_info=`psql -hpsql.host.com -Ugateconf -F";" -tAc "
	SET CLIENT_ENCODING TO 'UTF8';
	select	OP.name,
		MR.name
	from	c_address_space ADDRS
		full join c_virtual_region VR on ADDRS.virtual_region_id=VR.id
		full join c_operator OP on VR.operator_id=OP.id
		full join c_macroregion MR on MR.id= VR.macroregion_id
	where '$msisdn' between ADDRS.range_begin and ADDRS.range_end;"`;
	echo "Gateconf	$gateconf_info"
	#Разделяем 
	GC_op=`echo $gateconf_info | awk -F";" '{print $1}'`
	GC_mr=`echo $gateconf_info | awk -F";" '{print $2}'`
	#Там где пусто ставим unknown. Так может быть если произола ошибка из-за корявого номера.
        if [[ $GC_op == "" ]]
	then
		GC_op="unknown"
	fi
        if [[ $GC_mr == "" ]]
	then
		GC_mr="unknown"
	fi
	#Окончательно слепляем результат в порядке, в каком было указанно.
	#Чтобы убрать перенос строки сначала во временную  переменную
	rtmp=`echo $dominic_info | awk -F";" 'BEGIN{OFS = ";"}{print $1, $2, $3, $4, $6}'`
	#Пишем в файл с таблицей результата
	echo -n "$rtmp;$op_dominic;$GC_op;$GC_mr;" >> $result
	#Короткие номера в один столбик убирая лишние точки с запятой
	echo $dominic_info | awk -F";" 'BEGIN{OFS = ";"}{print $7, $8, $9}' | sed 's/;\{1,\}/;/g; s/^;//' >> $result
done
date +'%F %T'
} > $outlog 2>&1
