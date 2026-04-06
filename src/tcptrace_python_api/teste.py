import ctypes

def list_to_c_char_array(py_list_of_strings):
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

lib_tcptrace = ctypes.CDLL('./libtcptrace.so')

entrada_arquivo_pcap = "/mnt/Secundario/Doutorado/classificacao_trafego_2/material_traffic_classification2/analiseQoS/minha_ferramenta/folder_pcap/flow_total_facebook_audio1a_TCP_173.252.100.27_131.202.240.150_443_56404.pcap"
lista_params = ["tcptrace", "-l", "-r", "-W", "-u", "--csv", entrada_arquivo_pcap]

c_array, c_ptr_ptr = list_to_c_char_array(lista_params)

# resultado = lib_tcptrace.ProcessFile(entrada_arquivo_pcap)
resultado = lib_tcptrace.main(len(lista_params), c_ptr_ptr)
print(resultado)


# from subprocess import Popen, PIPE

# out = Popen(
#     args="nm ./libtcptrace.so", 
#     shell=True, 
#     stdout=PIPE
# ).communicate()[0].decode("utf-8")

# attrs = [
#     i.split(" ")[-1].replace("\r", "") 
#     for i in out.split("\n") if " T " in i
# ]

# functions = [i for i in attrs if hasattr(lib_tcptrace, i)]

# print(functions)