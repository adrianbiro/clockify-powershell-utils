import pandas as pd
import os
import re
import pathlib

url = os.path.abspath('')

files = os.listdir(os.path.abspath(''))
#files = [filepath.absolute() for filepath in pathlib.Path('reports').glob('**/*')]
df_dict = {}
for f in files:
    if f.endswith('.xlsx'): 
        excel = pd.ExcelFile(f)
        sheets = excel.sheet_names
        for s in sheets:
            df = excel.parse(s)
            name, *_ = re.split(r'\d\d\d\d\-\d\d\-\d\d', f)
            df_name = name
            df_dict[df_name] = df
        
with pd.ExcelWriter('output.xlsx') as writer:
    for k in df_dict.keys():
        df_dict[k].to_excel(writer, sheet_name = k, index=False)