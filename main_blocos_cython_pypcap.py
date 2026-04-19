# Algoritmo para ler um arquivo pcap de um fluxo e extrair blocos para processar suas features.



import argparse
import os
import time
import json
from itertools import islice
import multiprocessing

# import gc
import sys
sys.path.append(f'{os.getcwd()}/src')
# from memory_profiler import profile

import operador_pypcap as opcap

# from filelock import FileLock

import compilar_cython.feature_extractor as feature_extractor
# from ConexaoDB_pgadmin import ConexaoDB
from conexaoDB_mongodb import MongoCli as ConexaoDB

QTD_MAX_BLOCOS = 10000 
TIPO_BLOCOS = 0 

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


def escreverArquivo(folder_name, file_name, resultados_str, append=True, lock=None):

    # if not lock:
    #     lock = FileLock(f"{file_name}.csv.lock")

    if not os.path.exists(folder_name):
        os.makedirs(folder_name, exist_ok=True) # Evita erro de concorrência

    file_path = os.path.join(folder_name, file_name)
    
    # with lock: # nao remova o filelock manualmente durante os processos !! vai causar inconsistencia - estava dando problema
    with open(file_path, 'a' if append else 'w', encoding='utf-8') as file:
        if type(resultados_str) == list:
            for linha in resultados_str:
                file.write(f'{linha}\n')
        else:
            file.write(resultados_str+'\n')
        # file.flush()
        
    return



def dividir_e_filtrar_blocos(lista, tamanho, idle_timeout=2.0):
    """
    Gera blocos de tamanho fixo e filtra aqueles que excedem o timeout.
    lista: lista de tuplas (timestamp, dados_pacote)
    """
    it = iter(lista)
    while True:
        # Pega o próximo pedaço da lista
        bloco = list(islice(it, tamanho))
        if not bloco:
            break
        
        # Só processamos se o bloco estiver cheio (opcional) 
        # e se a diferença de tempo for menor que o timeout
        t_inicio = bloco[0][0]
        t_fim = bloco[-1][0]
        
        if (t_fim - t_inicio) <= idle_timeout:
            yield bloco
        else:
            # Opcional: print para debug
            # print(f"Bloco descartado: delta {t_fim - t_inicio:.2f}s")
            continue

def dividir_e_filtrar_deslizante(lista, tamanho, outros_parametros, idle_timeout=2.0):
    """
    Implementa uma janela deslizante: se o bloco for inválido, 
    anda apenas 1 pacote para frente e tenta novamente.
    """
    i = 0
    total = len(lista)
    
    while i + tamanho <= total:
        # Pega a janela atual (Slicing de lista é rápido no Python)
        bloco = lista[i : i + tamanho]
        
        t_inicio = bloco[0][0]
        t_fim = bloco[-1][0]
        
        if (t_fim - t_inicio) <= idle_timeout:
            yield (outros_parametros, bloco)
            # Se o bloco é válido, pulamos 'tamanho' para pegar o próximo bloco único
            # OU aumentamos apenas 1 se você quiser sobreposição total (mais lento)
            i += tamanho 
        else:
            # BLOCO INVÁLIDO: Anda apenas 1 posição para tentar achar um bloco válido
            i += 1

def dividir_e_filtrar_rajadas(lista, tamanho, parametros, idle_timeout=2.0):
    """
    Agrupa pacotes em blocos de 'tamanho'.
    Se qualquer intervalo entre pacotes consecutivos for > idle_timeout,
    descarta o que foi acumulado e recomeça a partir do pacote atual.
    """
    bloco_atual = []
    
    for i in range(len(lista)):
        pacote_atual = lista[i] # (timestamp, dados)
        
        if not bloco_atual:
            bloco_atual.append(pacote_atual)
            continue
        
        # Calcula o intervalo entre o pacote atual e o anterior
        ts_anterior = bloco_atual[-1][0]
        ts_atual = pacote_atual[0]
        intervalo = ts_atual - ts_anterior
        
        if intervalo <= idle_timeout:
            bloco_atual.append(pacote_atual)
            
            # Se atingimos o tamanho desejado, entregamos o bloco e limpamos
            if len(bloco_atual) == tamanho:
                yield (parametros, bloco_atual)
                if TIPO_BLOCOS==0:
                    bloco_atual = []
                else:
                    bloco_atual.pop(0)
                #outra abordagem bloco_atual.pop() -> porem caracteristicas muito semelhantes -> entradas muito parecidas na db
        else:
            # QUEBRA DE IDLE: O pacote atual demorou demais.
            # O que tínhamos acumulado é descartado e o atual vira o novo 'primeiro'
            bloco_atual = [pacote_atual]

