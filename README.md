# Make report from clockify
```pwsh
PS C:\clockify> .\all-summary-csv.ps1 -Start '2023-01-01' -End '2023-01-15'
PS C:\clockify> .\summary-for-each-workspace.ps1 -Start '2023-01-01' -End '2023-01-15'
PS C:\clockify> .\csv2xlsx.ps1
True
True
True
[...]

(venv) PS C:\clockify> pip install -r requirements.txt
(venv) PS C:\clockify> cd .\reports\
(venv) PS C:\clockify\reports> python ..\multiple2one.py
```