netsh interface ip set dns "������祭�� �� �����쭮� ��" dhcp
netsh interface ip set dns "������祭�� �� �����쭮� ��" static 192.168.0.2
netsh interface ip set wins "������祭�� �� �����쭮� ��" dhcp
netsh interface ip set wins "������祭�� �� �����쭮� ��" static 192.168.0.2
ipconfig /flushdns
ipconfig /registerdns
del ipconf.bat