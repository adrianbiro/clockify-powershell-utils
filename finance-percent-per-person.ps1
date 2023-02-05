#https://clockify.me/developers-api
#https://clockify.me/developers-api#tag-Workspace
#https://clockify.me/developers-api#tag-Reports
param(
    [string] $Start,
    [string] $End,
    [string] $Token
)
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
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
$jsonstring = @{
    "dateRangeStart" = $Start + 'T00:00:00.000Z'
    "dateRangeEnd"   = $End + 'T23:59:59.000Z'
    "summaryFilter"  = @{ "groups" = @( "USER", "PROJECT") }
    "exportType"     = "CSV"
} | ConvertTo-Json

function main {
    $pathToReports = "finance"
    Remove-Item -Recurse -Force -ErrorAction "SilentlyContinue" -Path $pathToReports | Out-Null 
    mkdir $pathToReports -ErrorAction "SilentlyContinue" | Out-Null
    foreach ($ws in $wpId.GetEnumerator()) {
        $reportPath = Join-Path -Path $pathToReports -ChildPath ("{0} {1}_{2}.csv" -f $ws.Name, $Start, $End)
        if (-not (Get-Content $reportPath -ErrorAction "SilentlyContinue").Count) { 
            '"User","Project","Time (h)","Time (decimal)","Percent"'
          | Add-Content -Encoding utf8BOM -Path $reportPath 
        }
        $out = (curl -X POST -s -H "X-Api-Key: $token" -H "Content-Type: application/json" `
                "https://reports.api.clockify.me/v1/workspaces/$($ws.Value)/reports/summary" -d $jsonstring)
        #$out | Add-Content -Encoding utf8BOM -Path $reportPath
        [hashtable] $sum = @{}
        $out | ConvertFrom-Csv | Foreach-Object {
            [double] $num = $_."Time (decimal)"
            if ($sum[$_.User]) {
                $sum[$_.User] += $num
            }
            else {
                $sum[$_.User] = $num
            }
        }
        $out | ConvertFrom-Csv | Foreach-Object {
            "`"{0}`",`"{1}`",`"{2}`",`"{3}`",`"{4}`"" `
                -f $_.User, $_.Project, $_."Time (h)", $_."Time (decimal)", $(($_."Time (decimal)" / $sum[$_.User]) * 100) | Add-Content -Encoding utf8BOM -Path $reportPath  
        }

    }
    
}
main