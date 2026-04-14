# Algoritmo para ler um arquivo pcap de um fluxo e extrair blocos para processar suas features.



import argparse
import os
import time
import json
# import gc
import sys
sys.path.append(f'{os.getcwd()}/src')
# from memory_profiler import profile

import operador_pypcap as opcap

from filelock import FileLock

import compilar_cython.feature_extractor as feature_extractor
# from ConexaoDB_pgadmin import ConexaoDB
from conexaoDB_mongodb import MongoCli as ConexaoDB

QTD_MAX_BLOCOS = 10000 

# idle_timeout = 2 #segundos

def modelar_dados(colunas, valores):
    resultados_str = ""
    
    # print("mongodb - modelar_dados")
    # print(f"colunas: {colunas}")
    # print(f"valores: {valores}")
    contador = 0 
    for col, val in zip(colunas,valores):
        if contador < 2: # os dois primeiros campos sao str 
            contador +=1
            resultados_str+= f',"{col}":"{val}"'
        else:
            resultados_str+= f',"{col}":{val}'
    return "{"+resultados_str.replace(',',"",1)+"}"

def modelar_dados_csv(valores):
    resultados_str = ""
    contador = 0 
    for val in valores:
        if contador < 5: # os cinco primeiros campos sao str 
            contador +=1
            resultados_str+= f',"{val}"'
        else:
            resultados_str+= f',{val}'
    return resultados_str.replace(',',"",1)


def removerArquivosTemporarios(file_name):

    # removendo aux_ (se houver -- esse é removido depois do uso na funcao dele)
    # removendo ab_ ba_
    # removendo .db 
    sufix = file_name.split("/")[-1]
    if os.path.exists(f'ab_{sufix}'):
        os.remove(f'ab_{sufix}')
    if os.path.exists(f'ba_{sufix}'):
        os.remove(f'ba_{sufix}')

    return 

def inserirArquivoEmDB(file_name, dbcon, nome_tabela):

    print("File Name: ", file_name)

    with open(file_name, 'r') as fileopen:
        count = 0
        lista_entradas = []
    
        for f in fileopen:
            # print(f"InserirDB: lendo arquivo -> {f}")
            if f == "":
                continue

            try:
                lista_entradas.append(json.loads(f))         
            except:
                print("linha problema: ", count)
                print(f)

            count+=1

            if count >= 5000: # agrupando 5000 entradas
                dbcon.insertMany(nome_tabela, lista_entradas)
                lista_entradas.clear()
                count=0
            if lista_entradas:
                dbcon.insertMany(nome_tabela, lista_entradas)    
    
        print("Inserido no DB")
        lista_entradas.clear()

    return True


def escreverArquivo(folder_name, file_name, resultados_str, append=True):

    if not os.path.exists(folder_name):
        os.makedirs(folder_name)

    file_path = os.path.join(folder_name, file_name)
    file = open(file_path, 'a' if append else 'w', encoding='utf-8')
    if type(resultados_str) == list:
        for linha in resultados_str:
            file.write(linha+'\n')
    else:
        file.write(resultados_str+'\n')
    file.flush()
    file.close()
    return


