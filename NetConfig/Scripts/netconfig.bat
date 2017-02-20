for /f "tokens=2 delims==" %%a in ('wmic path Win32_networkadapter where ^"NetConnectionStatus^=2^" get NetConnectionID /value') do set NETWORK=%%a
rem netsh interface ip set address "%NETWORK%" static 172.30.0.%1 255.255.255.0 172.30.0.1 1
rem netsh interface ip set dns "%NETWORK%" static 195.149.200.230
rem netsh interface ip add dns "%NETWORK%" 91.196.244.70