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
$pathToReports = "projectreports"
Remove-Item -Recurse -Force -ErrorAction "SilentlyContinue" -Path $pathToReports | Out-Null  
mkdir $pathToReports -ErrorAction "SilentlyContinue" | Out-Null
$workspacesJson = curl -s -H "X-Api-Key: $Token" "https://api.clockify.me/api/v1/workspaces"
$wpId = @{}; foreach ($i in ($workspacesJson | ConvertFrom-Json)) { $wpId[$i.Name] = $i.ID }
$jsonstring = @{
    "dateRangeStart" = $Start + 'T00:00:00.000Z'
    "dateRangeEnd"   = $End + 'T23:59:59.000Z'
    "detailedFilter" = @{
        "page"       = 1
        "pageSize"   = 50
        "exportType" = "JSON"
    }
} | ConvertTo-Json
function get-report () {
    param([string] $ws)
    return $(curl -X POST -s -H "X-Api-Key: $token" -H "Content-Type: application/json" "https://reports.api.clockify.me/v1/workspaces/$ws/reports/detailed" -d $jsonstring)
}

function seconds-to-hours {
    Param([double] $num)
    return $num / 3600
}
function make-report {
    Param(
        [string] $projectName,
        [string] $userName,
        [string] $description,
        $timeInterval
    )
    if (-not $projectName) {$projectName = "No project"}
    $reportPath = (Join-Path -Path $pathToReports -ChildPath ("{0} {1}_{2}.csv" -f $projectName, $Start, $End))
    New-Item -Path $reportPath -ErrorAction "SilentlyContinue" | Out-Null
    # Make header
    if (-not (Get-Content $reportPath -ErrorAction "SilentlyContinue").Count) { 
        '"Name","Description","From","To","Hours","Duration in seconds"'
      | Add-Content -Encoding utf8BOM -Path $reportPath 
    }
  
    "`"{0}`",`"{1}`",`"{2}`",`"{3}`",`"{4}`",`"{5}`"" `
        -f $userName, $description, $timeInterval.start, $timeInterval.end, 
            (seconds-to-hours -num $timeInterval.duration), $timeInterval.duration  | Add-Content -Encoding utf8BOM -Path $reportPath
}
function main {
    foreach ($ws in $wpId.GetEnumerator()) { 
        $allProjectJson = get-report -ws $ws.Value
        #$projectID = @{}; foreach ($i in ($allProjectJson | ConvertFrom-Json)) { $projectID[$i.Name] = $i.ID }
        foreach ($i in ($allProjectJson | ConvertFrom-Json)) {
            $i.timeentries | ForEach-Object {
                make-report -projectName $_.projectName -userName $_.userName `
                    -description $_.description -timeInterval $_.timeInterval
            }
        }
    }
}
main