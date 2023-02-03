#https://clockify.me/developers-api
#https://clockify.me/developers-api#tag-Workspace
#https://clockify.me/developers-api#tag-Reports
param(
    [string] $Start,
    [string] $End,
    [string] $Token
)
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
if ((-not $Start) -or (-not $End)) {
    "Usage:`n`t{0}  -Start '2023-01-01' -End '2023-01-15'" -f $MyInvocation.MyCommand.Name
    exit 1
}
if ((-not $Token) -and (Test-Path -Path ".config")) {
    $Token = Get-Content -Path ".config"
}
else {
    "Specify token with -Token 'token_string'"
    exit 1
}
$workspacesJson = curl -s -H "X-Api-Key: $Token" "https://api.clockify.me/api/v1/workspaces"
$wpId = @{}; foreach ($i in ($workspacesJson | ConvertFrom-Json)) { $wpId[$i.Name] = $i.ID }
$jsonstring = @{
    "dateRangeStart" = $Start + 'T00:00:00.000Z'
    "dateRangeEnd"   = $End + 'T23:59:59.000Z'
    "summaryFilter"  = @{ "groups" = @( "USER", "PROJECT") }
    "exportType"     = "CSV"
} | ConvertTo-Json

function main {
    $pathToReports = "finance"
    Remove-Item -Recurse -Force -ErrorAction "SilentlyContinue" -Path $pathToReports | Out-Null 
    mkdir $pathToReports -ErrorAction "SilentlyContinue" | Out-Null
    foreach ($ws in $wpId.GetEnumerator()) {
        $reportPath = Join-Path -Path $pathToReports -ChildPath ("{0} {1}_{2}.csv" -f $ws.Name, $Start, $End) 
        curl -X POST -s -H "X-Api-Key: $token" -H "Content-Type: application/json" "https://reports.api.clockify.me/v1/workspaces/$ws/reports/summary" -d $jsonstring 
        }
    
}
main