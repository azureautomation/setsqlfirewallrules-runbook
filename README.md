Set-SQLFirewallRules Runbook
============================

            


This runbook sets up a connection to an Azure virtual machine.


It requires the [Connect-AzureVM](https://gallery.technet.microsoft.com/scriptcenter/Connect-to-an-Azure-85f0782c) to be published before running


It will then configure the Virtual Machines Firewall to allow SQL Traffic using the choices defined in the parameters.


The All parameter will always overide any further choices but otherwise you can choose one,many or all of the following rules


.PARAMETER Port1433SQL,    Only enables Port1433 for SQL
.PARAMETER Port1434DAC,    Only enables Port1434 Dedicated Admin Connection
.PARAMETER Port4022Broker,    Only enables Port4022 for SQL Service Broker
.PARAMETER Port135RPC,    Only enables Port135 for SQL Debugger/RPC
.PARAMETER Port2383SSAS,    Only enables Port2383 for Analysis Services
.PARAMETER Port2382Browser,    Only enables Port2382 for SQL Server Browser Service
.PARAMETER Port80HTTP,    Only enables Port80 for HTTP
.PARAMETER Port443SSL,    Only enables Port443 for SSL      
.PARAMETER PUDP1434Browser,    Only enables Port1434 UDP for SQL Server Browser Service's 'Browse' Button

.PARAMETER Port5022Mirroring    Only enables Port5022 for SQL Mirroring


 

 

        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
