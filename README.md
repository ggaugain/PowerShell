# Collection of PowerShell scripts

## UrlCheck.ps1
check an url http status code and find a word in the html result
* 3 tries
* 30 seconds (try between 2 tests)
* 3 minutes (timeout)

> Usage : .\UrlCheck.ps1 https://my-website.com SearchString

## TelnetPort.ps1
Check if a tcp port is open on a target server.

> Usage : .\TelnetPort.ps1 <address IP or dns> <port_tcp>
