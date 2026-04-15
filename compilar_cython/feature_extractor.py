#01/09

# Retirado de moore::: file:///D:/artigo_traffic_classification2/material/moore2005discriminators.pdf
# server_port, client_port, min_IAT, q1_IAT, med_IAT, mean_IAT, q3_IAT, max_IAT, var_IAT, min_data_wire, q1_data_wire, med_data_wire, mean_data_wire.

# lista de portas de serviço IANA: https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers

# obs: se atentar a necessidade de normalizar os valores

## OTIMIZACOES:
# - adaptamos para cython
# - ainda lento, proximo passo, usar vector<string> ao inves de list, e usar bibliotecas lib c para realizar print ou write, pois conversao de tipos C para python eh lenta

from TIME_features_cython import calcular_estatisticas_raw as calcular_time_features
from PKT_features_cython import calcular_estatisticas_raw as calcular_pkt_features

import sys
import os
sys.path.append(f'{os.getcwd()}/src')
import tcptrace_api #import processar_em_memoria, preparar_buffer_pcap_sem_header

from multiprocessing import Pool

import operador_pypcap as opcap


def tratar_tcptrace(saida_tcptrace):
    
    lista_colunas, lista_resultados = saida_tcptrace.split(";") 
    lista_colunas = lista_colunas.split(",")
    lista_resultados = lista_resultados.replace("NA", "0")
    lista_resultados = lista_resultados.replace("Y", "1")
    lista_resultados = lista_resultados.replace("N", "0")
    lista_resultados = lista_resultados.split(",")
    
    if len(lista_colunas) != len(lista_resultados):
        print(f"Erro: o número de colunas ({len(lista_colunas)}) não corresponde ao número de resultados ({len(lista_resultados)}).")
        return ([], [])
    
    if len(lista_colunas) < 2 or len(lista_resultados) < 2:
        print("Erro: listas vazias ")
        return ([], [])
    
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
    
    return lista_colunas, lista_resultados

def process_bloco_pcap(filename, id_bloco, host_a, proto, service_class, app_class, bloco_total, is_two_ways):# -> tuple[list, list]:
    """     id_bloco = contador de blocos para o subfluxo
            class_label = como sera rotulado
            proto = protocolo (TCP ou UDP)
            two_ways = True or False -> são pacotes apenas de ida ou tem ida e volta ? (existem features específicas para ida e para volta)
            bloco_total = bloco com todos os pacotes do bloco
            bloco_ab/ba = caso queira adicinonar informacoes sobre os pacote two ways
    """
    res = None
    port_a = 0
    port_b = 0
    host_b =''

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

    resultados_saida = [filename, service_class, app_class, host_a, host_b, port_a, port_b, id_bloco, 0 if proto=='TCP' else 1, 0, 0, 0, 0]
    colunas_saida = ['filename', 'service_class', 'app_class', 'host_a', 'host_b', 'a_port', 'b_port', 'id_bloco', 'proto', 'bandwidth', 'delay', 'jitter', 'loss']

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

def process_bloco_pypcap(filepath, lista_ts_raw_pkts, linktype, id_bloco, host_a,host_b, port_a, port_b, proto, service_class, app_class, is_two_way, is_tcptrace):
    if lista_ts_raw_pkts == []:
        return ([],[])
    
    offset = 0 # linktype 101
    if linktype == 1: #eth
        offset = 14
    elif linktype == 113: # linux ssl
        offset = 16
        
    resultados_saida = [filepath, service_class, app_class, host_a, host_b, port_a, port_b, id_bloco, 0 if proto=='TCP' else 1, 0, 0, 0, 0]
    colunas_saida = ['filename', 'service_class', 'app_class', 'host_a', 'host_b', 'a_port', 'b_port', 'id_bloco', 'proto', 'bandwidth', 'delay', 'jitter', 'loss']

    lista_ts_raw_pkts_ab = [(ts,pkt) for ts,pkt in lista_ts_raw_pkts if opcap.montar_pkt_to_dict(pkt, linktype)['ipv4']['src_ip']== host_a]
    res = calcular_time_features(lista_ts_raw_pkts_ab, "ab_", proto, offset)
    # print(f"res calcular_time_features: {res}")
    colunas_saida.extend(res[0])
    resultados_saida.extend(res[1])
    res = calcular_pkt_features(lista_ts_raw_pkts_ab, "ab_", proto, offset)
    colunas_saida.extend(res[0])
    resultados_saida.extend(res[1])
    
    if is_two_way:
        res = calcular_time_features([(ts,pkt) for ts,pkt in lista_ts_raw_pkts if opcap.montar_pkt_to_dict(pkt, linktype)['ipv4']['src_ip']!= host_a], "ba_", proto, offset)
        colunas_saida.extend(res[0])
        resultados_saida.extend(res[1])
        res = calcular_time_features(lista_ts_raw_pkts, "total_", proto, offset)
        colunas_saida.extend(res[0])
        resultados_saida.extend(res[1])
        
    if is_tcptrace:
        bufferr = tcptrace_api.preparar_buffer_pcap_sem_header(lista_ts_raw_pkts, linktype)
        
        result= ""
        with Pool(processes=1, maxtasksperchild=1) as pool:
            result = pool.map(tcptrace_api.processar_em_memoria, [bufferr])[0].strip()
   
        colunas_tcptrace, resultados_tcptrace = tratar_tcptrace(result)

        #juntando as listas de colunas e resultados
        colunas_saida.extend(colunas_tcptrace)
        resultados_saida.extend(resultados_tcptrace)
    
    return (colunas_saida, resultados_saida)

def process_pcap(id_bloco, host_a, proto, service_class, app_class, entrada_arquivo_pcap, bloco_pacotes, is_two_way, is_tcptrace):
    if not bloco_pacotes:
        return ([], [])

    # chamar o processador de blocos
    saida = process_bloco_pcap(filename=entrada_arquivo_pcap, id_bloco=id_bloco, host_a=host_a, proto=proto, service_class= service_class, app_class= app_class, bloco_total=bloco_pacotes, is_two_ways= is_two_way)
    lista_colunas_saida = saida[0]
    lista_resultados_saida = saida[1]
    result = ""
    resultados_tcptrace = []
    colunas_tcptrace = []
 
    if is_tcptrace:

        result= ""
        with Pool(processes=4, maxtasksperchild=1) as pool:
            result = pool.map(wrapper_extrair_features, [entrada_arquivo_pcap])[0]
   
        colunas_tcptrace, resultados_tcptrace = tratar_tcptrace(result)
        # result = subprocess.run(["tcptrace", "-l", "-r", "-W", "-u", "--csv", entrada_arquivo_pcap], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        # saida = tratar_tcptrace(result, host_a, is_two_way=is_two_way)
        
        #juntando as listas de colunas e resultados
        lista_colunas_saida.extend(colunas_tcptrace)
        lista_resultados_saida.extend(resultados_tcptrace)
        # print(f"resultado{resultados_tcptrace} {colunas_tcptrace}")

    # processar as duas saidas
    return (lista_colunas_saida, lista_resultados_saida)