def gerar_blocos_processar_otimizado2(host_a, host_b,host_a_port, host_b_port, lista_ts_raw_pkts, file_path, block_size, idle_timeout, linktype, tabela_db, proto, service_class, 
                                     app_class, is_tcptrace=True, is_two_way= True):
    
    pid = os.getpid()
    qtd_pacotes_pcap = len(lista_ts_raw_pkts)
    if qtd_pacotes_pcap == 0:
        print("Gerar_blocos: lista vazia")
        return

    if block_size==-1:
        block_size = qtd_pacotes_pcap
    
    if qtd_pacotes_pcap < block_size:
        print(f"[saindo]: {file_path} - poucos pacotes: len {qtd_pacotes_pcap} < {block_size}")
        return
    
    tempo_ini = time.time()

    print(f'Opening {file_path} sz: {qtd_pacotes_pcap} tam_bloco: {block_size} tabela: {tabela_db}...')
    
    parametros = {'linktype':linktype,'host_a':host_a,'host_b':host_b,
        'port_a':host_a_port,
        'port_b':host_b_port,
        'proto':proto,
        'service_class':service_class,
        'app_class':app_class,
        'is_two_way':is_two_way,
        'is_tcptrace':is_tcptrace,
        'filepath': file_path}

    lista_parametros_e_ts_pkts = list(dividir_e_filtrar_rajadas(lista_ts_raw_pkts, block_size, parametros, idle_timeout))

    resultados_valores = []
    ctx = multiprocessing.get_context('spawn')
    with ctx.Pool(processes=multiprocessing.cpu_count()) as pool:
    #     # O chunksize faz com que o Python envie blocos em grupos, reduzindo a comunicação
        resultados_valores.append(pool.map(feature_extractor.process_bloco_pypcap, lista_parametros_e_ts_pkts))

    if resultados_valores == []:
        print(f'sem resultados validos')
        return
    
    # resultados_valores = [",".join(map(str, ress)) for ress in resultados_valores]
    # resultados_valores = [modelar_dados_csv(ress) for ress in resultados_valores]
    # print(f"res { resultados_valores}")
    print("Escrevendo resultados")
    for res in resultados_valores:
        escreverArquivo(tabela_db, f"{tabela_db}_{app_class}_{pid}.csv", res)
    resultados_valores.clear()

    print(f"File {file_path} terminou: {time.time()-tempo_ini}")
    return         


