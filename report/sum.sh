 awk -F',' '{
  arr[$1] += gsub("\"","", $15)
}
END{for (i in arr) {
      if(length(i)){
        print i ,arr[i]
      }
   }
}' files/Clockify_Time_Report_Detailed_09_01_2023-15_01_2023.csv
#awk -F',' '{ print  $15}' files/Clockify_Time_Report_Detailed_09_01_2023-15_01_2023.csv
# vráti string a pomieša columns