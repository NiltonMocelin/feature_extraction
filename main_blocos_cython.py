# Algoritmo para ler um arquivo pcap de um fluxo e extrair blocos para processar suas features.



import argparse
import os
import time
import json
import gc
import sys
sys.path.append('/media/nnmoc/Data/material_traffic_classification2/extracao_features/extrator_cython/src')
# from memory_profiler import profile

from scapy.utils import PcapReader, PcapNgReader, PcapWriter
from scapy.all import *

from filelock import FileLock

import feature_extractor_cython
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
        if contador < 5: # os cinco primeiros campos sao str 
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

def salvarPacotesScapyArquivo(filename, lista_pacotesScapy, append=False):
    
    # daqui pra frente está indo errado os blocoso
    _linktype = 101 # raw_ip

    if lista_pacotesScapy[0].haslayer('Ether'):
        _linktype = 1 # ethernet

    with PcapWriter(filename, append=append, linktype = _linktype) as pktdump:    
        pktdump.write(lista_pacotesScapy)
        pktdump.flush()

    return


def criar_pcaps_aux_one_way_ab_e_ba(folder_name, nome_arquivo):

    sufix = nome_arquivo.split('/')[-1]

    host_a = None

    leitor = PcapReader

    pacotes_ab = []
    pacotes_ba = []

    if 'pcapng' in nome_arquivo:
        leitor = PcapNgReader

    with leitor(folder_name+nome_arquivo) as reader:
        for pkt in reader:
            _ip = IP(raw(pkt)[14:])
            if host_a is None:
                host_a = _ip.src

            if _ip.src == host_a:
                pacotes_ab.append(pkt)
            else:
                pacotes_ba.append(pkt)

    if pacotes_ab:
            
        _linktype = 101 # raw_ip

        if pacotes_ab[0].haslayer('Ether'):
            _linktype = 1 # ethernet

        # wrpcap("ab.pcap", pacotes_ab, append=False, linktype = _linktype)
        pktdump = PcapWriter(f"ab_{sufix}", append=False, linktype = _linktype) # mais rapido que wrpcap pois permite flush
        pktdump.write(pacotes_ab)
        pktdump.flush()
        pktdump.close()
        
    if pacotes_ba:
        _linktype = 101 # raw_ip

        if pacotes_ba[0].haslayer('Ether'):
            _linktype = 1 # ethernet

        # wrpcap("ba.pcap", pacotes_ba, append=False, linktype = _linktype)
        pktdump = PcapWriter(f"ba_{sufix}", append=False, linktype = _linktype)
        pktdump.write(pacotes_ba)
        pktdump.flush()
        pktdump.close()

    return

def get_bloco_pacotes(pcap_file, esq, dir):
    lista_pacotes = []

    leitor = PcapReader(pcap_file)
    if 'pcapng' in pcap_file:
        leitor = PcapNgReader(pcap_file)
    count = 0
    for pkt in leitor:
        if count >= esq and count < dir:
            lista_pacotes.append(pkt)
        count +=1
    leitor.close()
    return lista_pacotes

def get_qtd_pacotes(pcap_file):
    leitor = PcapReader(pcap_file)
    if 'pcapng' in pcap_file:
        leitor = PcapNgReader(pcap_file)
    count = 0
    for pkt in leitor:
        count +=1
    leitor.close()
    return count