def run(args):
    # lista_tam_blocos = [10,30,50]
    is_somente_blocos = True # nao faz flow total
    TIPO_BLOCOS = 0 # se for 1=a janela desliza em 1 pacote, se for 0= a janela desliza o tamanho do bloco

    file_name = args.file_name # deveria ser file_path..
    # lista_arquivos = sorted(os.listdir(folder_name))

    service_class = args.service_class
    app_class = args.app_class
    tam_bloco = int(args.block_size)
    max_pacotes = 5000

    if '.pcap' not in file_name:
        print(f"Erro- not a pcap: {file_name}")

    ts = time.time()
    print(f"[inicio]: {file_name}")

    lista_ts_raw_pkts, linktype = opcap.ler_binario_direto(file_name, max_pacotes) #[(timestamp, bytes)]
    
    if lista_ts_raw_pkts == []:
        print(f"Arquivo {file_name} sem pacotes")
        return 
    
    pkt_zero_dict = opcap.montar_pkt_to_dict(lista_ts_raw_pkts[0][1], linktype)
    proto = 'udp'
    host_a=""
    host_b=""
    host_a_port=""
    host_b_port=""
    if pkt_zero_dict:
        if 'ipv4' in pkt_zero_dict:
            host_a = pkt_zero_dict['ipv4']['src_ip']
            host_b = pkt_zero_dict['ipv4']['dst_ip']
        if 'tcp' in pkt_zero_dict:
            proto = 'tcp'
        elif 'udp' in pkt_zero_dict:
            proto = 'udp'
        else:
            print("pacote sem tcp ou udp")
            return
        host_a_port = pkt_zero_dict[proto]['src_port']
        host_b_port = pkt_zero_dict[proto]['dst_port']
    

    lista_ts_raw_pkts_ab = []
    lista_ts_raw_pkts_ba = []
    for ts,pkt in lista_ts_raw_pkts:
        pkt_dict = opcap.montar_pkt_to_dict(pkt, linktype)
        if pkt_dict!= None:
            if 'ipv4' in pkt_dict:
                if  pkt_dict['ipv4']['src_ip'] == host_a:
                    lista_ts_raw_pkts_ab.append((ts,pkt))
                else:
                    lista_ts_raw_pkts_ba.append((ts,pkt))
        else:
            print("ERRO um pacote mal formado foi encontrado:")
            return

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
    if lista_ts_raw_pkts_ab != []:
        gerar_blocos_processar_otimizado2(host_a=host_a, host_b=host_b, host_a_port=host_a_port, host_b_port=host_b_port, lista_ts_raw_pkts = lista_ts_raw_pkts_ab, linktype=linktype, block_size=tam_bloco, file_path=file_name, tabela_db=f'ab_{tam_bloco}pkts_2s', proto=proto, service_class = service_class, app_class= app_class, idle_timeout=2, is_two_way=False, is_tcptrace=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez u
    # exit(0)
    # ba
    if lista_ts_raw_pkts_ba != []:
        gerar_blocos_processar_otimizado2(host_a=host_a, host_b=host_b, host_a_port=host_a_port, host_b_port=host_b_port,lista_ts_raw_pkts = lista_ts_raw_pkts_ba, linktype=linktype, block_size=tam_bloco, file_path= file_name, tabela_db=f'ab_{tam_bloco}pkts_2s', proto=proto, service_class = service_class, app_class= app_class, idle_timeout=2, is_two_way=False, is_tcptrace=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez u
    
    # proto = 'XX'
    # alem disso, criar as bases específicas para TCP
    if proto == 'tcp':
        
        # if not is_somente_blocos:
        #     print('\ncalculando twoways total TCP')
        #     #  two ways
        #     gerar_blocos_processar_otimizado2(folder_name="", file_name= file_name, tabela_db='fluxo_total_two_ways', proto=proto, service_class = service_class, app_class= app_class)  #two_way= True, block_size =None, idle_timeout=None) # talvez utilizar esses depois
        print(f'\ncalculando ab_tcp_{tam_bloco}pkts_2s')
        gerar_blocos_processar_otimizado2(host_a=host_a, host_b=host_b, host_a_port=host_a_port, host_b_port=host_b_port,lista_ts_raw_pkts = lista_ts_raw_pkts, linktype=linktype, block_size=tam_bloco, file_path= file_name, tabela_db=f'twoways_{tam_bloco}pkts_2s', proto=proto, service_class = service_class, app_class= app_class, idle_timeout=2)  #two_way= True, block_size =None, idle_timeout=None) # talvez utilizar esses depois
        # exit(0)
        # 10 pkts
        # ab
        if lista_ts_raw_pkts_ab != []:
            gerar_blocos_processar_otimizado2(host_a=host_a, host_b=host_b, host_a_port=host_a_port, host_b_port=host_b_port,lista_ts_raw_pkts = lista_ts_raw_pkts_ab, linktype=linktype, block_size=tam_bloco, file_path= file_name, tabela_db=f'ab_tcp_{tam_bloco}pkts_2s', proto=proto, service_class = service_class, app_class= app_class, idle_timeout=2, is_two_way=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez u
        # ba
        if lista_ts_raw_pkts_ba != []:
            gerar_blocos_processar_otimizado2(host_a=host_a, host_b=host_b, host_a_port=host_a_port, host_b_port=host_b_port,lista_ts_raw_pkts = lista_ts_raw_pkts_ba, linktype=linktype, block_size=tam_bloco, file_path= file_name, tabela_db=f'ab_tcp_{tam_bloco}pkts_2s', proto=proto, service_class = service_class, app_class= app_class, idle_timeout=2, is_two_way=False)  #two_way= True, block_size =None, idle_timeout=None) # talvez u

        # removerArquivosTemporarios(file_name)
    print(f"---------------- [FIM-{time.time()-ts}] ----------------")
    return


if __name__ == '__main__':


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

    #tabelas -> twoways_, fluxo_total_two_ways, fluxo_total_ab, ab_
    print("gerando blocos e processando")
    run(args)
    
