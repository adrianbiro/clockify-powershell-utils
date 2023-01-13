 awk -F',' 'NR > 1{ 
  gsub("\"","", $15)
   arr[$1] += $15
}
END{for (i in arr) {
        print i ,arr[i]
      }
}' ${1:-"files/Clockify_Time_Report_Detailed_09_01_2023-15_01_2023.csv"}
