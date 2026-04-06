import pymongo

class MongoCli():
    
    def __init__(self, database, ip="localhost", port=27017):
        self.myclient = pymongo.MongoClient(f"mongodb://{ip}:{port}/")
        self.mydb = self.myclient[database] #self.myclient["traffic_classification"]
    
    def insert(self, table, mydict):
        # mydict = { "name": "John", "address": "Highway 37" }
        mycol = self.mydb[table]
        x = None
        try:
            x= mycol.insert_one(mydict)
        except:
            print("[Error:insert]:",x)

    
    def insertMany(self, table, mydict):
        # mydict = [{ "name": "John", "address": "Highway 37" },...]
        # print(f"InsertDB: inserindo tab {table} - {mydict}")

        mycol = self.mydb[table]
        x = None
        try:
            x= mycol.insert_many(mydict)
        except:
            print("[Error:insertMany]:",x)

    def get(self, table, querydict):
        mycol = self.mydb[table]
        return mycol.find(querydict)

    def delete(self, table, querydict):
        mycol = self.mydb[table]
        mycol.delete_one(querydict)
        return
    
    def fechar(self):
        self.myclient.close()
        return
    
    def modelar_dados(self, colunas=[], valores=[]):
        resultados_str = ""
        
        # print("mongodb - modelar_dados")
        # print(f"colunas: {colunas}")
        # print(f"valores: {valores}")

        contador = 0 
        for col, val in zip(colunas,valores):
            if contador < 5: # os cinco primeiros campos sao str 
                contador +=1
                resultados_str+= f',"{col}":"{val}"'
            else:
                resultados_str+= f',"{col}":{val}'

        return "{"+resultados_str.replace(',',"",1)+"}"


    def print_get(self, get_result):
        for x in get_result:
            print(x)
        return

    
# mocli = MongoCli()
# mocli.insert({"celula":0,"altura":3,"dias":10})
# mocli.insert({"celula":1,"altura":2,"dias":11})
# mocli.insert({"celula":2,"altura":4,"dias":12})
# mocli.insert({"celula":3,"altura":3,"dias":13})
# mocli.insert({"celula":4,"altura":5,"dias":13})
# mocli.insert({"celula":5,"altura":5,"dias":13})
# mocli.insert({"celula":6,"altura":5,"dias":13})
# mocli.insert({"celula":7,"altura":5,"dias":13})
# mocli.insert({"celula":8,"altura":5,"dias":13})

# mocli.insert({"celula":0,"altura":5,"dias":20})
# mocli.insert({"celula":1,"altura":5,"dias":21})
# mocli.insert({"celula":2,"altura":5,"dias":22})
# mocli.insert({"celula":3,"altura":5,"dias":23})
# for x in mocli.get({"celula":0}):   
#     print(x['celula'])
