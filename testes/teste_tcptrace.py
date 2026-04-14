from multiprocessing import Pool
import sys
# Add the directory containing the file to sys.path
sys.path.append('/media/nnmoc/Data/material_traffic_classification2/extracao_features/extrator_cython/src')

from tcptrace_api import wrapper_extrair_features

def _get_col_val_tcptrace(saida_tcptrace):
    linhas = saida_tcptrace.split("\n")

    # tcptrace gera muitas linhas, encontrar quando comeca a falar sobre o cabecalho + quebra de linha+ dados
    index_cabecalho = 0
    for linha in linhas:
        if 'conn_#' in linha:
            break
        index_cabecalho += 1

    lista_cabecalho = linhas[index_cabecalho].replace(" ", "").split(',')
    # ajustar valores numericos: N/Y por = 0/1 , NA por = 0 ,  N por = 0, Y por = 1
    lista_resultados = linhas[index_cabecalho + 2].replace(" ", "").replace("NA", "0").replace("N",
                                                                                                         "0").replace(
        "Y", "1").split(',')
    lista_cabecalho.pop(-1)  #remover o ultimo ,
    lista_resultados.pop(-1)
    return (lista_cabecalho, lista_resultados)


def tratar_tcptrace(saida_tcptrace, host_a, is_two_way= True, is_debug= False):
    """ Aqui tem que modifinar manualmente conforme quer o resultado:
    Entrada: tcptrace csv -> Separa a saída do tcptrace em uma lista de strings. Ajusta valores como N/Y e NA para numérico"""

    saida = _get_col_val_tcptrace(saida_tcptrace)
    lista_cabecalho = saida[0]
    lista_resultados = saida[1]

    if lista_resultados[2] == host_a: # se o host_b do tcptrace for igual ao host_a do extrator de features, entao precisamos trocar o host_b <-> host_a do tcptrace
        saida_tcptrace=saida_tcptrace.replace("a2b", "x2y")
        saida_tcptrace=saida_tcptrace.replace("b2a", "a2b")
        saida_tcptrace=saida_tcptrace.replace("x2y", "b2a")
        saida = _get_col_val_tcptrace(saida_tcptrace) # isso eh pq nao sabemos como o tcptrace escolhe o host a (na verdade eh por ordem, mas agora nao lembro pq deixei isso)
        lista_cabecalho = saida[0]
        lista_resultados = saida[1]

    #quero remover esses campos (sao os primeiros):: {'conn_#', 'host_a', 'host_b', 'port_a', 'port_b', first_packet, last_packet}
    lista_resultados.pop(0) # con
    tcptrace_host_a = lista_resultados.pop(0) # host_a
    tcptrace_host_b = lista_resultados.pop(0) # host_b
    lista_resultados.pop(0) # port_a
    lista_resultados.pop(0) # port_b
    lista_resultados.pop(0) # first_packet
    lista_resultados.pop(0) # last_packet

    lista_cabecalho.pop(0) # con
    lista_cabecalho.pop(0) # host_a
    lista_cabecalho.pop(0) # host_b
    lista_cabecalho.pop(0) # port_a
    lista_cabecalho.pop(0) # port_b
    lista_cabecalho.pop(0) # first_packet
    lista_cabecalho.pop(0) # last_packet

    lista_cabecalho.pop(32)
    aux = lista_resultados.pop(32).split("/")
    val1=aux[0]
    val2=aux[1]
    lista_cabecalho.append("SYN_pkts_sent_a2b")
    lista_cabecalho.append("FIN_pkts_sent_a2b")
    lista_resultados.append(val1)
    lista_resultados.append(val2)

    lista_cabecalho.pop(32)
    aux  = lista_resultados.pop(32).split("/") #SYN/FIN_pkts_sent_b2a
    val1=aux[0]
    val2=aux[1]
    lista_cabecalho.append("SYN_pkts_sent_b2a")
    lista_cabecalho.append("FIN_pkts_sent_b2a")
    lista_resultados.append(val1)
    lista_resultados.append(val2)

    lista_cabecalho.pop(32)
    aux = lista_resultados.pop(32).split("/") #req_1323_ws/ts_a2b
    val1=aux[0]
    val2=aux[1]
    lista_cabecalho.append("req_1323_ws_a2b")
    lista_cabecalho.append("req_1323_ts_a2b")
    lista_resultados.append(val1)
    lista_resultados.append(val2)

    lista_cabecalho.pop(32)
    aux = lista_resultados.pop(32).split("/") #req_1323_ws/ts_a2b
    val1=aux[0]
    val2=aux[1]
    lista_cabecalho.append("req_1323_ws_b2a")
    lista_cabecalho.append("req_1323_ts_b2a")
    lista_resultados.append(val1)
    lista_resultados.append(val2)

    # fim da separacao em 2

    # se for one-way, remover todos os b2a ou a2b, conforme arquivo de entrada;
    if is_two_way == False:
        remover_host='b2a'
        for i in range(len(lista_resultados)-1, -1, -1):
            if remover_host in lista_cabecalho[i]:
                lista_cabecalho.pop(i)
                lista_resultados.pop(i)

    # remover o ultimo valor q eh vazio, por causa da virgula após o último valor valido  0,123,3123,
    lista_cabecalho.pop()
    lista_resultados.pop()

    if is_debug:
        print(' -- tcptrace -- ')
        for i in range(0, len(lista_cabecalho)):
            print('[',i,'] ', lista_cabecalho[i] , ' = ',  lista_resultados[i])
        print('tcptrace lista_cabecalho: ', len(lista_cabecalho))
        print('tcptrace lista_resultados: ', len(lista_resultados))

    return (lista_resultados, lista_cabecalho)


def tratar_saida(saida_tcptrace):
    
    lista_colunas, lista_resultados = saida_tcptrace.split(";") 
    lista_colunas = lista_colunas.split(",")
    lista_resultados = lista_resultados.replace("NA", "0")
    lista_resultados = lista_resultados.split(",")
    
    lista_colunas.pop(-1) #remover o ultimo ,
    lista_resultados.pop(-1)
    
    
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
    
    return lista_resultados, lista_colunas

entrada_arquivo_pcap= "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/qos/nonvpn_facebook_audio/flow_total_facebook_audio2a_TCP_173.252.100.27_131.202.240.150_443_56404.pcap"
is_two_way=False
host_a="173.252.100.27"
for i in range(1):
    
    with Pool(processes=4, maxtasksperchild=1) as pool:
        result = pool.map(wrapper_extrair_features, [entrada_arquivo_pcap])[0]
    
    print(result)
    tratar_saida(result)
# saida = tratar_tcptrace(result, host_a, is_two_way=is_two_way)
# resultados_tcptrace = saida[0]
# colunas_tcptrace = saida[1]

# print(f"results len({len(resultados_tcptrace)}): \n{resultados_tcptrace} ")
# print(f"columns len({len(colunas_tcptrace)}): \n{colunas_tcptrace} ")