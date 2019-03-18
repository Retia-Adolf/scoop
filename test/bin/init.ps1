Write-Host "PowerShell: $($PSVersionTable.PSVersion)"

Write-Host "Install dependencies ..."
Install-Module -Repository PSGallery -Scope CurrentUser -Force -Name Pester -SkipPublisherCheck
Install-Module -Repository PSGallery -Scope CurrentUser -Force -Name PSScriptAnalyzer,BuildHelpers

if($env:CI -eq $true) {
    Write-Host "Load 'BuildHelpers' environment variables ..."
    Set-BuildEnvironment -Force
}

$helpersPath = 'C:\projects\helpers'

if(!(Test-Path $helpersPath)) {
    New-Item -ItemType Directory -Path $helpersPath
}

if(!(Test-Path "$helpersPath\lessmsi\lessmsi.exe")) {
    Start-FileDownload 'https://github.com/activescott/lessmsi/releases/download/v1.6.3/lessmsi-v1.6.3.zip' -FileName "$helpersPath\lessmsi.zip"
    7z x "$helpersPath\lessmsi.zip" -o"$helpersPath\lessmsi" -y
}

if(!(Test-Path "$helpersPath\innounp\innounp.exe")) {
    Start-FileDownload 'https://raw.githubusercontent.com/scoopinstaller/binary-mirror/master/innounp/innounp048.rar' -FileName "$helpersPath\innounp.rar"
    7z x "$helpersPath\innounp.rar" -o"$helpersPath\innounp" -y
}

$buildVariables = ( Get-ChildItem -Path 'Env:' ).Where( { $_.Name -match "^(?:BH|CI(?:_|$)|APPVEYOR)" } )
$buildVariables += ( Get-Variable -Name 'CI_*' -Scope 'Script' )
$details = $buildVariables |
    Where-Object -FilterScript { $_.Name -notmatch 'EMAIL' } |
    Sort-Object -Property 'Name' |
    Format-Table -AutoSize -Property 'Name', 'Value' |
    Out-String
Write-Host "CI variables:"
Write-Host $details -ForegroundColor DarkGray
