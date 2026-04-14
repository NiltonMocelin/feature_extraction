import ctypes
import _ctypes

# Exemplo de declaração da função C (pode estar em um .h ou no próprio .pyx)
cdef extern from *:
    """
    #include <stdio.h>
    void minha_funcao_c_real(const char* nome) {
        printf("C recebeu o arquivo: %s\\n", nome);
    }
    """
    void minha_funcao_c_real(const char* nome)

encoded_strings = []

def chamar_processamento(str file_name):
    # 1. Converte a string Python (unicode) para bytes UTF-8
    # É essencial manter essa variável 'py_bytes' viva enquanto o C usa o ponteiro
    py_bytes = file_name.encode('utf-8')
    
    # 2. Faz o cast para char* (ponteiro C)
    cdef char* c_file_name = py_bytes
    
    # 3. Chama a função C
    minha_funcao_c_real(c_file_name)



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

def list_to_c_char_array(py_list_of_strings):
    encoded_strings = [s.encode('utf-8') for s in py_list_of_strings]
    c_char_p_array_type = (ctypes.c_char_p * len(encoded_strings))
    c_array_instance = c_char_p_array_type(*encoded_strings)
    return c_array_instance

def unload_library(lib_tcptrace):
    lib_handle = lib_tcptrace._handle
    _ctypes.dlclose(lib_handle) #destrutor
    return
def load_library():
    lib_tcptrace = ctypes.CDLL(f'./libtcptrace.so')
    lib_tcptrace.extrair_features.restype = ctypes.c_char_p
    lib_tcptrace.extrair_features.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_char_p)]
    return lib_tcptrace

def fechar(lib_tcptrace):
    lib_tcptrace.chamar_depois_terminar_manual()
    return

# Carrega a biblioteca
lib_tcptrace = ctypes.CDLL('./libtcptrace.so')

# --- CONFIGURAÇÃO CRUCIAL ---
# Informamos ao ctypes que a main2 retorna um ponteiro de string (char *)
lib_tcptrace.main2.restype = ctypes.c_char_p
# Informamos que os argumentos são (int, char**)
lib_tcptrace.main2.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_char_p)]
# ----------------------------

entrada_arquivo_pcap = "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_audio/flow_total_VOIP_gate_facebook_Audio_TCP_198.52.200.39_10.0.2.15_443_55139.pcap"
lista_params = ["tcptrace", "-l", "-r", "-W", "-u", "--csv", entrada_arquivo_pcap]
# Converte a lista para o formato C
c_array = list_to_c_char_array(lista_params)
for i in range(100):
    # Chama a função
    # O ctypes.c_char_p automaticamente converte o retorno de char* para bytes do Python
    print(f"passando {len(lista_params)} {lista_params}")
    resultado_bytes = lib_tcptrace.main2(len(lista_params), c_array)
    resultado=""
    if resultado_bytes:
        # Converte de bytes para string (UTF-8)
        resultado = resultado_bytes.decode('utf-8')
        # print(f'printando resultado:\n{resultado}')

        colunas, resultados = resultado.split(';')
        # print(f'colunas: {colunas}')
        # print(f'resultados: {resultados}')
    else:
        print("A função retornou NULL")

    print(resultado)
    lib_tcptrace.reset_argv_parser()
# fechar(lib_tcptrace)
    # unload_library(lib_tcptrace)
    # lib_tcptrace = load_library()
    
    # cabe, vals = tratar_tcptrace(resultado)
    # print(f'cab{cabe}')# - len vals{len(vals)}')





