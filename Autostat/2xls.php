
<?php
 
//добавляем библиотеку
require '/home/sup/scripts/PHPExcel-develop/Classes/PHPExcel/IOFactory.php';
//побольше памяти
ini_set("memory_limit", "1G");
 
//создаем книгу Excel
$objPHPExcel = new PHPExcel();
//задаем некоторые свойства (например, заголовок и тему)
$objPHPExcel->getProperties()->setTitle("Titles for Samsung");
$objPHPExcel->getProperties()->setSubject("Titles for Samsung");
//перебираем все .csv файлы в каталоге (по маске "*.csv")
foreach( glob("*.csv") as $filename )
{
        echo "Open file \"".$filename."\"...\n";
//Создаем Reader csv файлов
$objReader = PHPExcel_IOFactory::createReader('CSV');
//Задаем разделитель, кодировку
$objReader->setDelimiter('|');
$objReader->setInputEncoding('windows-1251');
//Загружаем содержимое из файла
$myPHPExcel = $objReader->load($filename);
//берем активный лист
$myWorkSheet = $myPHPExcel->getActiveSheet();
//Устанавливаем название листа по имени файла (убирая расширение - последние 4 символа)
$myWorkSheet->setTitle(substr($filename, 0, -4));
echo "Add new worksheet from csv file: ".$filename."->".substr($filename, 0, -4).".\n";
//Устанавливаем параметры листа
$myWorkSheet->getColumnDimension('B')->setWidth(50);
$myWorkSheet->getColumnDimension('C')->setWidth(50);
$myWorkSheet->getColumnDimension('D')->setWidth(17);
$myWorkSheet->getColumnDimension('E')->setWidth(0);
$myWorkSheet->getColumnDimension('F')->setWidth(10);
$myWorkSheet->getColumnDimension('G')->setAutoSize(true);
$myWorkSheet->getColumnDimension('H')->setAutoSize(true);
//по идее можно по условию подкрашивать. сюда добавлю просто так, чтобы было.
$myWorkSheet->getTabColor()->setRGB('FF0000');
//Добавляем лист в книгу
$objPHPExcel->addSheet($myWorkSheet);
 
}
echo "Saving XLS file...\n";
//Сохраняем книгу в файл
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
$objWriter->save('result.xls');

?>
