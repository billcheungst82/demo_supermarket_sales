import mysql.connector as myconn
import ast
import sys

def main(argv):
    
    file = open("conn_info.txt", "r")
    contents = file.read()
    conn_dict = ast.literal_eval(contents)
    file.close()
    
    
    if len(argv) > 0:
        date = argv[1]
    else:
        exit()

    conn = myconn.connect(host =conn_dict['host'],
                          port = conn_dict['port'],
                          user = conn_dict['user'],
                          password = conn_dict['password'],
                          database = conn_dict['database'])
    cursor = conn.cursor()

    try:
        cursor.execute("CALL comupte_daily_new_users('%s');"%(date))
        cursor.close()
        conn.close()    
    except:
        cursor.close()
        conn.close()    
        print("Fail to run comupte_daily_new_users for date = " + date)
        exit()
        
    


    return


if __name__ == "__main__":
   main(sys.argv[1:])