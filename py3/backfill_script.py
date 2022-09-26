# Run data from 2012-01-01 to 2015-12-31
import datetime
import mysql.connector as myconn

# change start & end below for backfilling historical data
start = datetime.date(2012,1,1)
end = datetime.date(2012,12,31)
numdays = (end-start).days + 1
date_list = [(start + datetime.timedelta(days=x)).strftime('%Y-%m-%d') for x in range(numdays)]


conn = myconn.connect(
    host="demo-db1.c0kvfimqbkbb.us-east-1.rds.amazonaws.com",
    port='3306',
    user="admin",
    password="########",
    database="demo_sales"
)
cursor = conn.cursor()

#cursor.callproc('comupte_daily_new_users', param)

for date in date_list:
    cursor.execute("CALL comupte_daily_new_users('%s');"%(date))

cursor.close()
conn.close()


