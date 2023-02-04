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
function sum-project-per-person {
    Param(
        [string] $csvfile,
        [string] $ProjectName
    )
    [hashtable]$sum = @{};
    [hashtable]$personInfo = @{}; 
    Get-Content -Path $csvfile `
    | ConvertFrom-Csv | Foreach-Object {
        [double] $num = $_."Duration in seconds" #TODO Department
        if ($sum[$_.Name]) {
            $sum[$_.Name] += $num
        }
        else {
            $sum[$_.Name] = $num
        }
        
        $personInfo["Email"] = $_.Email
        $personInfo["Department"] = $_.Department
        $personInfo["ProjectName"] = $ProjectName
        $personInfo["Person"] = $_.Name
    }
    return $sum, $personInfo
}
function main {
    $pathToReports = "finance"
    Remove-Item -Recurse -Force -ErrorAction "SilentlyContinue" -Path $pathToReports | Out-Null 
    mkdir $pathToReports -ErrorAction "SilentlyContinue" | Out-Null
    [hashtable] $PersonProject = @{};
    foreach ($name in (Get-ChildItem "projectreports" -Filter "*csv")) {
        $ProjectName = (Split-Path $name -Leaf) -split "\s\d{4}-\d{2}-\d{2}_.*\.csv"
        [hashtable]$sum, [hashtable]$personInfo = (sum-project-per-person -ProjectName $ProjectName  -csvfile $name)
        foreach ($data in $sum.GetEnumerator()) {
            $PersonProject[$data.Name] += @{"$ProjectName" = $data.Value } 
        }
    }
    foreach ($i in $PersonProject.GetEnumerator()) {
        $reportPath = Join-Path -Path $pathToReports -ChildPath ("{0} {1}_{2}.csv" -f $i.Name, $Start, $End)
        $i.Value | ConvertTo-Csv | Add-Content -Encoding utf8BOM -Path $reportPath
        #TODO percent ratio (part / total) * 100 add to nex row in CSV
        # use api report 
        [Double]$PersonTotal
        foreach ($line in $i.Value | ConvertFrom-Csv) { 
            $properties = $line | Get-Member -MemberType Properties
            for ($j = 0; $j -lt $properties.Count; $j++) {
                $column = $properties[$j]
                $columnvalue = $line | Select-Object -ExpandProperty $column.Name
                $columnvalue
                # doSomething $column.Name $columnvalue 
                # doSomething $i $columnvalue 
            }
        } 
    }
}
main