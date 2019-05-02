################################################################################
# Name            : UrlCheck.ps1
# Description     : Check an url http status code and find a word in the html result
# Compatibility   : Powershell 2.0 & more
# History changes : 2014.08.06 Creation
#
#
# Usage: ./UrlCheck.ps1 http://my-website.com SearchString
# 	example: ./UrlCheck.ps1 https://www.google.fr/ Google
################################################################################

Param(
	[string] $target,
	[string] $SearchString,
)

# --------------------------------------------------------------------------------
# Function name	: IsNullOrEmpty
# Description	: check if a string is null/empty or not
# --------------------------------------------------------------------------------
function IsNullOrEmpty($str) {
	return ([system.string]::IsNullOrEmpty($str))
}

# --------------------------------------------------------------------------------
# Function name	: CheckPage
# Description	: Check an url http status code and find a word in the html result
# --------------------------------------------------------------------------------
function global:CheckPage(
	$url = $( throw 'Url is requiered' ),
	$findWord = $null,
	$tries = 3,			# 3 tries
	$wait = 10,			# 30 seconds
	$timeout = 180		# 3 minutes
) {

	$global:curTry = $tries
	Write-Host "Checking url : $url"
	do {
		Try {
			[System.Net.HttpWebRequest]$webRequest = [System.Net.HttpWebRequest]::Create($url)
			$webRequest.TimeOut = 1000 * $timeout
			$webRequest.ServicePoint.Expect100Continue = $false
			$webRequest.AllowAutoRedirect = $false
			[System.Net.HttpWebResponse] $resp = [System.Net.HttpWebResponse] $webRequest.GetResponse()
			if ($resp.Statuscode -ne 200) {
				$resp.Close()
					throw "Invalid status code $([int]$resp.Statuscode) => $($resp.StatusDescription)"
			}
			$rs = $resp.GetResponseStream()
			[System.IO.StreamReader]$sr = New-Object System.IO.StreamReader -argumentList $rs
			$page = $sr.ReadToEnd()
			$sr.Close()
			$rs.Close()
			if ((IsNullOrEmpty $findWord) -eq $false) {
				if (($page | Select-string $findWord) -eq $null) {
					throw "Word '$findWord' not found in page"
				}
			}
			break
		}
		Catch {
			$global:curTry = $global:curTry - 1
			if ($global:curTry -le 0) {
				Write-Host "    => Failed : $_." -fore Yellow
				throw "Check url failed : $_"
			}
			else {
				Write-Host "    => Failed : $_. Retrying $global:curTry" -fore Yellow
				Start-Sleep -s $wait
			}
		}
	}
	while ($global:curTry -gt 0)
	Write-Host "    => Success"
}

# --------------------------------------------------------------------------------
# Function name	: Main program
# Description	:
# --------------------------------------------------------------------------------

Try {
	CheckPage $target $SearchString
}
Catch {
  Write-Host "An error occured, test aborted : $_" -fore Red
}
