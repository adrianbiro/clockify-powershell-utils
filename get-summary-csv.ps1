#https://clockify.me/developers-api
#https://clockify.me/developers-api#tag-Workspace
#https://clockify.me/developers-api#tag-Reports
#TODO https://stackoverflow.com/a/62617490 hash tables encoding problem switch to golang on python
param(
  [string] $Start,
  [string] $End,
  [string] $Token
)
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
$jsonstring = '{"dateRangeStart": "' + $Start + 'T00:00:00.000Z", "dateRangeEnd": "' + $End + 'T23:59:59.000Z", "summaryFilter": { "groups": [ "PROJECT"]}, "exportType": "CSV"}'

function get-report () {
  param([string] $ws)
  return $(curl -X POST -s -H "X-Api-Key: $token" -H "Content-Type: application/json" "https://reports.api.clockify.me/v1/workspaces/$ws/reports/summary" -d $jsonstring)
}
function get-hours-from-decimal {
  #Decimal hours = hours + minutes/60 + seconds/3600
  #https://calculatordaily.com/decimal-hours-to-hours-minutes-calculator
  param([double] $num)
  [int] $hours = $num 
  [int] $minutes = [math]::Floor(($num * 60) % 60)  # Floor to make it consistent with Clockify web app
  [int] $seconds = [math]::Floor(($num * 3600) % 60)
  return "{0}:{1}:{2}" -f $hours, $minutes, $seconds
}
function make-report {
  Param([hashtable]$sum,
    [string] $reportName
  )
  mkdir -Path  "reports" -ErrorAction SilentlyContinue | Out-Null
  if (-not $reportName) { $reportName = "summary" }
  $reportPath = Join-Path -Path "reports" -ChildPath (".\{0}{1}_{2}.csv" -f $reportName, $Start, $End)
  if (Test-Path $reportPath) {
    Remove-Item -Force -Path $reportPath
  }
  New-Item -Path $reportPath -ErrorAction "SilentlyContinue" | Out-Null
  '"Project","Hours","Decimal"' | Add-Content -Path $reportPath
  foreach ($i in $sum.GetEnumerator()) {
    "`"{0}`",`"{1}`",`"{2}`"" -f $i.Name, (get-hours-from-decimal -num $i.Value), $i.Value | Add-Content -Path $reportPath
  }
}
function main {
  $AllReports = @{}
  foreach ($ws in $wpId.GetEnumerator()) { $AllReports[$ws.Name] = get-report -ws $($ws.Value) }
  $sum = @{} 
  foreach ($i in $AllReports.GetEnumerator()) {
    $i.Value | ConvertFrom-Csv | Foreach-Object {
      [double] $num = $_."Time (decimal)"
      if ($sum[$_.Project]) {
        $sum[$_.Project] += $num
      }
      else {
        $sum[$_.Project] = $num
      }
    } 
  }

  make-report -sum $sum
  #TODO make separate report for each workspace
}
main