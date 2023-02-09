param(
    [string] $Start,
    [string] $End,
    [string] $pathToReports = (Join-Path -Path "finance" -ChildPath "person")
)
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
if ((-not $Start) -or (-not $End)) {
    "Usage:`n`t{0}  -Start '2023-01-01' -End '2023-01-15'" -f $MyInvocation.MyCommand.Name
    exit 1
}
Remove-Item -Recurse -Force -ErrorAction "SilentlyContinue" -Path $pathToReports | Out-Null 
mkdir $pathToReports -ErrorAction "SilentlyContinue" | Out-Null


$finalReport = [array]@()
foreach ($csv in (Get-ChildItem  (Join-Path -Path "finance" -ChildPath "*.csv"))) {
    Import-Csv $csv | ForEach-Object {
        $_ | ForEach-Object {
            $finalReport += [PSCustomObject]@{
                "User"           = $_.User;
                "Project"        = $_.Project
                "Time (h)"       = $_."Time (h)"
                "Time (decimal)" = $_."Time (decimal)"
                "Percent"        = $_.Percent
            }  
        }
    }
}
[hashtable] $sum = @{}
$finalReport | Foreach-Object {
    [double] $num = $_."Time (decimal)"
    if ($sum[$_.User]) {
        $sum[$_.User] += $num
    }
    else {
        $sum[$_.User] = $num
    }
}


#exit
$finalReport | ForEach-Object {
    $reportPath = Join-Path -Path $pathToReports -ChildPath ("{0} {1}_{2}.csv" -f $_.User, $Start, $End) 
    if (-not (Get-Content $reportPath -ErrorAction "SilentlyContinue").Count) { 
        '"User","Project","Time (h)","Time (decimal)","Percent"' | Add-Content -Encoding utf8BOM -Path $reportPath 
    }
    "`"{0}`",`"{1}`",`"{2}`",`"{3}`",`"{4}`"" -f 
    $_."User", $_."Project", $_."Time (h)", $_."Time (decimal)", $(([double]$_."Time (decimal)" / $sum[$_.User]) * 100) `
    | Add-Content -Encoding utf8BOM -Path $reportPath
}