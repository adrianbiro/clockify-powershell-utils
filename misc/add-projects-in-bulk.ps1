param(
  [Parameter(Mandatory = $true)]
  [string] $ClientName,
  [Parameter(Mandatory = $true)]
  [string] $NameOfWorkspace,
  [Parameter(Mandatory = $true)]
  [string] $File
)
$noadd = .\get-Projects.ps1 -NameOfWorkspace $NameOfWorkspace
#$noadd = @("foo", "bar")
foreach($i in Get-Content -Path $file) {
    if($noadd -contains $i){ 
        continue
    }
    .\add-Project.ps1 -NewProjectName $i -ClientName $ClientName -NameOfWorkspace $NameOfWorkspace
    Start-Sleep -Second 0.1
}