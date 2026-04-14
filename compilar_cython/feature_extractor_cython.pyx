#01/09

# Retirado de moore::: file:///D:/artigo_traffic_classification2/material/moore2005discriminators.pdf
# server_port, client_port, min_IAT, q1_IAT, med_IAT, mean_IAT, q3_IAT, max_IAT, var_IAT, min_data_wire, q1_data_wire, med_data_wire, mean_data_wire.

# lista de portas de serviço IANA: https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers

# obs: se atentar a necessidade de normalizar os valores

## OTIMIZACOES:
# - adaptamos para cython
# - ainda lento, proximo passo, usar vector<string> ao inves de list, e usar bibliotecas lib c para realizar print ou write, pois conversao de tipos C para python eh lenta

from TIME_features_cython cimport calcular_tudo as calcular_time_features
from PKT_features_cython cimport calcular_tudo as calcular_pkt_features

from tcptrace_python_api.tcptrace_api import TCPTraceAPI
import cython

# cdef tuple _get_col_val_tcptrace(str saida_tcptrace):
#     cdef list linhas = saida_tcptrace.split("\n")

#     # tcptrace gera muitas linhas, encontrar quando comeca a falar sobre o cabecalho + quebra de linha+ dados
#     cdef int index_cabecalho = 0
#     for linha in linhas:
#         if 'conn_#' in linha:
#             break
#         index_cabecalho += 1

#     cdef list lista_cabecalho = linhas[index_cabecalho].replace(" ", "").split(',')
#     # ajustar valores numericos: N/Y por = 0/1 , NA por = 0 ,  N por = 0, Y por = 1
#     cdef list lista_resultados = linhas[index_cabecalho + 2].replace(" ", "").replace("NA", "0").replace("N",
#                                                                                                          "0").replace(
#         "Y", "1").split(',')
#     lista_cabecalho.pop(-1)  #remover o ultimo ,
#     lista_resultados.pop(-1)
#     return (lista_cabecalho, lista_resultados)

# @cython.boundscheck(False)
# @cython.wraparound(False)
# cdef tuple tratar_tcptrace(str saida_tcptrace, str host_a, bint is_two_way= True, bint is_debug= False):
#     """ Aqui tem que modifinar manualmente conforme quer o resultado:
#     Entrada: tcptrace csv -> Separa a saída do tcptrace em uma lista de strings. Ajusta valores como N/Y e NA para numérico"""

#     cdef tuple saida = _get_col_val_tcptrace(saida_tcptrace)
#     cdef list lista_cabecalho = saida[0]
#     cdef list lista_resultados = saida[1]
#     cdef str remover_host
#     cdef str tcptrace_host_a
#     cdef str tcptrace_host_b
#     cdef list aux
#     cdef str val1
#     cdef str val2

#     if lista_resultados[2] == host_a: # se o host_b do tcptrace for igual ao host_a do extrator de features, entao precisamos trocar o host_b <-> host_a do tcptrace
#         saida_tcptrace=saida_tcptrace.replace("a2b", "x2y")
#         saida_tcptrace=saida_tcptrace.replace("b2a", "a2b")
#         saida_tcptrace=saida_tcptrace.replace("x2y", "b2a")
#         saida = _get_col_val_tcptrace(saida_tcptrace) # isso eh pq nao sabemos como o tcptrace escolhe o host a (na verdade eh por ordem, mas agora nao lembro pq deixei isso)
#         lista_cabecalho = saida[0]
#         lista_resultados = saida[1]

#     #quero remover esses campos (sao os primeiros):: {'conn_#', 'host_a', 'host_b', 'port_a', 'port_b', first_packet, last_packet}
#     lista_resultados.pop(0) # con
#     tcptrace_host_a = lista_resultados.pop(0) # host_a
#     tcptrace_host_b = lista_resultados.pop(0) # host_b
#     lista_resultados.pop(0) # port_a
#     lista_resultados.pop(0) # port_b
#     lista_resultados.pop(0) # first_packet
#     lista_resultados.pop(0) # last_packet

#     lista_cabecalho.pop(0) # con
#     lista_cabecalho.pop(0) # host_a
#     lista_cabecalho.pop(0) # host_b
#     lista_cabecalho.pop(0) # port_a
#     lista_cabecalho.pop(0) # port_b
#     lista_cabecalho.pop(0) # first_packet
#     lista_cabecalho.pop(0) # last_packet

#     lista_cabecalho.pop(32)
#     aux = lista_resultados.pop(32).split("/")
#     val1=aux[0]
#     val2=aux[1]
#     lista_cabecalho.append("SYN_pkts_sent_a2b")
#     lista_cabecalho.append("FIN_pkts_sent_a2b")
#     lista_resultados.append(val1)
#     lista_resultados.append(val2)

