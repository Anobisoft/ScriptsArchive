netsh interface ip set address "Подключение по локальной сети" static gateway=none
netsh interface ip set dns "Подключение по локальной сети" dhcp
netsh interface ip set dns "Подключение по локальной сети" static 192.168.0.2
netsh interface ip set wins "Подключение по локальной сети" dhcp
netsh interface ip set wins "Подключение по локальной сети" static 192.168.0.2
ipconfig /flushdns
ipconfig /registerdns
rem del ipconf.bat