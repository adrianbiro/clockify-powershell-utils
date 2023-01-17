#https://clockify.me/developers-api
#https://clockify.me/developers-api#tag-Workspace
#https://clockify.me/developers-api#tag-Reports
#TODO https://stackoverflow.com/a/62617490 hash tables encoding problem switch to golang on python
param(
  [Parameter(Mandatory = $true)]
  [string] $NewProjectName,
  [Parameter(Mandatory = $true)]
  [string] $ClientName,
  [Parameter(Mandatory = $true)]
  [string] $NameOfWorkspace,
  [string] $Token
)
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
if ($Help) {
  # TODO switch param
  "Usage:`n`t{0}  -NameOfWorkspace 'Bar' -NewProjectName 'Foo' -ClientName 'Lol sro.' " -f $MyInvocation.MyCommand.Name
  exit 0
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

function create-project () {
  param(
    [string] $ws,
    [string] $clientId
  )
  $jsonstring = '{"name": "' + $NewProjectName + '", "isPublic": "false" , "clientId": "' + $clientId + '"}"' #TODO parce id
  curl -X POST -s -H "X-Api-Key: $token" -H "Content-Type: application/json" "https://api.clockify.me/api/v1/workspaces/$ws/projects" -d $jsonstring
}
function main {
  foreach ($ws in $wpId.GetEnumerator()) { 
    if ($ws.Name -eq $NameOfWorkspace) {
      $clientId = curl -s -H "X-Api-Key: $Token" "https://api.clockify.me/api/v1/workspaces/$($ws.Value)/clients" `
        | ConvertFrom-Json | ForEach-Object { if ($_.name -eq $ClientName) { $_.id } }
      create-project -ws $ws.Value -clientId $clientId | Out-Null


    }
  }
  
}
main