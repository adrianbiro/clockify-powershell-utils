function sum-project-per-person {
    Param([string] $csvfile)
    [hashtable]$sum = @{}; 
    Get-Content -Path $csvfile `
    | ConvertFrom-Csv | Foreach-Object {
        [double] $num = $_."Duration in seconds" #TODO Department
        if ($sum[$_.Name]) {
            $sum[$_.Name] += $num
        }
        else {
            $sum[$_.Name] = $num
        }
    }
    return $sum
}
[hashtable] $PersonProject = @{};
foreach($name in (Get-ChildItem "projectreports" -Filter "*csv")){
    $ProjectName = (Split-Path $name -Leaf) -split "\s\d{4}-\d{2}-\d{2}_.*\.csv"
    foreach($i in (sum-project-per-person -csvfile $name).GetEnumerator()) {
        # {PersonName: {projectname: duration}}
        $PersonProject[$i.Name] += @{"$ProjectName" = $i.Value}
        #ForEach-Object { }
    }
}
$PersonProject #TODO map sum percent ratio
