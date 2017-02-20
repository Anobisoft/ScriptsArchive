<?php

require '/home/sup/scripts/PHPExcel-develop/Examples/csv2xls.php';

function help() {
	echo "Usage: php sendmail.php [options]
  -c <file>	Parse config file and send mail (or use default ~/.sendmail.cfg.xml).
  -h		This help.
  -l <file>	Log file.
  -s		Silent mode.\n";
	exit(0);
}

function dt_now() {
	$dt = new DateTime('NOW');
	return $dt->format("Y-m-d H:i:s");
}

$default_cfg = "./.sendmail.cfg.xml";
$default_log = "./sendmail.log";
/*
function silent() {
	return NULL;
}
*/
$options = getopt("l:c:sh");

if (isset($options["h"])) {
	help();	
}
if (isset($options["s"])) {
	ob_start();
	$silent = true;
}
if (isset($options["l"])) {
    if ($options["l"] != "") {
        $logfile = $options["l"];
    } else help();
} else $logfile = $default_log;

if (isset($options["c"])) {
	if ($options["c"] != "") {
		$cfg = $options["c"];
	} else help();
} else $cfg = $default_cfg;

echo dt_now()." Begin\n";

echo "Trying to open config: ".$cfg."\n";
if (file_exists($cfg)) $config = simplexml_load_file($cfg);
else exit("Не удалось открыть файл: ".$cfg."\n");


$EOL = "\r\n"; // ограничитель строк, некоторые почтовые сервера требуют \n - подобрать опытным путём
$boundary     = "--".md5(uniqid(time()));  // любая строка, которой не будет ниже в потоке данных.  

foreach ($config->email as $email)
{
	if (isset($email->disabled)) continue;
	if (isset($email->bash)) {
		$bash = shell_exec($email->bash);
		$bash = trim($bash);
		echo "Bash: $email->bash\nResult: $bash\n";
	} else $bash = "";
	$from = $email['from'];
	$subj = $email['subj'];
	$subj = str_replace("%bash%", $bash, $subj);
	echo "SUBJ: $subj\n";
	$cc = "";
	$to = "";
	foreach ($email->to as $t)
	{
		$to .= $t.",";
	}
	echo "TO: $to\n";
	foreach ($email->cc as $c)
	{
		$cc .= $c.",";
	}

	$body = trim($email->body);
	$body = str_replace("\n", "<br />\n", $body);
	$body = str_replace("%bash%", $bash, $body);

	$headers  = "MIME-Version: 1.0;$EOL";
	$headers .= "Content-Type: multipart/mixed; boundary=\"$boundary\"$EOL";
	$headers .= "From: $from$EOL";
	$headers .= "Cc: $cc$EOL";
	echo $headers;
	echo "BODY:\n$body\n";

	$multipart  = "--$boundary$EOL";
	//$multipart .= "Content-Type: text/html; charset=windows-1251$EOL";
	$multipart .= "Content-Type: text/html; charset=utf-8$EOL";
	$multipart .= "Content-Transfer-Encoding: base64$EOL";
	$multipart .= $EOL; // раздел между заголовками и телом html-части
	echo "$multipart";

	$multipart .= chunk_split(base64_encode($body));

	foreach ($email->attach as $att)
	{
		$path = $att->path;
		if (file_exists($path))
		{
			echo "Attach: $path\n";
			$tmpfname = tempnam('', '');
			echo "Tmp: $tmpfname\n";
			$name = $att->name;
			$name = str_replace("%bash%", $bash, $name);
			echo "Name: $name\n";
			if (isset($att->csv2xls)) {
				echo "Converting csv2xls\n";
				csv2xls($path, $tmpfname);
				echo "OK\n";
			} else if (!copy($path, $tmpfname)) echo "Не удалось скопировать $path -> $tmpfname.\n";
			$fp = fopen("$tmpfname", "rb");
			if (!$fp) {
				echo "Не удалось открыть файл $tmpfname.\n";
			}
			$file = fread($fp, filesize("$tmpfname"));   
			fclose($fp);
			unlink("$tmpfname");

			$multipart .= "$EOL--$boundary$EOL";
			$multipart .= "Content-Type: application/octet-stream; name=\"$name\"$EOL";
			$multipart .= "Content-Transfer-Encoding: base64$EOL";
			$multipart .= "Content-Disposition: attachment; filename=\"$name\"$EOL";
			$multipart .= $EOL; // раздел между заголовками и телом прикрепленного файла
			echo "$multipart\n";
			$multipart .= chunk_split(base64_encode($file));
		} else echo "Ошибка: файл $path не найден.";
	}
	

	$multipart .= "$EOL--$boundary--$EOL";
	echo ">>> SEND >>>\n\n";

	mail($to, $subj, $multipart, $headers);

}

echo dt_now()." End\n";

if (isset($silent)) { 
	$log = ob_get_contents();
	$fw = fopen("$logfile", "w");
	fputs($fw, $log, strlen($log));
	fclose($fw);
	ob_end_clean();
}



?>
