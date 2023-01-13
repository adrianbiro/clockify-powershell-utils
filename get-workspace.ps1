#https://clockify.me/developers-api
#https://clockify.me/developers-api#tag-Workspace
#https://clockify.me/developers-api#tag-Reports
$token = Get-Content .config
$workspacesJson = curl -s -H "X-Api-Key: $token" https://api.clockify.me/api/v1/workspaces
$workspaces = ($workspacesJson | ConvertFrom-Json).ID
$a = foreach ($ws in $workspaces) {
  #curl -X POST -s -H "X-Api-Key: $token" 'https://api.clockify.me/api/v1/workspaces/$ws/projects' -d  #"
  #{
  #    `"name`": `"$name`",
  #    `"isPublic`": `"false`"
  #}
  #"

  $jsonstring = '
{"dateRangeStart": "2023-01-10T00:00:00.000Z",
  "dateRangeEnd": "2023-01-13T00:00:00.000Z",
  "detailedFilter": {
    "page": 1,
    "pageSize": 50}
}
'
  curl -X POST -s -H "X-Api-Key: $token" -H "Content-Type: application/json" "https://reports.api.clockify.me/v1/workspaces/$ws/reports/detailed" -d $jsonstring

}
$a