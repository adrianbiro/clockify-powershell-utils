###############
##TODO it will add first blank column to new file

$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
$workingdir = "reports\*.csv"
$csv = Get-ChildItem -path $workingdir
foreach($inputCSV in $csv){
$outputXLSX = Join-Path -Path $inputCSV.DirectoryName -ChildPath ("{0}.xlsx" -f $inputCSV.Basename)
### Create a new Excel Workbook with one empty sheet
$excel = New-Object -ComObject excel.application 
$excel.DisplayAlerts = $False
$workbook = $excel.Workbooks.Add(1)
$worksheet = $workbook.worksheets.Item(1)

### Build the QueryTables.Add command
### QueryTables does the same as when clicking "Data » From Text" in Excel
$TxtConnector = ("TEXT;" + $inputCSV)
$Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
$query = $worksheet.QueryTables.item($Connector.name)

### Set the delimiter (, or ;) according to your regional settings
### $Excel.Application.International(3) = ,
### $Excel.Application.International(5) = ;
$query.TextFileOtherDelimiter = $Excel.Application.International(5)

### Set the format to delimited and text for every column
### A trick to create an array of 2s is used with the preceding comma
$query.TextFileParseType  = 1
$query.TextFileColumnDataTypes = ,2 * $worksheet.Cells.Columns.Count
$query.AdjustColumnWidth = 1

### Execute & delete the import query
$query.Refresh()
$query.Delete()

### Save & close the Workbook as XLSX. Change the output extension for Excel 2003
$Workbook.SaveAs($outputXLSX,51)  
$excel.Quit()
}
## To exclude an item, use the '-exclude' parameter (wildcards if needed)
remove-item -path $workingdir -exclude summary*.csv