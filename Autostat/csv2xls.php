<?php

require '/home/sup/scripts/PHPExcel-develop/Classes/PHPExcel/IOFactory.php';

function csv2xls($input, $output, $Delimiter=';', $cp='UTF-8')
{
$objReader = PHPExcel_IOFactory::createReader('CSV');

// If the files uses a delimiter other than a comma (e.g. a tab), then tell the reader
$objReader->setDelimiter($Delimiter);
// If the files uses an encoding other than UTF-8 or ASCII, then tell the reader
$objReader->setInputEncoding($cp);

$objPHPExcel = $objReader->load($input);
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
$objWriter->save($output);
}

?>
