import os
import shutil

root_EA = r"D:\3. RESOURCES\Software\000 Potable Program File\mt5\2.ROBO TRADE\MQL5\Experts\TimmyEA"

clients = [
    r"D:\3. RESOURCES\Software\000 Potable Program File\mt5\1.MANUAL TRADE\MQL5\Experts\TimmyEA",
    r"D:\3. RESOURCES\Software\000 Potable Program File\mt5\3.FUND TRADE\MQL5\Experts\TimmyEA",
]

for client in clients:
    if os.path.exists(client) == False:
        os.mkdir(client)


for file in os.listdir(root_EA):
    if file.endswith('.ex5'): 
        src_file = root_EA + "\\" + file
        for client in clients:
            dst_dir = client + "\\" + file
            shutil.copy2(src_file, dst_dir)
            print(src_file, " to ", dst_dir)