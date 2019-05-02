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
function global:Telnet-Port{ 
	Param([string]$srv,[string]$port,$timeout=1000,[switch]$verbose) 
	
	$ErrorActionPreference = "SilentlyContinue" 
	$tcpclient = new-Object system.Net.Sockets.TcpClient 
	$iar = $tcpclient.BeginConnect($srv,$port,$null,$null) 
	$wait = $iar.AsyncWaitHandle.WaitOne($timeout,$false) 
	
	if(!$wait)
	{ 
		$tcpclient.Close() 
		if($verbose){Write-Host "Connection Timeout"} 
		Return $false 
	} 
	else 
	{ 
		$error.Clear() 
		$tcpclient.EndConnect($iar) | out-Null 
		if($error[0]){if($verbose){write-host $error[0]};$failed = $true} 
		$tcpclient.Close() 
	} 
	if($failed){return $false}else{return $true} 
}

# --------------------------------------------------------------------------------
# Function name	: Main program
# --------------------------------------------------------------------------------
Try {
	Telnet-Port $target $TcpPort
}
Catch {
  Write-Host "An error occured, test aborted : $_" -fore Red
}