# @profile
# gerar_blocos_processar_otimizado(lista_ts_raw_pkts = lista_ts_raw_pkts, block_size=tam_bloco, file_name=file_name, tabela_db=f'ab_{tam_bloco}pkts_2s', proto=proto, service_class = service_class, app_class= app_class, idle_timeout=2, is_two_way=False, is_tcptrace=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez u
def gerar_blocos_processar_otimizado(lista_ts_raw_pkts, file_path, linktype, tabela_db, proto, service_class, 
                                     app_class, is_tcptrace=True, host_a= "", host_b="", is_two_way= True, 
                                     block_size = -1, idle_timeout=None):
     
    if len(lista_ts_raw_pkts_ab) == []:
        print("Gerar_blocos: lista vazia")
        return

    if not idle_timeout:
        idle_timeout = 9999999
        
    #max_pacotes = max pacotes que iremos processar de um .pcap
    qtd_pacotes_pcap = len(lista_ts_raw_pkts)
    bloco_pacotes = []
    
    if qtd_pacotes_pcap < block_size:
        print(f"[saindo]: {file_path} - poucos pacotes: len {qtd_pacotes_pcap} < {block_size}")
        return

    if block_size == -1: # qtdpacotes por bloco -> -1 quer dizer todos os pacotes em um bloco
        block_size = max_pacotes
        
    lista_resultados = []
    qtd_pacotes_processados = 0

    tempo_ini = time.time()
    # print(f"[debug] len{len(lista_ts_raw_pkts)}")
    dict_pacote_zero = opcap.montar_pkt_to_dict(lista_ts_raw_pkts[0][1], linktype)
    host_a = dict_pacote_zero['ipv4']['src_ip']
    host_b = dict_pacote_zero['ipv4']['dst_ip']
    port_a = dict_pacote_zero[proto]['src_port']
    port_b = dict_pacote_zero[proto]['dst_port']
    
    colunas = ""
    colunas_file = "header.csv"
    lock = FileLock(f"{tabela_db}_{app_class}.csv.lock")

    print(f'Opening {file_path} sz: {os.path.getsize(file_path)} tam_bloco: {block_size} tabela: {tabela_db}...')

    i_aux = 0
    contador_pkts = block_size 
    contador_blocos = 0
    # max_blocos = 5000 # tirei isso
    for ts, raw_pkt in lista_ts_raw_pkts:
        contador_blocos +=1
        qtd_pacotes_processados += block_size

        bloco_pacotes = lista_ts_raw_pkts[:block_size]
        lista_ts_raw_pkts.pop(0)

        tempo_1st_pkt_bloco = bloco_pacotes[0][0]
        tempo_ult_pkt_bloco = bloco_pacotes[-1][0]
        
        if tempo_ult_pkt_bloco - tempo_1st_pkt_bloco  > idle_timeout: #evitar blocos invalidos
            print(f"Bloco {contador_blocos} invalido (idletimeout) ")
            continue

        contador_pkts+=1
        
        retorno = feature_extractor.process_bloco_pypcap(file_path, bloco_pacotes, linktype, contador_blocos, host_a, host_b, port_a, port_b, proto, service_class, app_class, is_two_way, is_tcptrace)
        bloco_pacotes.clear()
        resultado_colunas = retorno[0]
        resultado_saida = retorno[1]
        # print(resultado_saida)
        # print(resultado_colunas)

        # print(f"res_val {resultado_saida}") # prints para comparar tcptrace com a saida
        # print(f"res_col {resultado_colunas}")
        resultados_str = modelar_dados_csv(resultado_saida)
        if colunas == "":
            colunas = ",".join(resultado_colunas)

        lista_resultados.append(resultados_str)

        if contador_blocos % 500 ==0:
            print(f'[working: {time.time() - tempo_ini}] pacotes_processados {qtd_pacotes_processados} blocos processados {contador_blocos} pacotes bloco atuaal {block_size}')
            with lock:
                print("Escrevendo resultados")
                escreverArquivo(tabela_db, f"{tabela_db}_{app_class}.csv", lista_resultados)
            lista_resultados.clear()
    
    with lock:
        print("Escrevendo resultados")
        escreverArquivo(tabela_db, f"{tabela_db}_{app_class}.csv", lista_resultados)
    lista_resultados.clear()

    if not os.path.exists(f"{tabela_db}/{colunas_file}"): #escrever as colunas apenas se nao foi feito antes...
        escreverArquivo(tabela_db, colunas_file, colunas)

    if os.path.exists(f"{tabela_db}_{app_class}.csv.lock"):
        os.remove(f"{tabela_db}_{app_class}.csv.lock")

    print(f"File {file_path} terminou: {time.time()-tempo_ini}")
    return

def host_mais_pacotes(bloco_pacotes):
    """ Entrada: bloco de pacotes
        Saída: ip do host que tiver mais pacotes no bloco"""
    
    # teste de sanidade
    if bloco_pacotes == []:
        return ''
    
    host_a = bloco_pacotes[0].getlayer('IP').src
    host_b = bloco_pacotes[0].getlayer('IP').dst
    contador = 0
    for pkt in bloco_pacotes:
        if pkt.getlayer('IP').src == host_a:
            contador+=1
        else:
            contador-=1
    
    if contador > 0:
        return host_a
    
    return host_b            

