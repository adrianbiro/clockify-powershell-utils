#https://clockify.me/developers-api
<#
    .SYNOPSIS
      Adds a new project to Clockify workspace.
    .DESCRIPTION
      
    .EXAMPLE
     ./add-Project.ps1 -NameOfWorkspace 'Bar' -NewProjectName 'Foo' -ClientName 'Lol sro.'
    .PARAMETER $NewProjectName
      The name of the new project.
    .PARAMETER $ClientName
      The name of the client.
    .PARAMETER $NameOfWorkspace
      The name of the workspace, for new project.
    .PARAMETER $Token
      Authentification token if there is no .config file.
#>
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
  #TODO parce id
  $jsonstring = @{
    "name"     = $NewProjectName
    "isPublic" = "false"
    "clientId" = $clientId
  } | ConvertTo-Json
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