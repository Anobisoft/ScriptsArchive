sljdfhksjdfhkaljhflaksjd
'Вообще здесь предупреждение надо сделать а пока будет так чтобы случайно не запустили
Set objExcel = CreateObject("Excel.Application")
Set objWorkbook = objExcel.Workbooks.Open("D:\AD.xlsx")
domain = "dc=novobaby, dc=local"
iRow = 2

Do Until objExcel.Cells(iRow,1).Value = ""

FullName = trim(objExcel.Cells(iRow, 1).Value)

ispace = inStr(1, FullName, " ")
usr_surname = trim(mid(FullName, 1, ispace-1))

temp = trim(mid(FullName, ispace+1, len(FullName)-ispace))
ispace = inStr(1, temp, " ")
usr_name = mid(temp, 1, ispace-1)
usr_fname = trim(mid(temp, ispace+1, len(temp)-ispace))
usr_acname = usr_surname&" "&mid(usr_name, 1, 1)&mid(usr_fname, 1, 1)

Set objUser = GetObject("LDAP://cn="&usr_acname&","&domain ) 
    usr_pwd = trim(Int((9876543-1234567)*Rnd+1234567))
' секретная комента от вредителей
'    objUser.SetPassword usr_pwd
'    objExcel.Cells(iRow, 3) = usr_pwd
    iRow = iRow + 1
Loop

objWorkbook.Save
objWorkbook.Close
objExcel.Quit
Wscript.Echo "Complete"
