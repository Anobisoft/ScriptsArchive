@echo off
if exist "%programfiles%\far2\far.exe" (
  runas /profile /user:novobaby\����������� "%programfiles%\far2\far.exe"
) else (
  echo �� ������ %programfiles%\far2\far.exe
  pause
)

