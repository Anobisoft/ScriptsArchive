Usr_AcName = "Шведов АВ"
NewPassword = "1127271"
domain = "dc=novobaby, dc=local"
adtable = "D:\AD.xlsx"

  Set objConnection = CreateObject("ADODB.Connection")
  objConnection.Open "Provider=ADsDSOObject;"
  Set objCommand = CreateObject("ADODB.Command")
  objCommand.ActiveConnection = objConnection
  objCommand.CommandText = "<LDAP://"&domain&">;(&(objectCategory=User)(samAccountName="&usr_acname&"));samAccountName;subtree"
  Set objRecordSet = objCommand.Execute 

  if objRecordSet.RecordCount = 0 then
    Wscript.Echo "Такого пользователя не существует."&vbCrLF&"Воспользуйтесь утилитой добавления нового пользователя в домен."
  else
    Set objUser = GetObject("LDAP://cn="&usr_acname&", "&domain) 
    with objUser
      if .AccountDisabled = TRUE then 
        Wscript.Echo "Account Disabled"
      else
        .SetPassword NewPassword
        id = .telephoneNumber

        Set objExcel = CreateObject("Excel.Application")
        Set objWorkbook = objExcel.Workbooks.Open(adtable)
        iRow = 2
        Do Until trim(objExcel.Cells(iRow,2).Value) = id OR trim(objExcel.Cells(iRow,1).Value) = ""
          iRow = iRow + 1
        Loop
        if trim(objExcel.Cells(iRow,1).Value) = "" then 
          objExcel.Cells(iRow, 1) = .FullName
          objExcel.Cells(iRow, 2) = .TelephoneNumber
          objExcel.Cells(iRow, 4) = .EMailAddress
          objExcel.Cells(iRow, 5) = .Description
          objExcel.Cells(iRow, 6) = "Added by ChangePassword.vbs script"
          Wscript.Echo "В табличке AD.xlsx записи с таким id ("&id&") почему-то не существует."&vbCrLF _
                      &"Поэтому была добавлена новая запись:"&vbCrLF _
                      &.Fullname &" | "& .TelephoneNumber &" | "& NewPassword &" | "& .EMailAddress &" | "& .Description &vbCrLF
        end if
        objExcel.Cells(iRow, 3) = NewPassword

        objWorkbook.Save
        objWorkbook.Close
        objExcel.Quit

        Wscript.Echo "Новый пароль установлен"
      end if
    end with
  end if