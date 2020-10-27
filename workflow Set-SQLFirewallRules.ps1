<#
.SYNOPSIS 
    Sets up a connection to an Azure Virtual Machine using Connect-AzureVM and configures the Firewall to allow SQL Traffic

.DESCRIPTION
    This runbook sets up a connection to an Azure virtual machine. It requires the Connect-AzureVM to be published
    It will then configure the Virtual Machines Firewall to allow SQL Traffic  

.PARAMETER AutomationCredential,
    The name of the Azure Automation Credential Asset.
    This should be created using 
    http://azure.microsoft.com/blog/2014/08/27/azure-automation-authenticating-to-azure-using-azure-active-directory/  
 
.PARAMETER LocalAdminCredential,
    The name of the Azure Automation Local Admin Credential Asset.

.PARAMETER AzureSubscriptionName,
    The Name of the Azure Subscription

.PARAMETER AVMName,
    The Name of the VM

.PARAMETER AServiceName,
    The Name of the Service

.PARAMETER All,
    This Parameter will run all of the firewall rules if set to true and will override all other choices

.PARAMETER Port1433SQL,
    Only enables Port1433 for SQL

.PARAMETER Port1434DAC,
    Only enables Port1434 Dedicated Admin Connection

.PARAMETER Port4022Broker,
    Only enables Port4022 for SQL Service Broker

.PARAMETER Port135RPC,
    Only enables Port135 for SQL Debugger/RPC

.PARAMETER Port2383SSAS,
    Only enables Port2383 for Analysis Services

.PARAMETER Port2382Browser,
    Only enables Port2382 for SQL Server Browser Service

.PARAMETER Port80HTTP,
    Only enables Port80 for HTTP

.PARAMETER Port443SSL,
    Only enables Port443 for SSL
        
.PARAMETER PUDP1434Browser,
    Only enables Port1434 UDP for SQL Server Browser Service's 'Browse' Button 

.PARAMETER Port5022Mirroring
    Only enables Port5022 for SQL Mirroring
.EXAMPLE
    Set-SQLFirewallRules -AutomationCredential autocred -LocalAdminCredential localadmin cred -AzureSubscriptionName Subname -AVMName VMName -AServiceName ServiceName -All $True

.NOTES
    AUTHOR: Rob Sewell sqldbawithabeard.com
    LASTEDIT: 06/01/2015 
