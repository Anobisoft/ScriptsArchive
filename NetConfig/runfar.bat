@echo off
if exist "%programfiles%\far2\far.exe" (
  runas /profile /user:novobaby\Администратор "%programfiles%\far2\far.exe"
) else (
  echo не найден %programfiles%\far2\far.exe
  pause
)

