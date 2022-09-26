# -*- coding: utf-8 -*-
"""
Created on Wed Sep 21 15:25:58 2022

@author: Bill
"""

import pandas as pd
import os
import random
import copy
import datetime
from sqlalchemy import create_engine
random_multi = list(range(3,7))
random_suffix = ['M1', 'M2', 'M3', 'M4']
random_int = [1,2,3,4,5]
#os.chdir("PycharmProjects\demo_supermarket_sales")

orders = pd.read_csv("C:/Users/Bill/PycharmProjects/demo_supermarket_sales/orders.csv")

new_orders = pd.DataFrame()

#orders = orders[:10000]
#orders = orders[10000:20000]
#orders = orders[20000:30000]
#orders = orders[30000:40000]
orders = orders[40000:]

for i in range(len(orders)):
    multiplier = random.choice(random_multi)
    original_row = orders.iloc[i]
    
    new_orders = new_orders.append(original_row)

    for j in range(multiplier):
        # 0 alter quantity and sales and discount & shift order date shipping date by n
        # 1 make it a new differnt customer shift order date shipping date by n
        new_row = copy.copy(original_row)
        j_rand = random.choice([0,1])                
        
        new_row['Order ID'] = new_row['Order ID'] + "#" + str(j) + '#' + str(j_rand)
        if j_rand == 1:
            new_row['Customer ID'] = new_row['Customer ID'] + random.choice(random_suffix)  # Manual Add
        else:
            random_multiplier = random.choice(random_int)
            new_row['Profit'] = random_multiplier * new_row['Profit']/new_row['Quantity']
            new_row['Sales'] = random_multiplier * new_row['Sales']/new_row['Quantity']
            new_row['Quantity'] = random_multiplier

            
        date_shift = random.choice(random_int)
        
        new_order_date = datetime.datetime.strptime(new_row['Order Date'], '%d/%m/%Y') + datetime.timedelta(days = date_shift)
        new_ship_date = datetime.datetime.strptime(new_row['Ship Date'], '%d/%m/%Y') + datetime.timedelta(days = date_shift)
        
        new_row['Order Date'] = datetime.datetime.strftime(new_order_date, '%d/%m/%Y')
        new_row['Ship Date'] = datetime.datetime.strftime(new_ship_date, '%d/%m/%Y')
        new_orders = new_orders.append(new_row)
        print(len(new_orders))
new_orders.to_csv("new_orders_5.csv", index = False)



no1 = pd.read_csv('new_orders_1.csv')
no2 = pd.read_csv('new_orders_2.csv')
no3 = pd.read_csv('new_orders_3.csv')
no4 = pd.read_csv('new_orders_4.csv')
no5 = pd.read_csv('new_orders_5.csv')


all_new_orders = no1.append(no2, ignore_index = True)
all_new_orders = all_new_orders.append(no3, ignore_index = True)
all_new_orders = all_new_orders.append(no4, ignore_index = True)
all_new_orders = all_new_orders.append(no5, ignore_index = True)


all_new_orders['unit_price'] = all_new_orders['Sales']/all_new_orders['Quantity']


product_info = all_new_orders.groupby('Product ID', as_index = False).agg({'Product Name': 'max',
                                                                           'unit_price': 'mean',
                                                                           'Segment': 'max',
                                                                           'Category': 'max', 
                                                                           'Sub-Category': 'max'})


product_info.rename(columns = {'Product ID': 'product_id', 
                               'Product Name': 'product_name',
                               'unit_price': 'unit_price',
                               'Segment': 'segment',
                               'Category': 'category', 
                               'Sub-Category': 'subcategory'}, inplace = True)

import mysql.connector
from sqlalchemy import create_engine

engine = create_engine('mysql+mysqlconnector://root:6541@localhost:3306/demo', echo=False)
product_info.to_sql(name='product_info', con=engine, if_exists = 'append', index=False)


all_new_orders.drop(columns = ['Category', 'Sub-Category', 'Product Name', 'Row ID', 'Sales', 'Profit', 'Segment', 'unit_price'], inplace = True)
all_new_orders.rename(columns = {'City': 'city',
                                 'Country': 'country',
                                 'Customer ID': 'customer_id',
                                 'Customer Name': 'customer_name',
                                 'Discount': 'discount',
                                 'Market': 'market',
                                 'Order Date': 'order_date',
                                 'Order ID': 'order_id',
                                 'Order Priority': 'order_priority',
                                 'Postal Code': 'postal_code',
                                 'Product ID': 'product_id',
                                 'Quantity': 'quantity', 
                                 'Region': 'region', 
                                 'Ship Date': 'ship_date', 
                                 'Ship Mode': 'ship_mode', 
                                 'Shipping Cost': 'shipping_cost', 
                                 'State': 'state'}, inplace = True) 
all_new_orders['order_date'] = all_new_orders['order_date'].apply(lambda x: pd.to_datetime(x, format="%d/%m/%Y").date())
all_new_orders['ship_date'] = all_new_orders['ship_date'].apply(lambda x: pd.to_datetime(x, format="%d/%m/%Y").date())



for i in range(len(all_new_orders)):
    all_new_orders[i:i+1].to_sql(name='orders', con=engine, if_exists = 'append', index=False)


len(set(list(all_new_orders['order_id'])))


all_new_orders.to_csv("all_new_orders.csv", index = False)
product_info.to_csv("product_info.csv", index = False)