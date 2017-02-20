'----------------------------------------------------------------------
'
' Copyright (c)  All rights reserved.
'
' 
' AUTHOR: tudimon.com 
' DATE: 15.09.2010 
' NAME: change_discription_comp.vbs
'
' COMMENT: 
'
' Изменение описания компьютера (описание то, что видно в проводнике в сетевом окружении)
' Имя компьютера и новое описание запрашивается у пользователя.
' основная идея взята на  http://forum.vingrad.ru/forum/topic-154708/view-all.html
' 
'
' 
'----------------------------------------------------------------------
On Error Resume Next

Set objShell = CreateObject("WScript.Shell")

' запросим имя компьютера       
strComputer = ""
strComputer = InputBox ("Введите имя компьютера для которого нужно добавить (изменить) описание: ","Input computer name", strComputer)

' предупредим 
' MsgBox  "Будем менять описание у " & strComputer

' Пингом проверим что комп включен
    Set objScriptExec = objShell.Exec("%comspec% /c ping.exe -n 2 " & strComputer)
    strPingResults = LCase(objScriptExec.StdOut.ReadAll)
    
    If InStr(strPingResults, "ttl=") Then
		' включен
		
		' запросим новое описание 
		strNewDescription = ""
		strNewDescription = InputBox ("Введите новое описание для " & strComputer ,"Input New Description", strNewDescription)
		
		' изменим описание 
        Set objWMIService = GetObject("winmgmts:\\" & strComputer).InstancesOf("Win32_OperatingSystem") 
        For Each x In objWMIService
            x.Description = strNewDescription
            x.Put_
        Next
		
		' Сообщим результат
		MsgBox "У компьютера " & strComputer & " новое описание = " & strNewDescription 
		
    Else
		' выключен
		MsgBox strComputer & " не пингуется. Попробуйте позвонить позднее :) "
    End If


	