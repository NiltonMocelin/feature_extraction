from multiprocessing import Pool
import sys
# Add the directory containing the file to sys.path
sys.path.append('/media/nnmoc/Data/material_traffic_classification2/extracao_features/extrator_cython/src')

import tcptrace_api
import operador_pypcap as opcap

def tratar_tcptrace(saida_tcptrace):

    lista_aux = saida_tcptrace.split(";")
    if len(lista_aux) != 2:
        print("Erro ao tratar saida tcptrace")
        return ([],[])

    lista_cabecalhos = lista_aux[0].split(',')
    lista_resultados = lista_aux[1].split(',')

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

    lista_alterar_com_barra = [
        "a2b_syn_fin_pkts_sent", "b2a_syn_fin_pkts_sent", "b2a_req_1323_ws_ts",
        "a2b_req_1323_ws_ts" ]
    dict_alteracoes_com_barra = {"a2b_syn_fin_pkts_sent":["a2b_syn_pkts_sent", "a2b_fin_pkts_sent"],
    "b2a_syn_fin_pkts_sent":["b2a_syn_pkts_sent", "b2a_fin_pkts_sent"],
    "a2b_req_1323_ws_ts":["a2b_req_1323_ws", "a2b_req_1323_ts"],
    "b2a_req_1323_ws_ts":["b2a_req_1323_ws", "b2a_req_1323_ts"]
    }

    for item in lista_alterar_com_barra:

        try:
            indice = lista_cabecalhos.index(item)
            valor_um, valor_dois = lista_resultados[indice].split("/")
            lista_cabecalhos.pop(indice)
            lista_cabecalhos += dict_alteracoes_com_barra[item]
            lista_resultados.pop(indice)
            lista_resultados.append(valor_um)
            lista_resultados.append(valor_dois)
        except:
            print(f"ERRO-f-extractor-cython: {item} nao encontrado em cabecalhos")

    for i,val in enumerate(lista_resultados):
        if 'N' in val:
            lista_resultados[i] = 0
        elif 'Y' in val:
            lista_resultados[i] = 1
        if '.' in val:
            lista_resultados[i] = float(lista_resultados[i])
        else:
            lista_resultados[i] = int(lista_resultados[i])   

    return (lista_cabecalhos, lista_resultados)

# O nome do arquivo que você quer passar para o C
file_name = "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_audio/flow_total_VOIP_gate_facebook_Audio_TCP_198.52.200.39_10.0.2.15_443_55139.pcap"

header_pcapfile = opcap.get_pcap_global_header(file_name)
pkts_pcapfile = opcap.ler_binario_direto(file_name, -1)
i=0
try:
    # for ts, pkt in pkts_pcapfile:
    #     i+=1
        # print(f'[{i}]: {opcap.montar_pkt(pkt)}')
    # Chamando a função que criamos no .pyx
    # Se você usou o nome 'wrapper_extrair_features' no seu código:
    # for i in range(100):
        
    #     resultado = tcptrace_api.wrapper_extrair_features(file_name)
    #     print(f"Resultado do tcptrace: {resultado}")
    
    bufferr = tcptrace_api.preparar_buffer_pcap_sem_header(pkts_pcapfile)
    saida = tcptrace_api.processar_em_memoria(bufferr)
    # opcap.criar_pcap_com_header_proprio('arquivo_teste.pcap', pkts_pcapfile)
    print(f"saida tcptrace: {tratar_tcptrace(saida)}")
except Exception as e:
    print(f"Erro ao chamar a função: {e}")
    
    # temos duas opcoes - chamadas independentes ou multiprocess com pool de processos. A primeira é mais simples, mas a segunda pode ser mais eficiente se você tiver muitos arquivos para processar. Vou mostrar um exemplo de chamadas independentes, e depois um exemplo usando multiprocessing.