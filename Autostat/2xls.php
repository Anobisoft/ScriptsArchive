
<?php
 
//��������� ����������
require '/home/sup/scripts/PHPExcel-develop/Classes/PHPExcel/IOFactory.php';
//�������� ������
ini_set("memory_limit", "1G");
 
//������� ����� Excel
$objPHPExcel = new PHPExcel();
//������ ��������� �������� (��������, ��������� � ����)
$objPHPExcel->getProperties()->setTitle("Titles for Samsung");
$objPHPExcel->getProperties()->setSubject("Titles for Samsung");
//���������� ��� .csv ����� � �������� (�� ����� "*.csv")
foreach( glob("*.csv") as $filename )
{
        echo "Open file \"".$filename."\"...\n";
//������� Reader csv ������
$objReader = PHPExcel_IOFactory::createReader('CSV');
//������ �����������, ���������
$objReader->setDelimiter('|');
$objReader->setInputEncoding('windows-1251');
//��������� ���������� �� �����
$myPHPExcel = $objReader->load($filename);
//����� �������� ����
$myWorkSheet = $myPHPExcel->getActiveSheet();
//������������� �������� ����� �� ����� ����� (������ ���������� - ��������� 4 �������)
$myWorkSheet->setTitle(substr($filename, 0, -4));
echo "Add new worksheet from csv file: ".$filename."->".substr($filename, 0, -4).".\n";
//������������� ��������� �����
$myWorkSheet->getColumnDimension('B')->setWidth(50);
$myWorkSheet->getColumnDimension('C')->setWidth(50);
$myWorkSheet->getColumnDimension('D')->setWidth(17);
$myWorkSheet->getColumnDimension('E')->setWidth(0);
$myWorkSheet->getColumnDimension('F')->setWidth(10);
$myWorkSheet->getColumnDimension('G')->setAutoSize(true);
$myWorkSheet->getColumnDimension('H')->setAutoSize(true);
//�� ���� ����� �� ������� ������������. ���� ������� ������ ���, ����� ����.
$myWorkSheet->getTabColor()->setRGB('FF0000');
//��������� ���� � �����
$objPHPExcel->addSheet($myWorkSheet);
 
}
echo "Saving XLS file...\n";
//��������� ����� � ����
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
$objWriter->save('result.xls');

?>