if __name__ == '__main__':

    # lista_tam_blocos = [10,30,50]
    is_somente_blocos = True # nao faz flow total

    parser = argparse.ArgumentParser(description='estatistica fluxos')
    parser.add_argument('--service_class', metavar='<[string] class of service (ex. video_real)>',
                        help='<[string] class of service (ex. video_real)>', required=True)
    parser.add_argument('--app_class', metavar='<[string] app of service (ex. facebook)>',
                        help='<[string] app of service (ex. facebook)>', required=True)
    parser.add_argument('--block_size', metavar='<[int] block_size (ex. 10)>',
                        help='<[int] block_size (ex. 10)>', required=True)
    parser.add_argument('--file_name', metavar='<[string] folder of the captured flows (pcap or pcapng)>',
                        help='<[string] folder of the captured flows (pcap or pcapng)>', required=True)

    args = parser.parse_args()

    file_name = args.file_name # deveria ser file_path..
    # lista_arquivos = sorted(os.listdir(folder_name))

    service_class = args.service_class
    app_class = args.app_class
    tam_bloco = int(args.block_size)
    max_pacotes = 5000

    if '.pcap' not in file_name:
        print(f"Erro- exit: {file_name}")
        exit(0)

    proto = None
    if 'TCP' in file_name or 'tcp' in file_name:
        proto = 'tcp'
    elif 'UDP' in file_name  or 'udp' in file_name:
        proto = 'udp'
    else: 
        print(f"Erro- exit: {file_name}")
        exit(0)
        
    ts = time.time()
    print(f"[inicio]: {file_name}")

    lista_ts_raw_pkts, linktype = opcap.ler_binario_direto(file_name, max_pacotes) #[(timestamp, bytes)]
    lista_ts_raw_pkts_ab = []
    lista_ts_raw_pkts_ba = []
    
    #tabelas -> twoways_, fluxo_total_two_ways, fluxo_total_ab, ab_
    print("gerando blocos e processando")
        
    # if not is_somente_blocos:
    #     # Calcular o fluxo total    ################################################################
    #     print('\ncalculando fluxo_total_ab e ba')
    #     #ab
    #     gerar_blocos_processar_otimizado(folder_name='', file_name= f"ab_{sufix}", tabela_db='fluxo_total_ab', proto=proto, service_class = service_class, app_class= app_class, is_two_way=False, is_tcptrace=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez utilizar esses depois
    #     #ba
    #     gerar_blocos_processar_otimizado(folder_name='', file_name= f"ba_{sufix}", tabela_db='fluxo_total_ab', proto=proto, service_class = service_class, app_class= app_class, is_two_way=False, is_tcptrace=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez utilizar esses depois
    # ##############################################################################################
        

    print(f'calculando ab_{tam_bloco}pkts_2s')
    # 10 pacotes IAT 2s         ##################################################################
    # ab

    # gerar_blocos_processar_otimizado(lista_ts_raw_pkts = lista_ts_raw_pkts, linktype=linktype, block_size=tam_bloco, file_path=file_name, tabela_db=f'ab_{tam_bloco}pkts_2s', proto=proto, service_class = service_class, app_class= app_class, idle_timeout=2, is_two_way=False, is_tcptrace=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez u
    # exit(0)
    # ba
    #erar_blocos_processar_otimizado(lista_ts_raw_pkts = lista_ts_raw_pkts, linktype=linktype, block_size=tam_bloco, file_path= file_name, tabela_db=f'ab_{tam_bloco}pkts_2s', proto=proto, service_class = service_class, app_class= app_class, idle_timeout=2, is_two_way=False, is_tcptrace=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez u
    
    # proto = 'XX'
    # alem disso, criar as bases específicas para TCP
    if proto == 'tcp':
        
        # if not is_somente_blocos:
        #     print('\ncalculando twoways total TCP')
        #     #  two ways
        #     gerar_blocos_processar_otimizado2(folder_name="", file_name= file_name, tabela_db='fluxo_total_two_ways', proto=proto, service_class = service_class, app_class= app_class)  #two_way= True, block_size =None, idle_timeout=None) # talvez utilizar esses depois
        print(f'\ncalculando ab_tcp_{tam_bloco}pkts_2s')
        gerar_blocos_processar_otimizado(lista_ts_raw_pkts = lista_ts_raw_pkts, linktype=linktype, block_size=tam_bloco, file_path= file_name, tabela_db=f'twoways_{tam_bloco}pkts_2s', proto=proto, service_class = service_class, app_class= app_class, idle_timeout=2)  #two_way= True, block_size =None, idle_timeout=None) # talvez utilizar esses depois
        exit(0)
        # 10 pkts
        # ab
        gerar_blocos_processar_otimizado(lista_ts_raw_pkts = lista_ts_raw_pkts, linktype=linktype, block_size=tam_bloco, file_path= file_name, tabela_db=f'ab_tcp_{tam_bloco}pkts_2s', proto=proto, service_class = service_class, app_class= app_class, idle_timeout=2, is_two_way=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez u
        # ba
        gerar_blocos_processar_otimizado(lista_ts_raw_pkts = lista_ts_raw_pkts, linktype=linktype, block_size=tam_bloco, file_path= file_name, tabela_db=f'ab_tcp_{tam_bloco}pkts_2s', proto=proto, service_class = service_class, app_class= app_class, idle_timeout=2, is_two_way=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez u

    print(f"[fim-{time.time()-ts}]: {file_name}")

    removerArquivosTemporarios(file_name)
    print(f"---------------- [FIM-{time.time()-ts}] ----------------")