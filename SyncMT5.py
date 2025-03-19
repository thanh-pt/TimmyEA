import os
import shutil

root_EA = r"C:\Users\tient\Documents\mt5\2.ROBO TRADE\MQL5\Experts\TimmyEA"

clients = [
    r"C:\Users\tient\Documents\mt5\1.MANUAL TRADE\MQL5\Experts\TimmyEA",
    r"C:\Users\tient\Documents\mt5\3.FUND TRADE\MQL5\Experts\TimmyEA",
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