#>
workflow Set-SQLFirewallRules
{
    Param
    (            
        [parameter(Mandatory=$true)]
        [String]$AutomationCredential,
        [parameter(Mandatory=$true)]
        [String]$LocalAdminCredential,
        [parameter(Mandatory=$true)]
        [String]$AzureSubscriptionName,
        [parameter(Mandatory=$true)]
        [String]$AVMName,
        [parameter(Mandatory=$true)]
        [String]$AServiceName,
        [parameter(Mandatory=$true)]
        [boolean]$All,
        [parameter(Mandatory=$false)]
        [boolean]$Port1433SQL,
        [parameter(Mandatory=$false)]
        [boolean]$Port1434DAC,
        [parameter(Mandatory=$false)]
        [boolean]$Port4022Broker,
        [parameter(Mandatory=$false)]
        [boolean]$Port135RPC,
        [parameter(Mandatory=$false)]
        [boolean]$Port2383SSAS,
        [parameter(Mandatory=$false)]
        [boolean]$Port2382Browser,
        [parameter(Mandatory=$false)]
        [boolean]$Port80HTTP,
        [parameter(Mandatory=$false)]
        [boolean]$Port443SSL,
        [parameter(Mandatory=$false)]
        [boolean]$PUDP1434Browser,
        [parameter(Mandatory=$false)]
        [boolean]$Port5022Mirroring
        )
    $Cred = Get-AutomationPSCredential -Name $AutomationCredential
    $LocalAdmin = Get-AutomationPSCredential -Name $LocalAdminCredential 
    $AzureSubscriptionName = $AzureSubscriptionName
    # Connect to Azure and Select Azure Subscription
    $AzureAccount = Add-AzureAccount -Credential $Cred
    $AzureSubscription = Select-AzureSubscription -SubscriptionName $AzureSubscriptionName
    $Uri = Connect-AzureVM -AzureSubscriptionName $AzureSubscriptionName -ServiceName $AServiceName -VMName $AVMName -AzureOrgIdCredential $cred
    if($All)
        {
        $Port1433SQL = $True
        $Port1434DAC = $True
        $Port4022Broker = $True
        $Port135RPC = $True
        $Port2383SSAS = $True
        $Port2382Browser = $True
        $Port80HTTP = $True
        $Port443SSL = $True
        $PUDP1434Browser = $True
        $Port5022Mirroring = $True
        }
    $PS = @"
"@
    ## From https://social.technet.microsoft.com/Forums/windowsserver/en-US/fa505145-92eb-403d-9e03-2965e5991a48/forum-faq-open-windows-firewall-ports-for-sql-server-powershell-script?forum=winserverPN

$PS += "Import-Module NetSecurity `n"

if($Port1433SQL)
{
$PS += @"
`n # TCP 1433 "SQLServer"
New-NetFirewallRule -DisplayName "Allow inbound TCP Port 1433 - SQLServer" –Direction inbound –LocalPort 1433 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow outbound TCP Port 1433 - SQLServer" –Direction outbound –LocalPort 1433 -Protocol TCP -Action Allow
"@
}
if($Port1434DAC)
{ $PS += @"
`n #TCP 1434 "Dedicated Admin Connection"
New-NetFirewallRule -DisplayName "Allow inbound TCP Port 1434 - Dedicated Admin Connection" -Direction inbound –LocalPort 1434 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow outbound TCP Port 1434 - Dedicated Admin Connection" -Direction outbound –LocalPort 1434 -Protocol TCP -Action Allow
"@ 
}
if($Port4022Broker)
{ $PS += @"
`n #TCP 4022 "SQL Service Broker"
New-NetFirewallRule -DisplayName "Allow inbound TCP Port 4022 - SQL Service Broker" -Direction inbound –LocalPort 4022 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow outbound TCP Port 4022 - SQL Service Broker" -Direction outbound –LocalPort 4022 -Protocol TCP -Action Allow
"@ 
}
if($Port135RPC)
{ $PS += @"
`n #TCP 135 "SQL Debugger/RPC"
New-NetFirewallRule -DisplayName "Allow inbound TCP Port 135 - SQL Debugger/RPC" -Direction inbound –LocalPort 135 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow outbound TCP Port 135 - SQL Debugger/RPC" -Direction outbound –LocalPort 135 -Protocol TCP -Action Allow
"@
}
if($Port2383SSAS)
{ $PS += @"
`n #TCP 2383 "Analysis Services"
New-NetFirewallRule -DisplayName "Allow inbound TCP Port 2383 - Analysis Services" -Direction inbound –LocalPort 2383 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow outbound TCP Port 2383 - Analysis Services" -Direction outbound –LocalPort 2383 -Protocol TCP -Action Allow
"@
}
if($Port2382Browser)
{ $PS += @"
`n #TCP 2382 "SQL Browser"
New-NetFirewallRule -DisplayName "Allow inbound TCP Port 2382 - SQL Browser" -Direction inbound –LocalPort 2382 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow outbound TCP Port 2382 - SQL Browser" -Direction outbound –LocalPort 2382 -Protocol TCP -Action Allow
"@
}
if($Port80HTTP)
{ $PS += @"
`n #TCP 80 "HTTP"
New-NetFirewallRule -DisplayName "Allow inbound TCP Port 80 - HTTP" -Direction inbound –LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow outbound TCP Port 80 - HTTP" -Direction outbound –LocalPort 80 -Protocol TCP -Action Allow
"@
}
if($Port443SSL)
{ $PS += @"
`n #TCP 443 "SSL"
New-NetFirewallRule -DisplayName "Allow inbound TCP Port 443 - SSL" -Direction inbound –LocalPort 443 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow outbound TCP Port 443 - SSL" -Direction outbound –LocalPort 443 -Protocol TCP -Action Allow
"@
}
if($PUDP1434Browser)
{ $PS += @"
`n #UDP 1434 "SQL Browser"
New-NetFirewallRule -DisplayName "Allow inbound UDP Port 1434 - SQL Browser" -Direction inbound –LocalPort 1434 -Protocol UDP -Action Allow
New-NetFirewallRule -DisplayName "Allow outbound UDP Port 1434 - SQL Browser" -Direction outbound –LocalPort 1434 -Protocol UDP -Action Allow
"@
}
if($Port5022Mirroring)
{ $PS += @"
`n #TCP 5022 "Mirroring"
New-NetFirewallRule -DisplayName “Allow Inbound SQL Server - SQL Mirroring1” -Direction Inbound –Protocol TCP –LocalPort 5022 -Action Allow
New-NetFirewallRule -DisplayName “Allow Outbound SQL Server- SQL Mirroring1” -Direction Outbound –Protocol TCP –LocalPort 5022 -Action Allow
"@
}

	# Run a command on the Azure VM
    $PSCommandResult = InlineScript {        
        Invoke-command -ConnectionUri $Using:Uri -credential $Using:LocalAdmin -ScriptBlock {
            Invoke-Expression $Args[0]
        } -Args $Using:PS

    }
	
	$PSCommandResult
}