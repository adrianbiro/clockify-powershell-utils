$FilePath = ".\files\Clockify_Time_Report_Detailed_09_01_2023-15_01_2023.csv"
#Decimal hours = hours + minutes/60 + seconds/3600
$a = foreach ($i in (Import-Csv $FilePath)) {$i } 
$a | % {$sum = @{}} {
    [double] $num = $_."Duration (decimal)"
    if ($sum[$_.Project]) {
        $sum[$_.Project] += $num
    }
    else {
        $sum[$_.Project] = $num
    }
} {$sum}