#     lista_cabecalho.pop(32)
#     aux  = lista_resultados.pop(32).split("/") #SYN/FIN_pkts_sent_b2a
#     val1=aux[0]
#     val2=aux[1]
#     lista_cabecalho.append("SYN_pkts_sent_b2a")
#     lista_cabecalho.append("FIN_pkts_sent_b2a")
#     lista_resultados.append(val1)
#     lista_resultados.append(val2)

#     lista_cabecalho.pop(32)
#     aux = lista_resultados.pop(32).split("/") #req_1323_ws/ts_a2b
#     val1=aux[0]
#     val2=aux[1]
#     lista_cabecalho.append("req_1323_ws_a2b")
#     lista_cabecalho.append("req_1323_ts_a2b")
#     lista_resultados.append(val1)
#     lista_resultados.append(val2)

#     lista_cabecalho.pop(32)
#     aux = lista_resultados.pop(32).split("/") #req_1323_ws/ts_a2b
#     val1=aux[0]
#     val2=aux[1]
#     lista_cabecalho.append("req_1323_ws_b2a")
#     lista_cabecalho.append("req_1323_ts_b2a")
#     lista_resultados.append(val1)
#     lista_resultados.append(val2)

#     # fim da separacao em 2

#     # se for one-way, remover todos os b2a ou a2b, conforme arquivo de entrada;
#     if is_two_way == False:
#         remover_host='b2a'
#         for i in range(len(lista_resultados)-1, -1, -1):
#             if remover_host in lista_cabecalho[i]:
#                 lista_cabecalho.pop(i)
#                 lista_resultados.pop(i)

#     # remover o ultimo valor q eh vazio, por causa da virgula após o último valor valido  0,123,3123,
#     lista_cabecalho.pop()
#     lista_resultados.pop()

#     if is_debug:
#         print(' -- tcptrace -- ')
#         for i in range(0, len(lista_cabecalho)):
#             print('[',i,'] ', lista_cabecalho[i] , ' = ',  lista_resultados[i])
#         print('tcptrace lista_cabecalho: ', len(lista_cabecalho))
#         print('tcptrace lista_resultados: ', len(lista_resultados))

