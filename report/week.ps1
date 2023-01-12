#$FilePath = "files\Clockify_Time_Report_Detailed_01_01_2023-15_01_2023.xlsx"
#    https://devblogs.microsoft.com/scripting/grabbing-excel-xlsx-values-with-powershell/   
#import-module psexcel
# $a =   foreach ($i in (Import-XLSX -Path $FilePath  -RowStart 1)){ $i  }
# $a | Get-Unique
$FilePath = ".\files\Clockify_Time_Report_Detailed_09_01_2023-15_01_2023.csv"
function get-project-names {
    Param([string] $FilePath)
    $DupProjects = foreach ($i in (Import-Csv $FilePath)) {$i.Project} 
    $DupProjects | Sort-Object -Unique
    return $Projects
}
function main {
    $projectNames = get-project-names $FilePath
    $projectNames

}
main