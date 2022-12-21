#https://clockify.me/developers-api
#https://clockify.me/developers-api#tag-Workspace
$token = Get-Content .config
$workspacesJson = curl -s -H "X-Api-Key: $token" https://api.clockify.me/api/v1/workspaces
$workspaces = ($workspacesJson | ConvertFrom-Json).ID

$namesOfProjects = Get-Content Aktivni_projekty-update.csv

foreach($ws in $workspaces){
    foreach ($name in $namesOfProjects) {
        "name wp"}
<#
        curl -X POST -s -H "X-Api-Key: $token" 'https://api.clockify.me/api/v1/workspaces/$ws/projects' -d  "
{
    `"name`": `"$name`",
    `"isPublic`": `"false`"
}
"
    }
#>
}