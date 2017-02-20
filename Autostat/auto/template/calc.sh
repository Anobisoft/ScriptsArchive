
#��� ����� � �������� �����������
result="result.csv"
result2="result2.csv"
outlog="calc`date +%F`.log"

#���������� ���� ������ � ����� �������
date_tmp=`date +%Y-%m`-01
date_begin=`date +%F -d "$date_tmp -1 month"`
date_end=`date +%F -d "$date_tmp -1 day"`
echo "������ ������� $date_begin, ����� $date_end" > $outlog

#��������� �������
echo "������� ���������" > $result
echo "������� ��������" > $result2
for i in {1..10}
do
	echo -n "x^$i;" >> $result2
done
echo "" >> $result2

#������� ���
for i in {1..10}
do
	for j in {1..10}
	do
		x=`echo $i*$j | bc`
		echo -n "$x;" >> $result
	done
	echo "" >> $result
done

#� ��� ����� ����-������ ��������
echo "��������� ������� ���������" >> $outlog

#������� ���
for i in {1..10}
do
	for j in {1..10}
	do
		x=$i
		for (( k=1; k < j; k++ ))
		do
			x=`echo $x*$i | bc`
		done
		echo -n "$x;" >> $result2
	done
	echo "" >> $result2
done


