param(
    #[Parameter(Mandatory = $true)]
    [string] $Start,
    #[Parameter(Mandatory = $true)]
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
remove-Item ".\reports\",".\projectreports\" -Recurse -Force -ErrorAction "SilentlyContinue" | Out-Null

### Generate reports
# Detailed for each project, persoon, task name etc.
.\detailed-for-project.ps1 -Start $Start -End $End | Out-Null
# put all to one xlsx file 
python multiple2one.py projectreports
# this one must go firts
.\all-summary-csv.ps1 -Start $Start -End $End | Out-Null
# make aggregation of previous step
.\summary-for-each-workspace.ps1 -Start $Start -End $End | Out-Null
# put all to one xlsx file 
python multiple2one.py reports

#### Move reports to Downloads folder
$pathToReports = [IO.Path]::Combine($HOME, "Downloads", ("Clockify {0}_{1}" -f $Start, $End))
Remove-Item -Recurse -Force -ErrorAction "SilentlyContinue" -Path $pathToReports | Out-Null  
mkdir $pathToReports -ErrorAction "SilentlyContinue" | Out-Null
Copy-Item -Path (Join-Path -Path "projectreports" -ChildPath ("{0}_{1}.xlsx" -f $Start, $End)) `
    -Destination (Join-Path -Path $pathToReports -ChildPath ("Projects Detailed {0}_{1}.xlsx" -f $Start, $End))
Copy-Item -Path (Join-Path -Path "reports" -ChildPath ("{0}_{1}.xlsx" -f $Start, $End)) `
    -Destination (Join-Path -Path $pathToReports -ChildPath ("Summary {0}_{1}.xlsx" -f $Start, $End))

Write-Host ("Reports are in {0}" -f $pathToReports)

explorer.exe $pathToReports
