function Set-2012R2IPAddress {
#2012R2 
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$ServerName,
	
   [Parameter(Mandatory=$True)]
   [string]$filePath
)
# Here's what you do:
# Qry interfacealiases from $Server
invoke-command $Servername {New-NetIPAddress –InterfaceAlias “vEthernet (VS02-Internal)” –IPAddress “10.1.1.25” –PrefixLength 24}


}

#2016
#invoke-command hv05 {New-NetIPAddress –InterfaceAlias “vEthernet (VS02-Internal)” –IPv4Address “10.1.1.27” –PrefixLength 24 -whatif}
#Lots of things to add here. Can you use menus in functions? I don't think so...