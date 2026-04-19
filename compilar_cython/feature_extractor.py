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
import tcptrace_api #import processar_em_memoria, preparar_buffer_pcap_sem_header


import sys
import os
sys.path.append(f'{os.getcwd()}/src')
# import tcptrace_api #import processar_em_memoria, preparar_buffer_pcap_sem_header

import operador_pypcap as opcap


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

def process_bloco_pypcap(tupla_param):
    # print(lista_ts_raw_pkts[0])
    parametros= tupla_param[0]
    filepath=         parametros['filepath']
    lista_ts_raw_pkts = tupla_param[1]
    linktype=         parametros['linktype']
    id_bloco=         0
    host_a=           parametros['host_a']
    host_b=           parametros['host_b']
    port_a=           parametros['port_a']
    port_b=           parametros['port_b']
    proto=            parametros['proto']
    service_class=    parametros['service_class']
    app_class=        parametros['app_class']
    is_two_way=       parametros['is_two_way']
    is_tcptrace=      parametros['is_tcptrace']
    # print(f"a")
    if lista_ts_raw_pkts == []:
        print(f"[lista_pkts vazia] {len(lista_ts_raw_pkts)}")
        return []
        # return ([],[])
    
    offset = 0 # linktype 101
    if linktype == 1: #eth
        offset = 14
    elif linktype == 113: # linux ssl
        offset = 16

    filename = filepath.split('/')[-1]

    # aqui que eu vou decidir quem eh a e quem eh b

    host_a = None
    host_b = None
        
    lista_ts_raw_pkts_ab = []
    lista_ts_raw_pkts_ba = []

    for ts, pkt in lista_ts_raw_pkts:
        pkt_dict = opcap.montar_pkt_to_dict(pkt, linktype)
        if pkt_dict!= None:
            if 'ipv4' in pkt_dict:
                if not host_a:
                    host_a = pkt_dict['ipv4']['src_ip']
                    host_b = pkt_dict['ipv4']['dst_ip']
                    
                if  pkt_dict['ipv4']['src_ip'] == host_a:
                    lista_ts_raw_pkts_ab.append((ts,pkt))
                else:
                    lista_ts_raw_pkts_ba.append((ts,pkt))
            else:
                print("Erro ao processar bloco: sem cabecalho ipv4")
                return []
                # return ([],[])
        else:
            print("Erro ao processar bloco: erro ao montar pkt_dict")
            return []
        
    resultados_saida = [filepath, service_class, app_class, host_a, host_b, port_a, port_b, id_bloco, 0 if proto=='tcp' else 1, 0, 0, 0, 0]
    # colunas_saida = ['filename', 'service_class', 'app_class', 'host_a', 'host_b', 'a_port', 'b_port', 'id_bloco', 'proto', 'bandwidth', 'delay', 'jitter', 'loss']

    # print(f"b")
    res = calcular_time_features(lista_ts_raw_pkts_ab, "ab_", proto, offset)
    # print(f"res calcular_time_features: {res}")
    # colunas_saida.extend(res[0])
    resultados_saida.extend(res[1])
    res = calcular_pkt_features(lista_ts_raw_pkts_ab, "ab_", proto, offset)
    # colunas_saida.extend(res[0])
    # print(f"res calcular_pkt_features: {res}")
    resultados_saida.extend(res[1])
    lista_ts_raw_pkts_ab.clear()
    # print(f"c")
    if is_two_way:
        res = calcular_time_features(lista_ts_raw_pkts_ba, "ba_", proto, offset)
        # colunas_saida.extend(res[0])
        resultados_saida.extend(res[1])
        res = calcular_time_features(lista_ts_raw_pkts, "total_", proto, offset)
        # colunas_saida.extend(res[0])
        resultados_saida.extend(res[1])
    lista_ts_raw_pkts_ba.clear()
    # print(f"d")
    if is_tcptrace:

        bufferr = tcptrace_api.preparar_buffer_pcap_sem_header(lista_ts_raw_pkts, linktype)

        resultados_valores=tcptrace_api.processar_em_memoria(bufferr) # nao precisamos utilizar multiprocessing pq agora ele usa fork

        colunas_tcptrace, resultados_tcptrace = tratar_tcptrace(resultados_valores)
        if colunas_tcptrace == [] or resultados_tcptrace == []:
            # opcap.criar_pcap_com_header_proprio(f'erro_tcptrace_{filename}', lista_ts_raw_pkts, linktype=linktype) # esse abre no tcptrace
            escreverArquivo('', f"erro_tcptrace_{filename}", bufferr) # analisar pq o tcptrace nao retorna nada com esse arquivo!
            print(f"error: tcptrace retornou {resultados_valores} : {filepath} len lista_raw_pkts {len(lista_ts_raw_pkts)}")

        resultados_saida.extend(resultados_tcptrace)
    
    # return (colunas_saida, resultados_saida)
    return modelar_dados_csv(resultados_saida)

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

def escreverArquivo(folder_name, file_name, resultados_str):

    file_path = os.path.join(folder_name, file_name)
    
    with open(file_path, 'wb') as file:
        file.write(resultados_str)
        
    return