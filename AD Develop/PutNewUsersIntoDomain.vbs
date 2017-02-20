Set objExcel = CreateObject("Excel.Application")
Set objWorkbook = objExcel.Workbooks.Open("D:\AD.xlsx")
domain = "novobaby.local"

domainx = "dc=novobaby, dc=local"
'тут надо сделать в цикле поск точки и выделение доменных имен (x1.x2.x3.....xN ==>> dc=x1, dc=x2, dc=x3 ... dc= xN)

iRow = 1
iRowEnd = 999
list = ""

Set objDomain = GetObject("LDAP://"&domainx)

Do Until ( (objExcel.Cells(iRow,1).Value = "") OR (iRow > iRowEnd) )

  FullName = trim(objExcel.Cells(iRow, 1).Value)

  ispace = inStr(1, FullName, " ")
  if ispace = 0 then 
    usr_acname = FullName
    usr_surname = FullName
    usr_name = FullName
    usr_patronymic = ""
  else  
    usr_surname = trim( mid(FullName, 1, ispace-1) )
    temp = trim(mid(FullName, ispace+1, len(FullName)-ispace))
    ispace = inStr(1, temp, " ")
    if ispace = o then
      usr_name = trim(temp)
      usr_patronymic = ""
      usr_acname = usr_surname&" "&usr_name
      Fullname = usr_acname
    else
      usr_name = mid(temp, 1, ispace-1)
      usr_patronymic = trim(mid(temp, ispace+1, len(temp)-ispace))
      usr_acname = usr_surname&" "&mid(usr_name, 1, 1)&mid(usr_patronymic, 1, 1)
      FullName = usr_surname&" "&usr_name&" "&usr_patronymic
    end if
  End if

  Set objConnection = CreateObject("ADODB.Connection")
  objConnection.Open "Provider=ADsDSOObject;"
  Set objCommand = CreateObject("ADODB.Command")
  objCommand.ActiveConnection = objConnection
  objCommand.CommandText = "<LDAP://"&domainx&">;(&(objectCategory=User)(samAccountName="&usr_acname&"));samAccountName;subtree"
  Set objRecordSet = objCommand.Execute 

  if objRecordSet.RecordCount = 0 then
  'если учетка не найдена
    Set objUser = objDomain.Create("user", "CN="&usr_acname) 
    With objUser
      .sAMAccountName = usr_acname
      .UserPrincipalName = usr_acname&"@"&domain
      .SetInfo

      usr_pwd = trim(objExcel.Cells(iRow, 3))
      if len(usr_pwd) < 7 then 
        usr_pwd = trim(Int((9876543-1234567)*Rnd+1234567))
        objExcel.Cells(iRow, 3) = usr_pwd    
      end if
          
      .SetPassword usr_pwd

      .FirstName = usr_name&" "&usr_patronymic
      .FullName = FullName
      .LastName = usr_surname
      .Description = trim(objExcel.Cells(iRow, 5).Value)

      if trim(objExcel.Cells(iRow, 6)) = "декрет" then
        .AccountDisabled = TRUE 
      else 
        .AccountDisabled = FALSE
        usr_phone = trim(objExcel.Cells(iRow, 2).Value)
        usr_email = trim(objExcel.Cells(iRow, 4).Value)
        if (usr_phone = "") or (usr_email = "") then
          objExcel.Cells(iRow, 6) = trim(objExcel.Cells(iRow, 6))&" Error"
        else
          .telephoneNumber = usr_phone
          .EmailAddress = usr_email
        end if
      End if
      .SetInfo
    End With

    list = list&usr_acname&vbCrLF

  end if

  iRow = iRow + 1

Loop

objWorkbook.Save
objWorkbook.Close
objExcel.Quit

if list = "" then 
  Wscript.Echo "Не добавлено ни одного нового пользователя"
else 
  Wscript.Echo "Добавлены пользователи:"&vbCrLF&list
end if

