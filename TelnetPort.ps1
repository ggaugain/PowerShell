################################################################################
# Name            : TelnetPort.ps1
# Description     : Check if a tcp port is open on a server.
# Compatibility   : Powershell 2.0 & more
# History changes : 2016.04.10 Creation
#
#
# Usage: ./TelnetPort.ps1 <address IP or dns> <port tcp>
# 	example: ./TelnetPort.ps1 192.168.1.50 443
################################################################################

Param(
	[string] $target,
	[string] $TcpPort
)

# --------------------------------------------------------------------------------
# Function name	: Telnet-Port
# --------------------------------------------------------------------------------
function global:Test-Port {
    [CmdletBinding()]
    Param (
        [string] $ComputerName,
        [int] $Port,
        [int] $Delay = 1,
        [int] $Count = 3
    )
    function Test-TcpClient ($IPAddress, $Port) {
        $TcpClient = New-Object Net.Sockets.TcpClient
        Try { $TcpClient.Connect($IPAddress, $Port) } Catch {}
        If ($TcpClient.Connected) { $TcpClient.Close(); Return $True }
        Return $False
    }
    function Invoke-Test ($ComputerName, $Port) {
        Try   { [array]$IPAddress = [System.Net.Dns]::GetHostAddresses($ComputerName) | Select-Object -Expand IPAddressToString } 
        Catch { Return $False }
        [array]$Results = $IPAddress | % { Test-TcpClient -IPAddress $_ -Port $Port }
        If ($Results -contains $True) { Return $True } Else { Return $False }
    }
    for ($i = 1; ((Invoke-Test -ComputerName $ComputerName -Port $Port) -ne $True); $i++)
    {
        if ($i -ge $Count) {
            Write-Warning "Timed out while waiting for port $Port to be open on $ComputerName!"
            Return $false
        }
        Write-Warning "Port $Port not open, retrying..."
        Sleep $Delay
    }
    Return $true
}

# --------------------------------------------------------------------------------
# Function name	: Main program
# --------------------------------------------------------------------------------
Try {
	Test-Port $target $TcpPort
}
Catch {
  Write-Host "An error occured, test aborted : $_" -fore Red
}