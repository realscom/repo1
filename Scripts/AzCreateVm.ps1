<#
.SYNOPSIS
Creates a VM in Azure.

.DESCRIPTION
Make sure you use correct params. Networking needs to be setup in the resource group.

.PARAMETER VmName
This is the server name.

.PARAMETER OS
Options: 2019-Datacenter, 2016-Datacenter, 2012-R2-Datacenter, 2012-Datacenter

.PARAMETER ResGroup
Usually "Milic_RG1", not case=sensitive.

.PARAMETER PrivateIpAddress
DC1 is 10.0.0.20 so start at 10.0.0.21.

.INPUTS

.OUTPUTS

.NOTES

.EXAMPLE
.\AzCreateVm.ps1 -VmName S12 -OS "2012-R2-Datacenter" -ResGroup "Milic_rg1" -PrivateIpAddress 10.0.0.21

.EXAMPLE
.\AzCreateVm.ps1 -VmName S12 -OS "2016-Datacenter" -ResGroup "Milic_rg1" -PrivateIpAddress 10.0.0.22 

.LINK
These helped me:

https://docs.microsoft.com/en-us/powershell/module/Az.Compute/New-AzVM?view=azps-3.4.0
https://ilovepowershell.com/2019/10/30/every-step-you-need-to-create-an-azure-virtual-machine-with-powershell/
http://www.bradleyschacht.com/create-new-azure-vm-with-powershell/
#>

Param ([string]$VmName,[string]$OS,[string]$ResGroup,[string]$PrivateIpAddress)
$ErrorActionPreference = "Stop"
Write-Host -ForegroundColor Yellow "=========== WARNING !!! ==========="
Write-Host
Write-Host -ForegroundColor Yellow "This will create the following VM:`n`nVmName: $VmName`nOS: $OS`nResource Group: $ResGroup`nPrivateIpAddress: $PrivateIpAddress"
Write-Host
pause
Write-Host

# Setup parameters
Write-Host -ForegroundColor Yellow "1. Setup parameters"
$VMLocalAdminUser = "ant"
$VMLocalAdminPassword = "P@sswordP@ssword"
$VMLocalAdminSecurePassword = ConvertTo-SecureString $VMLocalAdminPassword -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword); 
#$VmName = "S12" # <--YOUR VALUE-->
#$OS = "2012-R2-Datacenter" # <--YOUR VALUE-->
<#
2019-Datacenter
2016-Datacenter
2012-R2-Datacenter
2012-Datacenter
More here https://docs.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage
#>
$TimeZone = "AUS Eastern Standard Time"
$VMSize = "Standard_B2s"
#$PrivateIpAddress = "10.0.0.21" # <--YOUR VALUE-->
$DnsServer = "10.0.0.20" # <--YOUR VALUE-->
#old $ResGroup = "Milic_RG1"

# Create VM Configuration Object
Write-Host -ForegroundColor Yellow "2. Create VM Configuration Object"
$VMSettings = New-AzVMConfig -VMName $VmName -VMSize $VMSize
Set-AzVMOperatingSystem -VM $VMSettings -Windows -ComputerName $VmName -Credential $Credential -TimeZone $TimeZone

# Bind to resource group
Write-Host -ForegroundColor Yellow "3. Bind to resource group"
$ResGroupName = Get-AzResourceGroup -Name $ResGroup

<# Add OS image

#>
Write-Host -ForegroundColor Yellow "4. Add OS image"
$VMSettings = Set-AzVMSourceImage -VM $VMSettings -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus $OS -Version "latest"

# Add OS disk
Write-Host -ForegroundColor Yellow "5. Add OS disk"
Set-AzVMOSDisk -VM $vmSettings -Name "$VmName-OsDisk" -Windows -CreateOption FromImage

# Add network bits
Write-Host -ForegroundColor Yellow "6. Add network bits"
$Nsg = Get-AzNetworkSecurityGroup -Name "DC1-nsg"
$Vnet = $ResGroupName | Get-AzVirtualNetwork -Name "$ResGroup-vnet"
$Sub = $Vnet.Subnets[0]
$NIC = $ResGroupName | New-AzNetworkInterface -Name "$VmName-Nic" -SubnetId $Sub.Id -NetworkSecurityGroupId $Nsg.Id -PrivateIpAddress $PrivateIpAddress -DnsServer $DnsServer
Add-AzVMNetworkInterface -VM $VMSettings -Id $NIC.Id
 
# Build VM
Write-Host -ForegroundColor Yellow "7. Build VM"
Write-Host
$ResGroupName | New-AzVm -VM $VMSettings

