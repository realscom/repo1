<#
.SYNOPSIS
Removes a VM in Azure.

.DESCRIPTION
Make sure you use correct params.

.PARAMETER VmName
This is the server name.

.PARAMETER ResGroup
Usually "Milic_RG1", not case=sensitive.

.INPUTS

.OUTPUTS

.NOTES

.EXAMPLE
.\AzRemoveVm.ps1 -VmName S12 -ResGroup "Milic_rg1"

.LINK
These helped me:

https://adamtheautomator.com/remove-azure-virtual-machine-powershell/
https://4sysops.com/archives/delete-an-azure-vm-with-objects-using-powershell/
#>

Param ([string]$VmName,[string]$ResGroupName)
$ErrorActionPreference = "Stop"
Write-Host -ForegroundColor Yellow "=========== WARNING !!! ==========="
Write-Host
Write-Host -ForegroundColor Yellow "This will permanently remove the VM '$VmName' and all it's related objects. This is an unrecoverable operation."
Write-Host
pause
Write-Host

# Get VM
Write-Host -ForegroundColor Yellow "1. Get VM '$VmName'"
$Vm = Get-AzVm –Name $VmName –ResourceGroupName $ResGroupName
$VmName = $Vm.Name
$ResGroupName = $Vm.ResourceGroupName

# Remove boot diagnostics container
Write-Host -ForegroundColor Yellow "2. Remove boot diagnostics container"
$VmLower = $Vm.Name.ToLower()
$VmId = $Vm.vmid
$StorageAcc = "milicrg1diag"
$StorageCont = "bootdiagnostics-$VmLower-$VmId"
Get-AzStorageAccount -ResourceGroupName $ResGroupName -Name $StorageAcc | Get-AzStorageContainer -Name $StorageCont | Remove-AzStorageContainer -Force

# Remove VM
Write-Host -ForegroundColor Yellow "3. Remove VM"
$Vm | Remove-AzVM -Force

# Remove Nic and public IPs
Write-Host -ForegroundColor Yellow "4. Remove Nic and public IPs"
ForEach($NicId In $Vm.NetworkProfile.NetworkInterfaces.Id)
{
 $Nic = Get-AzNetworkInterface -ResourceGroupName $Vm.ResourceGroupName -Name $NicId.Split('/')[-1]
 Remove-AzNetworkInterface -Name $Nic.Name -ResourceGroupName $Vm.ResourceGroupName -Force
 ForEach($ipConfig In $Nic.IpConfigurations)
   {
    If($ipConfig.PublicIpAddress -ne $null)
     {
      Remove-AzPublicIpAddress -ResourceGroupName $Vm.ResourceGroupName -Name $ipConfig.PublicIpAddress.Id.Split('/')[-1] -Force
     }
   }
}

# Remove network security group
<#Write-Host -ForegroundColor Yellow "5. Remove network security group"
$Nsg= "DC1-nsg"
Get-AzNetworkSecurityGroup -ResourceGroupName $ResGroupName -Name $Nsg | Remove-AzNetworkSecurityGroup -Force
#>
# Remove OS disk
Write-Host -ForegroundColor Yellow "6. Remove OS disk"
$OsDisk = $Vm.StorageProfile.OsDisk.Name
Get-AzDisk -ResourceGroupName $ResGroupName -DiskName $OsDisk | Remove-AzDisk -Force

# Remove data disks
Write-Host -ForegroundColor Yellow "7. Remove data disks"
If ($Vm.StorageProfile.DataDisks.Count -gt 0)
{
ForEach ($DataDisk In $Vm.StorageProfile.DataDisks)
{
Write-Host -ForegroundColor Yellow "`t Detach data disk:" $DataDisk.Name
Remove-AzVMDataDisk -VM $Vm -Name $DataDisk.Name
Update-AzVM -ResourceGroupName $ResGroupName -VM $Vm
Write-Host -ForegroundColor Yellow "`t Delete data disk:" $DataDisk.Name
Get-AzDisk -ResourceGroupName $ResGroupName -DiskName $DataDisk.Name | Remove-AzDisk -Force
}
}
Write-Host
Write-Host -ForegroundColor Yellow "Done"
