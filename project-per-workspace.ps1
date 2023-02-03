param(
    [string] $Start,
    [string] $End
)
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
if ((-not $Start) -or (-not $End)) {
    "Usage:`n`t{0}  -Start '2023-01-01' -End '2023-01-15'" -f $MyInvocation.MyCommand.Name
    exit 1
}
function sum-project-per-person {
    Param(
        [string] $csvfile
    )
    [hashtable]$sum = @{};
    Get-Content -Path $csvfile `
    | ConvertFrom-Csv | Foreach-Object {
        [double] $num = $_."Duration in seconds" #TODO Department
        if ($sum[$_.Department]) {
            $sum[$_.Department] += $num
        }
        else {
            $sum[$_.Department] = $num
        }
    }
    return $sum 
}
function seconds-to-hours {
    Param([double] $num)
    return ("{0:hh\:mm\:ss}" -f [timespan]::fromseconds($num)) 
}
function main {
    $pathToReports = "reports"
    mkdir $pathToReports -ErrorAction "SilentlyContinue" | Out-Null
    [hashtable] $DepartmentInProject = @{};
    foreach ($name in (Get-ChildItem "projectreports" -Filter "*csv")) {
        $ProjectName = (Split-Path $name -Leaf) -split "\s\d{4}-\d{2}-\d{2}_.*\.csv"
        [hashtable]$sum = (sum-project-per-person -csvfile $name)
        foreach ($data in $sum.GetEnumerator()) {
            $DepartmentInProject[$data.Name] += @{"$ProjectName" = $data.Value } 
        }
    }
    foreach ($i in $DepartmentInProject.GetEnumerator()) {
        foreach ($j in $i.Value.GetEnumerator()) {
            $reportPath = Join-Path -Path $pathToReports -ChildPath ("{0} {1}_{2}.csv" -f $j.Name, $Start, $End)
            if (-not (Get-Content $reportPath -ErrorAction "SilentlyContinue").Count) { 
                '"Department","Hours"' | Add-Content -Encoding utf8BOM -Path $reportPath 
            }
            "`"{0}`",`"{1}`"" -f $i.Name, (seconds-to-hours -num $j.Value) | Add-Content -Encoding utf8BOM -Path $reportPath
        }
    }
}
main