# @profile
def gerar_blocos_processar_otimizado(file_name, tabela_db, proto, service_class, 
                                     app_class, folder_name='', 
                                     is_tcptrace=True, host_a= None, is_two_way= True, 
                                     block_size = -1, max_pacotes = 6000, idle_timeout=None):
    """ Gera blocos de pacotes e processa:
        file_name = nome do arquivo pcap do fluxo
        app_label = qual rótulo desse fluxo, se for conhecido (fase de treinamento).
        block_size = tamanho de cada bloco (0 == fluxo inteiro)
        subflows = IAT considerado de um subflow (None == nao considerar)
        two_ways = True or false
        ip_a = decidir manualmente quem é o IP ou deixar None e escolher sempre o que tiver mais pacotes como sendo o host_A (obs: isso é definido no primeiro bloco)
    """
     
    if not os.path.exists(folder_name+file_name):
        print('->',folder_name+file_name,' não existe')
        return
    
    if os.path.getsize(folder_name+file_name) < 100: # arquivo maior que 1kb
        print("[Diss] Arquivo vazio !")
        return 

    sufix = file_name.split('/')[-1]

    aux_filename = f'aux_{sufix}'
    
    if not idle_timeout:
        idle_timeout = 9999999
        
    #max_pacotes = max pacotes que iremos processar de um .pcap
    qtd_pacotes_pcap = get_qtd_pacotes(folder_name+file_name)

    if qtd_pacotes_pcap == 0:
        return
    
    if qtd_pacotes_pcap < block_size:
        print(f"[saindo]: {folder_name+file_name} - poucos pacotes: len {qtd_pacotes_pcap} < {block_size}")
        return

    if qtd_pacotes_pcap < max_pacotes:
        max_pacotes = qtd_pacotes_pcap

    qtd_blocos_passo = 500
    pacotes_passo = qtd_blocos_passo-1+block_size
    if block_size == -1: # qtdpacotes por bloco -> -1 quer dizer todos os pacotes em um bloco
        pacotes_passo = max_pacotes
        block_size = max_pacotes
    # print(f"Qtd pacotes a serem analisados: {max_pacotes}; total no pcap: {qtd_pacotes_pcap}")
    qtd_blocos = max_pacotes - block_size + 1 # qtd de blocos que consigo com essa qtd de pacotes

    lista_resultados = []
    qtd_pacotes_processados = 0

    tempo_ini = time.time()
    
    colunas = ""
    colunas_file = "header.csv"
    lock = FileLock(f"{tabela_db}_{app_class}.csv.lock")

    print(f'Opening {folder_name+file_name} sz: {os.path.getsize(folder_name+file_name)} tam_bloco: {block_size} tabela: {tabela_db}...')

    # carregar apenas 10000 blocos por vez
    lista_pacotes = get_bloco_pacotes(folder_name+file_name, 0, pacotes_passo)
    i_aux = 0
    contador = 0
    max_blocos = 5000
    for i in range(qtd_blocos):
        qtd_pacotes_processados += block_size

        if i >= max_blocos:
            break

        # if qtd_pacotes_processados >= max_pacotes:
        #     break

        bloco_pacotes = lista_pacotes[:block_size]
        lista_pacotes.pop(0)

        if float(bloco_pacotes[0].time) - float(bloco_pacotes[-1].time) > idle_timeout: #evitar blocos invalidos
            print(f"Bloco {i} invalido (idletimeout) ")
            continue

        contador+=1

        salvarPacotesScapyArquivo(f"{contador}_{aux_filename}", bloco_pacotes)
        host_a = bloco_pacotes[0].getlayer('IP').src
        
        try: 
            retorno = feature_extractor_cython.process_pcap(i, host_a, proto, service_class, app_class, f"{contador}_{aux_filename}", bloco_pacotes, is_two_way, is_tcptrace)         
            bloco_pacotes.clear()
            resultado_colunas = retorno[0]
            resultado_saida = retorno[1]
            # print(resultado_saida)
            # print(resultado_colunas)

            resultados_str = modelar_dados_csv(resultado_saida)
            if colunas == "":
                colunas = ",".join(resultado_colunas)

            lista_resultados.append(resultados_str)
            os.remove(f"{contador}_{aux_filename}")
        except Exception as e:
            print(e)

        if contador >= 100:
            contador = 0
            print(f'[working: {time.time() - tempo_ini}] pacotes_processados {qtd_pacotes_processados} blocos processados {i} pacotes bloco atuaal {block_size}')
            with lock:
                print("Escrevendo resultados")
                escreverArquivo(tabela_db, f"{tabela_db}_{app_class}.csv", lista_resultados)
            lista_resultados.clear()

        if i % qtd_blocos_passo == 0: # deu dezmil blocos
            print(f"[blocos:{i}] : pegando novos pacotes")
            print(qtd_blocos_passo)
            print(f"getting {pacotes_passo+i_aux}")
            i_aux+=1
            lista_pacotes.clear()
            #gc.collect() deu erro chamando junto com o cython    
            lista_pacotes = get_bloco_pacotes(folder_name+file_name, i_aux, pacotes_passo+i_aux)
        
            if len(lista_pacotes)<block_size:
                break
    
    with lock:
        print("Escrevendo resultados")
        escreverArquivo(tabela_db, f"{tabela_db}_{app_class}.csv", lista_resultados)
    lista_resultados.clear()

    if not os.path.exists(f"{tabela_db}/{colunas_file}"): #escrever as colunas apenas se nao foi feito antes...
        escreverArquivo(tabela_db, colunas_file, colunas)

    if os.path.exists(f"{tabela_db}_{app_class}.csv.lock"):
        os.remove(f"{tabela_db}_{app_class}.csv.lock")

    print(f"File {file_name} terminou: {time.time()-tempo_ini}")
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

    file_name = args.file_name
    # lista_arquivos = sorted(os.listdir(folder_name))

    service_class = args.service_class
    app_class = args.app_class
    tam_bloco = int(args.block_size)

    if '.pcap' not in file_name:
        print(f"Erro- exit: {file_name}")
        exit(0)

    proto = None
    if 'TCP' in file_name or 'tcp' in file_name:
        proto = 'TCP'
    elif 'UDP' in file_name  or 'udp' in file_name:
        proto = 'UDP'
    else: 
        print(f"Erro- exit: {file_name}")
        exit(0)
        
    ts = time.time()
    print(f"[inicio]: {file_name}")

    print('\ncriar arquivos ab')
    sufix = file_name.split('/')[-1]
    # criar arquivos one_way
    criar_pcaps_aux_one_way_ab_e_ba("", file_name) 

    #tabelas -> twoways_, fluxo_total_two_ways, fluxo_total_ab, ab_
    print("gerando blocos e processando")
        
    # if not is_somente_blocos:
    #     # Calcular o fluxo total    ################################################################
    #     print('\ncalculando fluxo_total_ab e ba')
    #     #ab
    #     gerar_blocos_processar_otimizado2(folder_name='', file_name= f"ab_{sufix}", tabela_db='fluxo_total_ab', proto=proto, service_class = service_class, app_class= app_class, is_two_way=False, is_tcptrace=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez utilizar esses depois
    #     #ba
    #     gerar_blocos_processar_otimizado2(folder_name='', file_name= f"ba_{sufix}", tabela_db='fluxo_total_ab', proto=proto, service_class = service_class, app_class= app_class, is_two_way=False, is_tcptrace=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez utilizar esses depois
    # ##############################################################################################
        

    print(f'calculando ab_{tam_bloco}pkts_2s')
    # 10 pacotes IAT 2s         ##################################################################
    # ab
    # gerar_blocos_processar_otimizado(folder_name='', block_size=tam_bloco, file_name= f"ab_{sufix}", tabela_db=f'ab_{tam_bloco}pkts_2s', proto=proto, service_class = service_class, app_class= app_class, idle_timeout=2, is_two_way=False, is_tcptrace=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez u
    
    # # ba
    # gerar_blocos_processar_otimizado(folder_name='', block_size=tam_bloco, file_name= f"ba_{sufix}", tabela_db=f'ab_{tam_bloco}pkts_2s', proto=proto, service_class = service_class, app_class= app_class, idle_timeout=2, is_two_way=False, is_tcptrace=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez u
    
    # proto = 'XX'
    # alem disso, criar as bases específicas para TCP
    if proto == 'TCP':
        
        # if not is_somente_blocos:
        #     print('\ncalculando twoways total TCP')
        #     #  two ways
        #     gerar_blocos_processar_otimizado2(folder_name="", file_name= file_name, tabela_db='fluxo_total_two_ways', proto=proto, service_class = service_class, app_class= app_class)  #two_way= True, block_size =None, idle_timeout=None) # talvez utilizar esses depois
        print(f'\ncalculando ab_tcp_{tam_bloco}pkts_2s')
        gerar_blocos_processar_otimizado(folder_name="", block_size=tam_bloco, file_name= file_name, tabela_db=f'twoways_{tam_bloco}pkts_2s', proto='TCP', service_class = service_class, app_class= app_class, idle_timeout=2)  #two_way= True, block_size =None, idle_timeout=None) # talvez utilizar esses depois
        # 10 pkts
        # ab
        gerar_blocos_processar_otimizado(folder_name='', block_size=tam_bloco, file_name= f"ab_{sufix}", tabela_db=f'ab_tcp_{tam_bloco}pkts_2s', proto='TCP', service_class = service_class, app_class= app_class, idle_timeout=2, is_two_way=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez u
        # ba
        gerar_blocos_processar_otimizado(folder_name='', block_size=tam_bloco, file_name= f"ba_{sufix}", tabela_db=f'ab_tcp_{tam_bloco}pkts_2s', proto='TCP', service_class = service_class, app_class= app_class, idle_timeout=2, is_two_way=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez u

    print(f"[fim-{time.time()-ts}]: {file_name}")

    removerArquivosTemporarios(file_name)
    print(f"---------------- [FIM-{time.time()-ts}] ----------------")