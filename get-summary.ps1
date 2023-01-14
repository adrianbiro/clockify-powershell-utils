#https://clockify.me/developers-api
#https://clockify.me/developers-api#tag-Workspace
#https://clockify.me/developers-api#tag-Reports
#TODO https://stackoverflow.com/a/62617490 hash tables encoding problem switch to golang on python
$token = Get-Content .config
$workspacesJson = curl -s -H "X-Api-Key: $token" https://api.clockify.me/api/v1/workspaces
$wpId = @{}; foreach ($i in ($workspacesJson | ConvertFrom-Json)) { $wpId[$i.Name] = $i.ID }
function get-reports () {
  param([string] $ws)
  #detailed body $jsonstring = '{"dateRangeStart": "2023-01-10T00:00:00.000Z", "dateRangeEnd": "2023-01-13T00:00:00.000Z", "detailedFilter": { "page": 1, "pageSize": 50} }'
  #curl -X POST -s -H "X-Api-Key: $token" -H "Content-Type: application/json" "https://reports.api.clockify.me/v1/workspaces/$ws/reports/detailed" -d $jsonstring
  #TODO summary body dates from args
  $jsonstring = '{"dateRangeStart": "2023-01-10T00:00:00.000Z", "dateRangeEnd": "2023-01-13T23:59:59.000Z", "summaryFilter": { "groups": [ "PROJECT"]}}'
  return $(curl -X POST -s -H "X-Api-Key: $token" -H "Content-Type: application/json" "https://reports.api.clockify.me/v1/workspaces/$ws/reports/summary" -d $jsonstring)
}
$AllReportsjson = @{}
foreach ($ws in $wpId.GetEnumerator()) { $AllReportsjson[$ws.Name] = get-reports $($ws.Value) }
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
#$sum | ogv #Export-Csv -Path "zmaz.csv"
#TODO report name with date from args for json body request 
$reportPath = ".\summary.csv"
New-Item -Path $reportPath -ErrorAction "SilentlyContinue" | Out-Null
#TODO generuj csv z hash mapy cez custop obj
'"Project","Hours"' | Add-Content -Path $reportPath
foreach ($i in $sum.GetEnumerator()) {
  "`"{0}`",`"{1}`"" -f $i.Name, ([math]::Round(($i.Value / 3600),2)) | Add-Content -Path $reportPath
}

