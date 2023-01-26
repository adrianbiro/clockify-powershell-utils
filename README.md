# Make report from clockify
tldr
```pwsh
PS C:\clockify> .\run.ps1 -Start '2023-01-01' -End '2023-01-15'
```
or
```pwsh
PS C:\clockify> .\all-summary-csv.ps1 -Start '2023-01-01' -End '2023-01-15'
PS C:\clockify> .\summary-for-each-workspace.ps1 -Start '2023-01-01' -End '2023-01-15'
(venv) PS C:\clockify> pip install -r requirements.txt
(venv) PS C:\clockify> cd .\reports\
(venv) PS C:\clockify\reports> python ..\multiple2one.py
```
final report is in `reports\2023-01-01_2023-01-15.xlsx`

## Excel stuff
decimal time to hours: `=TEXT(SUM(C2:C56)/24,"[h]:mm:ss")` or `=TEXT(SUM(OFFSET($C$2,0,0,COUNTA(C:C),1))/24,"[h]:mm:ss")`

# Make detailed report for each project from all workspaces
```pwsh
PS C:\clockify> ./detailed-for-project.ps1  -Start '2023-01-01' -End '2023-01-15'
```

# Change client name in all workspaces
```pwsh
PS C:\clockify> .\change-client-name-in-all-ws.ps1 -NewClientName 'Office&Facility Management' -ClientName 'Office Management'
```

# Add Project to workspace
```pwsh
PS C:\clockify> ./add-Project.ps1 -NameOfWorkspace 'Bar' -NewProjectName 'Foo' -ClientName 'Lol sro.'
# or
PS C:\clockify> ./add-Projects-in-bulk.ps1 -NameOfWorkspace 'Bar' -File 'Foo.txt' -ClientName 'Lol sro.'
```