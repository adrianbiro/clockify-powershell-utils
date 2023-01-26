import pandas as pd
import os
import re
import pathlib

url = os.path.abspath("")

files = os.listdir(os.path.abspath(""))
outputreportname = ""
df_dict = {}
for f in files:
    if f.endswith(".csv"):
        outputreportname = (
            re.search(r"(.*)(\d{4}\-\d{2}\-\d{2}_\d{4}\-\d{2}\-\d{2})(.*)", f).group(2)
            + ".xlsx"
        )
        read_file = pd.read_csv(f)
        *csvname, _ = f.split(".")
        excelname = "".join(csvname) + ".xlsx"
        read_file.to_excel(excelname, index=None, header=True)
        excel = pd.ExcelFile(excelname)
        sheets = excel.sheet_names
        for s in sheets:
            df = excel.parse(s)
            name, *_ = re.split(r"\d{4}\-\d{2}\-\d{2}", f)
            df_name = name[:30]  # truncate name of sheet
            df_dict[df_name] = df

with pd.ExcelWriter(outputreportname) as writer:
    for k in df_dict.keys():
        df_dict[k].to_excel(writer, sheet_name=k, index=False)
