# Make report from clockify
* install dependencies
  * `pip3 install -r requirements.txt`   
  * put token to `.config` file in `clockify` directory
  * Powershell version 7 plus **not** 5.1
* Run `Make-All-Reports.ps1` to produce all reports.
    
```pwsh
PS C:\clockify> .\Make-All-Reports.ps1 -Start '2023-01-01' -End '2023-01-15'
# Or whitout arguments and default is last week
PS C:\clockify> .\Make-All-Reports.ps1
```

