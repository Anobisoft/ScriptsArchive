<?php
ini_set("memory_limit", "1G");
include '/home/sup/scripts/statistics/auto/PHPExcel-develop/Classes/PHPExcel/IOFactory.php';

$objPHPExcel = new PHPExcel();
$objPHPExcel->getProperties()->setTitle("OMG!");
$objPHPExcel->getProperties()->setSubject("ATATAT!");

foreach( glob("*.csv") as $filename )
{
	echo "Open file \"".$filename."\"...\n";
$model=substr($filename, 0, -4);
if (substr($model, -1) == '_' ) {
	$top=" TOP";
	$model=substr($model, 0, -1);
} else $top="";
echo "model: $model\n";
$objReader = PHPExcel_IOFactory::createReader('CSV');
$objReader->setDelimiter('|');
$objReader->setInputEncoding('windows-1251');
$myPHPExcel = $objReader->load($filename);
$myWorkSheet = $myPHPExcel->getActiveSheet();
$myWorkSheet->setTitle($model.$top);
echo "Add new worksheet from csv file: ".$filename."->".$model.".\n";
$myWorkSheet->getColumnDimension('B')->setWidth(50);
$myWorkSheet->getColumnDimension('C')->setWidth(50);
$myWorkSheet->getColumnDimension('D')->setWidth(17);
$myWorkSheet->getColumnDimension('E')->setWidth(0);
$myWorkSheet->getColumnDimension('F')->setWidth(10);
$myWorkSheet->getColumnDimension('G')->setAutoSize(true);
$myWorkSheet->getColumnDimension('H')->setAutoSize(true);
$objPHPExcel->addSheet($myWorkSheet);


}
echo "Saving XLS file...\n";
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
$objWriter->save('tt527393_result.xls');

?>
