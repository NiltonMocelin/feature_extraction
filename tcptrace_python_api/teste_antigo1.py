import tcptrace_api
import operador_pypcap as opcap
import multiprocessing 
import os



def get_file_name(file_path):
    return file_path.split('/')[-1].split('.')[0]


def modelar_dados_csv(valores):
    resultados_str = ""
    for val in valores:
        resultados_str+= f',{val}'
    return resultados_str.replace(',',"",1)

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

def tratar_tcptrace(saida_tcptrace):
    
    lista_colunas, lista_resultados = saida_tcptrace.split(";") 
    lista_colunas = lista_colunas.split(",")
    lista_resultados = lista_resultados.replace("NA", "0")
    lista_resultados = lista_resultados.replace("Y", "1")
    lista_resultados = lista_resultados.replace("N", "0")
    lista_resultados = lista_resultados.split(",")
    qtd_colunas = len(lista_colunas)
    qtd_resultados = len(lista_resultados)

    if qtd_colunas != qtd_resultados:
        print(f"Erro: o número de colunas ({len(lista_colunas)}) não corresponde ao número de resultados ({len(lista_resultados)}).")
        return ([], [])
    
    if qtd_colunas < 2 or qtd_resultados < 2:
        print("Erro: listas vazias ")
        return ([], [])
    
    # lista_colunas.pop(-1) #remover o ultimo , e os dois primeiros hosts ip address
    # lista_resultados.pop(-1)
    # lista_resultados.pop()
    lista_colunas = lista_colunas[2:qtd_colunas-1]
    lista_resultados = lista_resultados[2:qtd_resultados-1]

    # print(f"saida tcptrace: {lista_colunas}")
    
    
    # [a2b_syn_fin_pkts_sent]=0/0
    index = lista_colunas.index("a2b_syn_fin_pkts_sent")
    aux = lista_resultados[index].split("/")
    lista_colunas.pop(index)
    lista_colunas.append("a2b_syn_pkts_sent")
    lista_colunas.append("a2b_fin_pkts_sent")
    lista_resultados.pop(index)
    lista_resultados.append(aux[0])
    lista_resultados.append(aux[1])
    
    # [b2a_syn_fin_pkts_sent]=0/0
    index = lista_colunas.index("b2a_syn_fin_pkts_sent")
    aux = lista_resultados[index].split("/")
    lista_colunas.pop(index)
    lista_colunas.append("b2a_syn_pkts_sent")
    lista_colunas.append("b2a_fin_pkts_sent")
    lista_resultados.pop(index)
    lista_resultados.append(aux[0])
    lista_resultados.append(aux[1])
    
    # [a2b_req_1323_ws_ts]=N/Y
    index = lista_colunas.index("a2b_req_1323_ws_ts")
    aux = lista_resultados[index].split("/")
    lista_colunas.pop(index)
    lista_colunas.append("a2b_req_1323_ws")
    lista_colunas.append("a2b_req_1323_ts")
    lista_resultados.pop(index)
    lista_resultados.append(0 if aux[0] == "N" else 1)
    lista_resultados.append(0 if aux[1] == "N" else 1)
    
    # [b2a_req_1323_ws_ts]=N/Y
    index = lista_colunas.index("b2a_req_1323_ws_ts")
    aux = lista_resultados[index].split("/")
    lista_colunas.pop(index)
    lista_colunas.append("b2a_req_1323_ws") 
    lista_colunas.append("b2a_req_1323_ts")
    lista_resultados.pop(index)
    lista_resultados.append(0 if aux[0] == "N" else 1)
    lista_resultados.append(0 if aux[1] == "N" else 1)

    # for col, val in zip(lista_colunas, lista_resultados):
    #     print(f"[{col}]={val}")
    
    return lista_colunas, lista_resultados

def ler_folder(folder):
    listaa = os.listdir(folder)
    listaa.sort()
    return [file for file in listaa if '.pcap' in file]

def dividir_e_filtrar_rajadas(lista, tamanho, parametros, idle_timeout=2.0):
    """
    Agrupa pacotes em blocos de 'tamanho'.
    Se qualquer intervalo entre pacotes consecutivos for > idle_timeout,
    descarta o que foi acumulado e recomeça a partir do pacote atual.
    """
    TIPO_BLOCOS = 0
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

