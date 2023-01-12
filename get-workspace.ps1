#https://clockify.me/developers-api
#https://clockify.me/developers-api#tag-Workspace
#https://clockify.me/developers-api#tag-Reports
$token = Get-Content .config
$workspacesJson = curl -s -H "X-Api-Key: $token" https://api.clockify.me/api/v1/workspaces
$workspaces = ($workspacesJson | ConvertFrom-Json).ID

foreach($ws in $workspaces){
        #curl -X POST -s -H "X-Api-Key: $token" 'https://api.clockify.me/api/v1/workspaces/$ws/projects' -d  #"
#{
#    `"name`": `"$name`",
#    `"isPublic`": `"false`"
#}
#"
curl -X POST -s -H "X-Api-Key: $token" -H "Content-Type: application/json" "https://reports.api.clockify.me/v1/workspaces/$ws/reports/summary" -d '
{
    "dateRangeStart": "2023-01-10",
    "dateRangeEnd": "2023-01-11",
    "summaryFilter": {
    "groups": [
      "USER",
      "PROJECT",
      "TIMEENTRY"
    ]
}
'

}
