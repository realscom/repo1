Connect-AzAccount
Get-AzSubscription -SubscriptionId f88597aa-8733-4ad5-a0f6-4550e56fa21b | Set-AzContext
$VM="DC1","S19","M19","G19","A19"
$Count=1
$VM | ForEach-Object {
    Write-Host -ForegroundColor Yellow "$Count/5 Starting $_"
    Start-AzVM -Name $_ -ResourceGroupName "Milic_RG1"
    if ($Count -ne 5) {
         Start-Sleep 60
        }
        $Count+=1
    }