def teste3(folder, block_size, folder_output):
    files = ler_folder(folder)
    for file in files:
        lista_ts_raw_pkts, linktype = opcap.ler_binario_direto(os.path.join(folder, file), 2000)
        processar_blocos(folder_output, block_size, get_file_name(file), lista_ts_raw_pkts, linktype)
    return


def processar_blocos(folder, block_size, file_name, lista_ts_raw_pkts, linktype):

    lista_parametros_e_ts_pkts = list(dividir_e_filtrar_rajadas(lista_ts_raw_pkts, block_size,parametros={}, idle_timeout=2))

    for i,l in enumerate(lista_parametros_e_ts_pkts):
            
            # ctx = multiprocessing.get_context('spawn')
            resultados_valores = []

            # Criamos um Pool onde cada worker processa 1 tarefas e depois morre (limpa a RAM)
            # with multiprocessing.Pool(processes=1, maxtasksperchild=1) as pool:
            #     # O chunksize faz com que o Python envie blocos em grupos, reduzindo a comunicação
            #     bufferr = tcptrace_api.preparar_buffer_pcap_sem_header(lista_ts_raw_pkts, linktype)        
            #     resultados_valores=(pool.map(tcptrace_api.processar_em_memoria, [bufferr]))

            bufferr = tcptrace_api.preparar_buffer_pcap_sem_header(l[1], linktype)
            resultados_valores = tcptrace_api.processar_em_memoria(bufferr)

            col, val = tratar_tcptrace(resultados_valores)

            if col == [] or val ==[]:
                print(f'file: {file_name} - bloco vazio')
                continue
            escreverArquivo(folder,  f'blocks{block_size}_{file_name}.csv', modelar_dados_csv(val))

            # print(f"[run{i}]: {resultados_valores}")

def teste2(lista_ts_raw_pkts, linktype):

    lista_parametros_e_ts_pkts = list(dividir_e_filtrar_rajadas(lista_ts_raw_pkts, 10,parametros={}, idle_timeout=2))

    for i,l in enumerate(lista_parametros_e_ts_pkts):
            
            # ctx = multiprocessing.get_context('spawn')
            resultados_valores = []

            # Criamos um Pool onde cada worker processa 1 tarefas e depois morre (limpa a RAM)
            # with multiprocessing.Pool(processes=1, maxtasksperchild=1) as pool:
            #     # O chunksize faz com que o Python envie blocos em grupos, reduzindo a comunicação
            #     bufferr = tcptrace_api.preparar_buffer_pcap_sem_header(lista_ts_raw_pkts, linktype)        
            #     resultados_valores=(pool.map(tcptrace_api.processar_em_memoria, [bufferr]))

            bufferr = tcptrace_api.preparar_buffer_pcap_sem_header(l[1], linktype)
            resultados_valores = tcptrace_api.processar_em_memoria(bufferr)

            # result=tcptrace_api.processar_em_memoria(bufferr)

            print(f"[run{i}]: {resultados_valores}")


def teste1(lista_ts_raw_pkts, linktype):
    for i in range(100):
        
        # ctx = multiprocessing.get_context('spawn')
        resultados_valores = []

        # Criamos um Pool onde cada worker processa 1 tarefas e depois morre (limpa a RAM)
        # with multiprocessing.Pool(processes=1, maxtasksperchild=1) as pool:
        #     # O chunksize faz com que o Python envie blocos em grupos, reduzindo a comunicação
        #     bufferr = tcptrace_api.preparar_buffer_pcap_sem_header(lista_ts_raw_pkts, linktype)        
        #     resultados_valores=(pool.map(tcptrace_api.processar_em_memoria, [bufferr]))

        bufferr = tcptrace_api.preparar_buffer_pcap_sem_header(lista_ts_raw_pkts, linktype)
        resultados_valores = tcptrace_api.processar_em_memoria(bufferr)

        # result=tcptrace_api.processar_em_memoria(bufferr)

        print(f"[run{i}]: {resultados_valores}")







teste3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/qos/vpn_facebook_audio", 30, 'saida_tcptrace')


