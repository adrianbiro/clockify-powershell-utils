#https://clockify.me/developers-api
#https://clockify.me/developers-api#tag-Workspace
#https://clockify.me/developers-api#tag-Reports
#TODO https://stackoverflow.com/a/62617490 hash tables encoding problem switch to golang on python
param(
  [string] $Start,
  [string] $End,
  [string] $Token
)
if((-not $Start) -or (-not $End)){
  "Usage:`n`t{0}  -Start '2023-01-01' -End '2023-01-15'" -f $MyInvocation.MyCommand.Name
  exit 1
}
if ((-not $Token) -and (Test-Path -Path ".config")){
  $Token = Get-Content -Path ".config"
} else {
  "Specify token with -Token 'token_string'"
  exit 1
}
$workspacesJson = curl -s -H "X-Api-Key: $Token" "https://api.clockify.me/api/v1/workspaces"
$wpId = @{}; foreach ($i in ($workspacesJson | ConvertFrom-Json)) { $wpId[$i.Name] = $i.ID }
$jsonstring = '{"dateRangeStart": "' + $Start + 'T00:00:00.000Z", "dateRangeEnd": "' + $End + 'T23:59:59.000Z", "summaryFilter": { "groups": [ "PROJECT"]}}'

function get-report () {
  param([string] $ws)
  return $(curl -X POST -s -H "X-Api-Key: $token" -H "Content-Type: application/json" "https://reports.api.clockify.me/v1/workspaces/$ws/reports/summary" -d $jsonstring)
}
$AllReportsjson = @{}
foreach ($ws in $wpId.GetEnumerator()) { $AllReportsjson[$ws.Name] = get-report -ws $($ws.Value) }
$sum = @{} 
foreach ($i in $AllReportsjson.GetEnumerator()) {
  ($i.Value | ConvertFrom-Json).groupOne | Foreach-Object {
    [double] $num = $_.Duration
    if ($_.Name -eq $null) { continue }#$_.Name = "No Project Selected"}  # TODO catch all values from project whitout name
    if ($sum[$_.Name]) {
      $sum[$_.Name] += $num
    }
    else {
      $sum[$_.Name] = $num
    }
  } 
}
$reportPath = ".\JSONsummary{0}_{1}.csv" -f $Start, $End
if (Test-Path $reportPath){
  Remove-Item -Force -Path $reportPath
}
New-Item -Force -Path $reportPath -ErrorAction "SilentlyContinue" | Out-Null
#TODO make csv from hash map with custom obj. Like this `$sum | Export-Csv -Path "zmaz.csv"` but with inverted lines to columns
'"Project","Hours"' | Add-Content -Path $reportPath
foreach ($i in $sum.GetEnumerator()) {
  "`"{0}`",`"{1}`"" -f $i.Name, ([math]::Round(($i.Value / 3600), 2)) | Add-Content -Path $reportPath
}

