param(
    [string] $Start,
    [string] $End
)
# set last week as default
if (-not $Start -and -not $End) {
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
elseif (-not $Start -or -not $End) {
    "Usage:`n`t{0}  -Start '2023-01-01' -End '2023-01-15'" -f $MyInvocation.MyCommand.Name
    exit 1
}

### Clean old reports.
remove-Item ".\reports\", ".\projectreports\", "IRreports", "finance" -Recurse -Force -ErrorAction "SilentlyContinue" | Out-Null

### Generate reports
# Detailed for each project, persoon, task name etc.
.\detailed-for-project.ps1 -Start $Start -End $End | Out-Null
# this one must go firts
.\all-summary-csv.ps1 -Start $Start -End $End | Out-Null
# make aggregation of previous step
.\project-per-workspace.ps1 -Start $Start -End $End | Out-Null
# IRreport
.\IR-summary-csv.ps1 -Start $Start -End $End | Out-Null
# finance
.\finance-percent-per-person.ps1 -Start $Start -End $End | Out-Null


## put all to one xlsx file 
$locations = "IRreports", "reports", "projectreports", "finance"
foreach ($i in $locations) {
    python multiple2one.py $i 
}

#### Move reports to Downloads folder
$pathToReports = [IO.Path]::Combine($HOME, "Downloads", ("Clockify {0}_{1}" -f $Start, $End))
Remove-Item -Recurse -Force -ErrorAction "SilentlyContinue" -Path $pathToReports | Out-Null  
mkdir $pathToReports -ErrorAction "SilentlyContinue" | Out-Null
$FinalReports = @{
    "projectreports" = ("Projects Detailed {0}_{1}.xlsx" -f $Start, $End)
    "reports"        = ("Summary {0}_{1}.xlsx" -f $Start, $End)
    "IRreports"      = ("IR report {0}_{1}.xlsx" -f $Start, $End)
    "finance"        = ("Finance {0}_{1}.xlsx" -f $Start, $End)
}
foreach ($i in $FinalReports.GetEnumerator()) {
    Copy-Item -Path (Join-Path -Path $I.Name -ChildPath ("{0}_{1}.xlsx" -f $Start, $End)) `
        -Destination (Join-Path -Path $pathToReports -ChildPath $i.Value)
}

Write-Host ("Reports are in {0}" -f $pathToReports)

explorer.exe $pathToReports
