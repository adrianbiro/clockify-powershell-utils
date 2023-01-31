#https://clockify.me/developers-api
<#
    .SYNOPSIS
      Adds a new project to Clockify workspace.
    .DESCRIPTION
      
    .EXAMPLE
      .\change-client-name-in-all-ws.ps1 -NewClientName 'Office&Facility Management' -ClientName 'Office Management' 
    .PARAMETER $NewClientName
      The new name.
    .PARAMETER $ClientName
      The name of the client.
    .PARAMETER $Token
      Authentification token if there is no .config file.
#>
param(
  [Parameter(Mandatory = $true)]
  [string] $NewClientName,
  [Parameter(Mandatory = $true)]
  [string] $ClientName,
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

function update-client-name () {
  param(
    [string] $ws,
    [string] $clientId,
    [string] $NewClientName
  )
  $jsonstring = @{
    "name" = $NewClientName
  } | ConvertTo-Json
  curl -X PUT -s -H "X-Api-Key: $token" -H "Content-Type: application/json" "https://api.clockify.me/api/v1/workspaces/$ws/clients/$clientId" -d $jsonstring
}
function main {
  foreach ($ws in $wpId.GetEnumerator()) { 
    $clientId = curl -s -H "X-Api-Key: $Token" "https://api.clockify.me/api/v1/workspaces/$($ws.Value)/clients" `
    | ConvertFrom-Json | ForEach-Object { if ($_.name -eq $ClientName) { $_.id } }
    update-client-name -ws $ws.Value -clientId $clientId -NewClientName $NewClientName | Out-Null
  }
}
main