#     return (lista_resultados, lista_cabecalho)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef tuple tratar_tcptrace(str saida_tcptrace,str host_a, bint is_two_way):

    cdef list lista_aux = saida_tcptrace.split(";")
    if len(lista_aux) != 2:
        print("Erro ao tratar saida tcptrace")
        return ([],[])

    cdef list lista_cabecalhos = lista_aux[0].split(',')
    cdef list lista_resultados = lista_aux[1].split(',')
    # print(f"tcptrace: cab {len(lista_cabecalhos)} - res {len(lista_resultados)}")
    # print(f"lista_cab{lista_cabecalhos}")
    if len(lista_cabecalhos) != len(lista_resultados):
        print(f"Erro - tcptrace tamanhos diferentes ! cab {len(lista_cabecalhos)} - res {len(lista_resultados)}")
        return ([],[])

    return (lista_cabecalhos, lista_resultados)
    for col, val in zip(lista_cabecalhos, lista_resultados):
        print(f"[{col}]={val}")

    cdef list nova_lista_resultados = []
    cdef int indice 
    cdef list valores

    lista_cabecalhos.pop(0)#host_a
    lista_cabecalhos.pop(0)#host_b
    lista_cabecalhos.pop(0)#port_a
    lista_cabecalhos.pop(0)#port_b
    lista_cabecalhos.pop(-1)#,nada

    lista_resultados.pop(0)#host_a
    lista_resultados.pop(0)#host_b
    lista_resultados.pop(0)#port_a
    lista_resultados.pop(0)#port_b
    lista_resultados.pop(-1)#,nada

    cdef list lista_alterar_com_barra = [
        "a2b_syn_fin_pkts_sent", "b2a_syn_fin_pkts_sent", "b2a_req_1323_ws_ts",
        "a2b_req_1323_ws_ts" ]
    cdef dict dict_alteracoes_com_barra = {"a2b_syn_fin_pkts_sent":["a2b_syn_pkts_sent", "a2b_fin_pkts_sent"],
    "b2a_syn_fin_pkts_sent":["b2a_syn_pkts_sent", "b2a_fin_pkts_sent"],
    "a2b_req_1323_ws_ts":["a2b_req_1323_ws", "a2b_req_1323_ts"],
    "b2a_req_1323_ws_ts":["b2a_req_1323_ws", "b2a_req_1323_ts"]
    }

    for item in lista_alterar_com_barra:

        try:
            indice = lista_cabecalhos.index(item)
            valores = lista_resultados[indice].split("/")
            lista_cabecalhos.pop(indice)
            lista_cabecalhos += dict_alteracoes_com_barra[item]
            lista_resultados.pop(indice)
            lista_resultados.append(valores[0])
            lista_resultados.append(valores[1])
        except:
            print(f"ERRO-f-extractor-cython: {item} nao encontrado em cabecalhos")

    print(f"cabecalhos: {lista_cabecalhos}")
    print(f"result:{lista_resultados}")

    for i,val in enumerate(lista_resultados):
        print(f"fixing[{i}]={val}")
        if 'N' in val:
            nova_lista_resultados.append(0)
            continue
            # lista_resultados[i] = 0
        elif 'Y' in val:
            # lista_resultados[i] = 1
            nova_lista_resultados.append(1)
            continue
        if '.' in val:
            # lista_resultados[i] = float(lista_resultados[i])
            nova_lista_resultados.append(float(lista_resultados[i]))
        else:
            # lista_resultados[i] = int(lista_resultados[i])
            nova_lista_resultados.append(int(lista_resultados[i]))   

    return (lista_cabecalhos, lista_resultados)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef tuple process_bloco(str filename, int id_bloco, str host_a, str proto, str service_class, str app_class, list bloco_total, bint is_two_ways):# -> tuple[list, list]:
    """     id_bloco = contador de blocos para o subfluxo
            class_label = como sera rotulado
            proto = protocolo (TCP ou UDP)
            two_ways = True or False -> são pacotes apenas de ida ou tem ida e volta ? (existem features específicas para ida e para volta)
            bloco_total = bloco com todos os pacotes do bloco
            bloco_ab/ba = caso queira adicinonar informacoes sobre os pacote two ways
    """
    cdef tuple res
    cdef int port_a
    cdef int port_b
    cdef str host_b =''

    if not bloco_total[0].haslayer('IP') or not bloco_total[0].haslayer(proto):
        return ([], [])

    if bloco_total[0].getlayer('IP').src == host_a:
        host_b = bloco_total[0].getlayer('IP').dst
        port_a = bloco_total[0].getlayer(proto).sport
        port_b = bloco_total[0].getlayer(proto).dport
    else:
        host_b = bloco_total[0].getlayer('IP').src
        port_a = bloco_total[0].getlayer(proto).dport
        port_b = bloco_total[0].getlayer(proto).sport

    cdef list resultados_saida = [filename, service_class, app_class, host_a, host_b, port_a, port_b, id_bloco, 0 if proto=='TCP' else 1, 0, 0, 0, 0]
    cdef list colunas_saida = ['filename', 'service_class', 'app_class', 'host_a', 'host_b', 'a_port', 'b_port', 'id_bloco', 'proto', 'bandwidth', 'delay', 'jitter', 'loss']

    res = calcular_time_features([pkt for pkt in bloco_total if pkt.getlayer('IP').src == host_a], "ab_", proto)
    colunas_saida.extend(res[0])
    resultados_saida.extend(res[1])
    res = calcular_pkt_features([pkt for pkt in bloco_total if pkt.getlayer('IP').src == host_a], "ab_", proto)
    colunas_saida.extend(res[0])
    resultados_saida.extend(res[1])
    
    if is_two_ways:
        res = calcular_time_features([pkt for pkt in bloco_total if pkt.getlayer('IP').src != host_a], "ba_", proto)
        colunas_saida.extend(res[0])
        resultados_saida.extend(res[1])
        res = calcular_time_features(bloco_total, "total_", proto)
        colunas_saida.extend(res[0])
        resultados_saida.extend(res[1])

    return (colunas_saida, resultados_saida)

@cython.boundscheck(False)
@cython.wraparound(False)
cpdef tuple process_pcap(int id_bloco, str host_a, str proto, str service_class, str app_class, str entrada_arquivo_pcap, list bloco_pacotes, bint is_two_way, bint is_tcptrace):
    if not bloco_pacotes:
        return ([], [])

    # chamar o processador de blocos
    cdef tuple saida = process_bloco(filename=entrada_arquivo_pcap, id_bloco=id_bloco, host_a=host_a, proto=proto, service_class= service_class, app_class= app_class, bloco_total=bloco_pacotes, is_two_ways= is_two_way)
    cdef list lista_colunas_saida = saida[0]
    cdef list lista_resultados_saida = saida[1]
    cdef str result = ""
    cdef object tcptrace
    cdef list resultados_tcptrace
    cdef list colunas_tcptrace
 
    if is_tcptrace:
        tcptrace = TCPTraceAPI()
        result = tcptrace.tcptrace(entrada_arquivo_pcap)
        
        # result = subprocess.run(["tcptrace", "-l", "-r", "-W", "-u", "--csv", entrada_arquivo_pcap], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        saida = tratar_tcptrace(result, host_a, is_two_way=is_two_way)
        print(saida)
        resultados_tcptrace = saida[0]
        colunas_tcptrace = saida[1]

        #juntando as listas de colunas e resultados
        lista_colunas_saida.extend(colunas_tcptrace)
        lista_resultados_saida.extend(resultados_tcptrace)
        # print(f"resultado{resultados_tcptrace} {colunas_tcptrace}")

    # processar as duas saidas
    return (lista_colunas_saida, lista_resultados_saida)