param(
    #[Parameter(Mandatory = $true)]
    [string] $Start,
    #[Parameter(Mandatory = $true)]
    [string] $End
)
# set last week as default
if ((-not $Start) -and (-not $End)) {
    $days = @{ "Monday" = 0
        "Tuesday"       = 1
        "Wednesday"     = 2 
        "Thursday"      = 3
        "Friday"        = 4
        "Saturday"      = 5 
        "Sunday"        = 6
    }
    $DaysFromMonday = $days["$((get-date).DayOfWeek)"]
    $MondayLastWeek = (get-date).AddDays( - (7 + $DaysFromMonday)) 
    $SundayLastWeek = $MondayLastWeek.AddDays(6) #-Format 'YYYY-mm-DD'
    $Start = get-date -Date ($MondayLastWeek) -Format 'yyyy-MM-dd'
    $End = get-date -Date ($SundayLastWeek) -Format 'yyyy-MM-dd'
}
else {
    "Usage:`n`t{0}  -Start '2023-01-01' -End '2023-01-15'" -f $MyInvocation.MyCommand.Name
    exit 1
}

.\run-detailed-report-for-all-projects.ps1 -Start $Start -End $End | Out-Null
.\run-summary-of-all-workspaces.ps1 -Start $Start -End $End | Out-Null

$pathToReports = [IO.Path]::Combine($HOME, "Downloads", ("Clockify {0}_{1}" -f $Start, $End))
Remove-Item -Recurse -Force -ErrorAction "SilentlyContinue" -Path $pathToReports | Out-Null  
mkdir $pathToReports -ErrorAction "SilentlyContinue" | Out-Null
Copy-Item -Path (Join-Path -Path "projectreports" -ChildPath ("{0}_{1}.xlsx" -f $Start, $End)) `
    -Destination (Join-Path -Path $pathToReports -ChildPath ("Projects Detailed {0}_{1}.xlsx" -f $Start, $End))
Copy-Item -Path (Join-Path -Path "reports" -ChildPath ("{0}_{1}.xlsx" -f $Start, $End)) `
    -Destination (Join-Path -Path $pathToReports -ChildPath ("Summary {0}_{1}.xlsx" -f $Start, $End))

Write-Host ("Reports are in {0}" -f $pathToReports)

explorer.exe $pathToReports