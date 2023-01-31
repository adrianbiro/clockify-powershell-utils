#https://clockify.me/developers-api
param(
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

function get-projects {
  param([string] $ws)
  $LoginParameters = @{ Uri = 'https://api.clockify.me/api/v1/workspaces/' + $ws + '/projects'
    method                  = 'GET'
    "Headers"               = @{"X-Api-Key" = $Token }
  }
  return ((Invoke-WebRequest @LoginParameters).Content | ConvertFrom-Json).name
}

function main {
  foreach ($ws in $wpId.GetEnumerator()) { 
    if ($ws.Name -eq $NameOfWorkspace) {
      return get-projects -ws $ws.Value 
    }
  }
}
main