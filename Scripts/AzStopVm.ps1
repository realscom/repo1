# Connect-AzAccount
# Get-AzSubscription -SubscriptionId f88597aa-8733-4ad5-a0f6-4550e56fa21b | Set-AzContext
$VM="A19","G19","M19","S19","DC1"
$Count=1
$VM | ForEach-Object {
    Write-Host -ForegroundColor Yellow "$Count/5 Stopping $_"
    Stop-AzVM -Name $_ -ResourceGroupName "Milic_RG1" -Force
    if ($Count -ne 5) {
        Start-Sleep 30
       }
       $Count+=1
}

