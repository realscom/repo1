Param($Url, $DestPath, $SourcePath, $Token, [Switch]$Help)
If ($Help -eq $true)
{
Write-Host
Write-Host "[DESCRIPTION]"
Write-Host
Write-Host "Allows you to upload a single file from your computer to an Artifactory repo."
Write-Host
Write-Host "[PARAMETERS]"
Write-Host
Write-Host "1. `$Url: Repo Url without slash on the end."
Write-Host "2. `$DestPath: The relative path of the destination file. Add slash at start."
Write-Host "3. `$SourcePath: Full path to source file."
Write-Host "4. `$Token: Access token required to authenticate. There are a few ways to authentice, this is just one."
Write-Host
Write-Host "[EXAMPLE]"
Write-Host
Write-Host "1. Upload C:\Build\File1.txt from your local computer to the folder SCOM/2019 in Artifactory (SCOM is the root folder)."
Write-Host 
Write-Host -ForegroundColor yellow ".\ArtifactoryTestUpload.ps1 -Url https://artifactory.company.com/artifactory/my-repo -DestPath /scom/2019/File1.txt -SourcePath C:\Build\File1.txt -Token AKCp5ekN76KVLtL18cvz2dsi1b"
Write-Host
Break
}
$Start=Get-Date -format "dd/MM/yyyy HH:mm:ss"
Write-Host
Write-Host -ForegroundColor yellow "START: $Start" 
$FullUrlPath=$Url + $DestPath
Try
{
    curl -H "X-JFrog-Art-Api:$Token" -X PUT $FullUrlPath -T $SourcePath -m 3600
}
Catch
{
    Write-Host -ForegroundColor red "Error uploading $($SourcePath) to Artifactory: $($_.Exception.Message)"
}
Write-Host
$Stop=Get-Date -format "dd/MM/yyyy HH:mm:ss"
Write-Host -ForegroundColor yellow "STOP: $Stop" 