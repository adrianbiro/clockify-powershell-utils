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
[hashtable] $PersonProject = @{};
foreach ($name in (Get-ChildItem "projectreports" -Filter "*csv")) {
    $ProjectName = (Split-Path $name -Leaf) -split "\s\d{4}-\d{2}-\d{2}_.*\.csv"
    [hashtable]$sum, [hashtable]$personInfo = (sum-project-per-person -ProjectName $ProjectName  -csvfile $name)
    foreach ($data in $sum.GetEnumerator()) {
       # foreach ($info in $personInfo.GetEnumerator()) {
            # {PersonName: {projectname: duration}}
            #if (-not $PersonProject[$data.Name]) {
                $PersonProject[$data.Name] += @{"$ProjectName" = $data.Value } #| Out-Null
            #}
            # foreach ($i in $Info) {
            #     if(-not ($data.Name -eq $personInfo["Person"])){continue}
            #     if ( $PersonProject[$data.Name][$data.Name]) {
            #         $PersonProject[$data.Name] += @{$data.Name = "$info[$i]" } 
            #     }
            # }
        #}
    }
}
$PersonProject #TODO map sum percent ratio
exit
foreach ($i in $PersonProject.GetEnumerator()) {
    $i.Value | ConvertTo-Json
}