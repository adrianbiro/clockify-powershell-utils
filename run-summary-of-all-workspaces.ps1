param(
    [Parameter(Mandatory = $true)]
    [string] $start,
    [Parameter(Mandatory = $true)]
    [string] $End
)
$reportdir = "reports"
Remove-Item $reportdir -Recurse -Force -ErrorAction "SilentlyContinue"
.\all-summary-csv.ps1 -Start $Start -End $End
.\summary-for-each-workspace.ps1 -Start $Start -End $End
if (-not (test-path venv)) {
    python3 -m venv venv
    .\venv\Scripts\Activate.ps1
    pip install -r requirements.txt
}
.\venv\Scripts\Activate.ps1
Set-Location -Path "reports" 
python ..\multiple2one.py
Set-Location -Path "../"
deactivate
"Final report is in:`n`t{0}" -f (Join-path -Path $pwd.path -ChildPath ("\{0}\{1}_{2}.xlsx" -f $reportdir, $Start, $End))