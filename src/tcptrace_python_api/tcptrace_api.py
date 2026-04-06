##################################################################
######################## TCPTRACE API #############################
import ctypes
# No Linux, dlclose remove a lib da memória se o refcount chegar a 0
import _ctypes
import gc

class TCPTraceAPI():
    def __init__(self):
        # as variaveis nao estao sendo limpas infelizmente... por isso vou ter que recarregar a biblioteca cada vez
        self.lib_tcptrace = ctypes.CDLL('./tcptrace_python_api/libtcptrace.so')
        self.lib_tcptrace.main.restype = ctypes.c_char_p
        pass

    # CALL: 
    # entrada_arquivo_pcap = "/mnt/Secundario/Doutorado/classificacao_trafego_2/material_traffic_classification2/analiseQoS/minha_ferramenta/folder_pcap/flow_total_facebook_audio1a_TCP_173.252.100.27_131.202.240.150_443_56404.pcap"
    # lista_params = ["tcptrace", "-l", "-r", "-W", "-u", "--csv", entrada_arquivo_pcap]
    # c_array, c_ptr_ptr = list_to_c_char_array(lista_params)
    # resultado = lib_tcptrace.main(len(lista_params), c_ptr_ptr)
    # print(resultado)

    def list_to_c_char_array(self, py_list_of_strings):
        """
        Converts a Python list of strings to a ctypes array of c_char_p.
        """
        # 1. Encode Python strings to bytes (necessary for C compatibility)
        #    Python 3 strings are Unicode; C char* expects bytes (e.g., utf-8 encoded)
        encoded_strings = [s.encode('utf-8') for s in py_list_of_strings]

        # 2. Define the C array type: c_char_p multiplied by the number of strings
        c_char_p_array_type = (ctypes.c_char_p * len(encoded_strings))

        # 3. Create an instance of the C array type from the encoded bytes
        #    The * unpacks the list as arguments to the array constructor
        c_array_instance = c_char_p_array_type(*encoded_strings)

        # Optional: Cast the array to a simple pointer to pointer (char**)
        # This is often what a C function signature expects
        c_char_p_p = ctypes.cast(c_array_instance, ctypes.POINTER(ctypes.c_char_p))

        return c_array_instance, c_char_p_p

    ######################## TCPTRACE API #############################
    ########################################################################
    def tcptrace(self, pcap_file_path):
        lista_params=["tcptrace", "-l", "-r", "-W", "-u", "--csv"]
        # print("AA")
        nova_lista=[]
        nova_lista += lista_params
        nova_lista.append(pcap_file_path)
        # lista_params.append(pcap_file_path)

        c_array, c_ptr_ptr = self.list_to_c_char_array(nova_lista) 
        # print(f"AA: {pcap_file_path}")
        # print(nova_lista)
        resultado_bytes = self.lib_tcptrace.main(len(nova_lista), c_ptr_ptr)
        # print(f"resultado obtido bytes {resultado_bytes}")
        resultado = resultado_bytes.decode('utf-8')
        # print(f"resultado obtido decode {resultado}")

        ## carregando a biblioteca - modo lento
        # Pega o endereço interno para fechar manualmente (hack necessário no Linux)
        lib_handle = self.lib_tcptrace._handle
        _ctypes.dlclose(lib_handle) #destrutor
        gc.collect()
        self.lib_tcptrace = ctypes.CDLL('./tcptrace_python_api/libtcptrace.so')
        self.lib_tcptrace.main.restype = ctypes.c_char_p
        ##

        return resultado
    
# if __name__ == "__main__":
#     tcptraceapi = TCPTraceAPI()

#     entrada_arquivo_pcap = "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/qos/nonvpn_facebook_audio/flow_total_facebook_audio4_TCP_173.252.110.27_131.202.240.101_443_47093.pcap"
#     result = tcptraceapi.tcptrace(entrada_arquivo_pcap)
#     print(f"python resultado obtido: {result}")
#     pass