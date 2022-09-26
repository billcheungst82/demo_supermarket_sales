import pandas as pd
import os
from sqlalchemy import create_engine
import math
#os.chdir("PycharmProjects\demo_supermarket_sales")


product_info = pd.read_csv("src/rawdata/product_info.csv")
all_new_orders = pd.read_csv("src/rawdata/all_new_orders.csv")

engine = create_engine('mysql+mysqlconnector://admin:65416541@demo-db1.c0kvfimqbkbb.us-east-1.rds.amazonaws.com:3306/demo_sales', echo=False)
product_info.to_sql(name='product_info', con=engine, if_exists = 'append', index=False)

batch_size = 1000
n_batch = math.ceil(len(all_new_orders)/batch_size)
for i in range(n_batch):
    start = i*1000
    end = ((i+1)*1000) - 1
    print("Inserting row %s to %s"%(start, end))
    all_new_orders.loc[start:end].to_sql(name='orders', con=engine, if_exists = 'append', index=False)
    print("Done row %s to %s"%(start, end))