strComputer = ""
strNewDescription = ""

Set objWMIService = GetObject("winmgmts:\\" & strComputer).InstancesOf("Win32_OperatingSystem")
For Each x In objWMIService
  x.Description = strNewDescription
  x.Put_
Next