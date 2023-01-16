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