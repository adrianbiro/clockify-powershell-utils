function Get-TODO {
    #$FilePath = ".\files\Clockify_Time_Report_Detailed_09_01_2023-15_01_2023.csv"
    param([string] $FilePath)
    Import-Csv $FilePath | Foreach-Object { $sum = @{} } {
        [double] $num = $_."Duration (decimal)"
        if ($sum[$_.Project]) {
            $sum[$_.Project] += $num
        }
        else {
            $sum[$_.Project] = $num
        }
    } 
    return $sum
}
function get-hours-from-decimal {
    #Decimal hours = hours + minutes/60 + seconds/3600
    #https://calculatordaily.com/decimal-hours-to-hours-minutes-calculator
    param([double] $num)
    [int] $hours = $num 
    [int] $minutes = [math]::Floor(($num * 60) % 60)  # Floor to make it consistent with Clockify web app
    [int] $seconds = [math]::Floor(($num * 3600) % 60)
    return "{0}:{1}:{2}" -f $hours, $minutes, $seconds
}

Function Merge-Hashtables {
    $Output = @{}
    ForEach ($Hashtable in ($Input + $Args)) {
        If ($Hashtable -is [Hashtable]) {
            ForEach ($Key in $Hashtable.Keys) {$Output.$Key = $Hashtable.$Key}
        }
    }
    $Output
}

#$hs = 
foreach ($i in (Get-ChildItem ".\files\" "*.csv").FullName) {
    Get-TODO $i 
} #|  Merge-Hashtables
#$hs 
# |  Foreach-Object { $sum = @{} } {
#     [double] $num = $_."Duration (decimal)"
#     if ($sum[$_.Project]) {
#         $sum[$_.Project] += $num
#     }
#     else {
#         $sum[$_.Project] = $num
#     }
# } $sum