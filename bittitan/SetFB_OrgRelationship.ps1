<#

.SYNOPSIS

88888888ba   88      888888888888  88                                            88                                
88      "8b  ""    ,d     88       ""    ,d                                      88                                
88      ,8P        88     88             88                                      88                                
88aaaaaa8P'  88  MM88MMM  88       88  MM88MMM  ,adPPYYba,  8b,dPPYba,           88  8b,dPPYba,    ,adPPYba,       
88""""""8b,  88    88     88       88    88     ""     `Y8  88P'   `"8a          88  88P'   `"8a  a8"     ""       
88      `8b  88    88     88       88    88     ,adPPPPP88  88       88          88  88       88  8b               
88      a8P  88    88,    88       88    88,    88,    ,88  88       88  "88     88  88       88  "8a,   ,aa  888  
88888888P"   88    "Y888  88       88    "Y888  `"8bbdP"Y8  88       88  d8'     88  88       88   `"Ybbd8"'  888  
                                                                        8"                                         
© Copyright 2016 BitTitan, Inc. All Rights Reserved.

.DESCRIPTION
    This PowerShell Script is part of the process to enable Free/Busy Coexistance between G-Suite and Office 365
.NOTES
    Version		1.3
	Author			Alberto Nunes
	Date			08/Dec/2016
	Disclaimer: This script is provided ‘AS IS’. No warrantee is provided either expresses or implied.
	Change Log
		1.0: Initial release
		1.1: Error handling improvement
		1.2: Adding support to Exchange On-Premises
		1.3: Add disclaimer
#>

Param
(
	[Parameter(Position=0,Mandatory = $true)][ValidateSet('OnPremises','O365')][String]$TargetEnvironment,
	[Parameter(Mandatory = $true)][String]$AccessToken,
	[Parameter(Mandatory = $true)][String]$AdminUser,
	[Parameter(Mandatory = $true)][String]$ExternalDomains,
	[Parameter(Mandatory = $true)][String]$RelationshipName
)

$targetAutodiscoverEpr = "https://coexistence.bittitan.com/ews/exchange.asmx/"

# Ask for credentials. If the user hits Cancel or Esc the script will end immediately
try
{
	$tenantCredential = Get-Credential -Credential $adminUser
}
catch
{
	Write-Host "`nESC or CANCEL button pressed. Script aborted`n"
	Exit
}

# Create PSSession
write-host "`nTrying to connect to Exchange $TargetEnvironment Remote PowerShell... `n"

if( $TargetEnvironment -eq "OnPremises")
{
	# Check if this Exchange PowerShell Module is loaded
	if( -not (Get-Command Get-ExchangeServer -ErrorAction SilentlyContinue) )
	{
		Write-Host "Script aborted. When you chose OnPremises, the script should run on an Exchange Server"
		Exit
	}
}
else
{
	try
	{
		$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $tenantCredential -Authentication Basic -AllowRedirection
		Import-PSSession $session
	}
	catch
	{
		$msg = "ERROR: Failed to open a new PS Session to Office 365 with the error `n Details: $($Error[0].Exception.Message) `n Script aborted"
		write-host $msg -ForegroundColor Red
		Remove-PSSession -Session $session
		Exit
	}
	
	# Validate is OrganizationCustomization was already enabled
	try
	{
		if( ((Get-OrganizationConfig).Isdehydrated) )
		{
			$execute = Enable-OrganizationCustomization
		}
	}
	catch
	{
		$msg = "ERROR: Execute 'Enable-OrganizationCustomization' failed with the error `n Details: $($Error[0].Exception.Message) `n Script aborted"
		write-host $msg -ForegroundColor Red
		Remove-PSSession -Session $session
		Exit
	}
}

$orgRelation = Get-OrganizationRelationship
$orgRelationshipExists = $false
$msg = $null
#Split the list of domains into an array
$domainsList = $externalDomains.Split(", ")

# Validate if a Org Relationship with the specified name already exists
foreach ( $relation in $orgRelation )
{
	if( $relation.Name -eq $relationshipName )
	{
		$orgRelationshipExists = $true
	}
	else
	{
		# Validate if any domain is already in use on another Organization Relationship
		foreach ( $domain in $relation.domainNames )
		{
			for ( $count = 0; $count -le ($domainsList).count; $count++ )
			{
				if( $domain -eq $domainsList[$count] )
				{
					$msg += "`nThe Organization Relationship '$($Relation.Name)' already have the domain '$($domainsList[$count])' configured.`n"
				}
			}
		}
	}
}

# If the domains specified are already in use, thec script will abort	
if( $msg -ne $NULL )
{
	$msg += "One or more of the Domains required to create the Organization Relationship are already in use.`n
	Please validate your configuration and remove the domains above from that Relationships and re-run this script"
	write-host $msg -ForegroundColor Red
	Remove-PSSession $session
	Exit
}

if( $orgRelationshipExists )
{
	$msg = "WARNING: Organization Relationship with the name '$relationshipName' already exists. `n"
	write-host $msg -ForegroundColor Yellow
	write-host "Press any key to continue or ESC to abort and review the options entered" -ForegroundColor Magenta
	$keyPressed = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	if( $keyPressed.VirtualKeyCode -eq 27 )
	{
		#Remove PS-Session and aborting script# End the current session
		Write-Host "ESC key Pressed. Aborting Script"
		Remove-PSSession $session
		Exit
	}
	else 
	{
		write-host "Required changes will be applied to the existing Organization Relationship '$relationshipName'"
		try
		{
			Remove-OrganizationRelationship -Identity $relationshipName -Confirm:$false
		}
		catch
		{
			$msg = "Error removing the Organization relationship. `n Details: $($Error[0].Exception.Message) `n"
			Write-Host $msg -ForegroundColor Red
			Remove-PSSession $session
			Exit
		}
	}
}	
Write-Host "Creating On premises Organization Relationship '$relationshipName'" -ForegroundColor DarkGreen
try
{
	# Create a new relationship with the tenant
	New-OrganizationRelationship -Name $relationshipName -DomainNames $domainsList -FreeBusyAccessEnabled $true -FreeBusyAccessLevel LimitedDetails `
		-TargetApplicationUri "outlook.com" -TargetSharingEpr "${TargetAutodiscoverEpr}${accessToken}"
}
catch
{
	$msg = "ERROR: There was an error creating the Organization relationship. `n Details: $($Error[0].Exception.Message) `n"
	write-host $msg -ForegroundColor Red
}

# End the current session
Remove-PSSession $session
