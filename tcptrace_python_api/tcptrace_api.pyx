# Importa a assinatura do seu arquivo .h
cdef extern from *:
    """
    // 1. Forçamos as macros que o tcptrace.h usa para pular os erros "OOPS"
    #ifndef SIZEOF_UNSIGNED_INT
        #define SIZEOF_UNSIGNED_INT 4
    #endif
    #ifndef SIZEOF_UNSIGNED_SHORT
        #define SIZEOF_UNSIGNED_SHORT 2
    #endif
    #ifndef SIZEOF_UNSIGNED_LONG
        #define SIZEOF_UNSIGNED_LONG 8
    #endif

    // 2. Definimos os tipos básicos que o header espera encontrar já prontos
    typedef unsigned int u_int32;
    typedef unsigned short u_int16;
    
    // 3. Não vamos definir 'seglen' ou 'Bool' aqui, 
    // deixaremos o tcptrace.h fazer isso sozinho para evitar o erro de "conflicting types"
    """
    pass

cdef extern from "tcptrace.h":
    char* extrair_features(char* argv)


# analisador.pyx
cdef extern from "sys/mman.h" nogil:
    int memfd_create(const char *name, unsigned int flags)

# No topo do arquivo, adicione/corrija as importações de C
cdef extern from "unistd.h" nogil:
    ssize_t write(int fd, const void *buf, size_t count)
    int close(int fd)
    # off_t costuma ser long ou long long, dependendo da arquitetura
    long lseek(int fd, long offset, int whence)

# Definição manual da constante caso não queira importar do fcntl
DEF SEEK_SET = 0

import struct

def preparar_buffer_pcap(global_header, lista_ts_pkts):
    # Iniciamos com o Global Header (24 bytes)
    buffer_pcap = bytearray(global_header)

    for ts, pkt in lista_ts_pkts:
        # 1. Preparar o Packet Header (16 bytes)
        ts_sec = int(ts)
        ts_usec = int((ts % 1) * 1000000)
        caplen = len(pkt)
        
        # Formato: timestamp segundos, microssegundos, tamanho capturado, tamanho original
        pkt_header = struct.pack("<IIII", ts_sec, ts_usec, caplen, caplen)
        
        # 2. Adicionar header e dados ao buffer
        buffer_pcap.extend(pkt_header)
        buffer_pcap.extend(pkt)
        
    return buffer_pcap


def preparar_buffer_pcap_sem_header(lista_ts_pkts, linktype):
    #o dummy eth eh adicionado em caso de nao ter cabecalho eth na captura, o que pode ocorrer - pode dar problema para alguns casos
    # Forçamos o Header Global do PCAP Clássico (24 bytes)
    # Magic: 0xa1b2c3d4, Ver: 2.4, Snaplen: 65535, Network: 1 (Ethernet)
    global_header = struct.pack("<IHHIIII", 0xa1b2c3d4, 2, 4, 0, 0, 65535, 1) # ultimo eh o linktype
    
    buffer_pcap = bytearray(global_header)

    for ts, pkt in lista_ts_pkts:
        ts_sec = int(ts)
        ts_usec = int((ts % 1) * 1000000)
        caplen = len(pkt)
        if linktype != 1: # dummy eth
            caplen += 14

        # Header de Pacote Clássico (16 bytes)
        pkt_header = struct.pack("<IIII", ts_sec, ts_usec, caplen, caplen)
        
        buffer_pcap.extend(pkt_header)
        if linktype !=1: #dummy eth
            buffer_pcap.extend(b'\x00'*12 + b'\x08\x00' + pkt)
        else:
            buffer_pcap.extend( pkt)
        
    return buffer_pcap


def processar_em_memoria(unsigned char[:] pcap_data):
    """
    Recebe um buffer bytes/numpy contendo o PCAP completo (Header + Pacotes)
    e cria o link virtual para o tcptrace.
    """
    cdef int fd = memfd_create("pcap_buffer", 0)
    if fd == -1:
        raise OSError("Falha ao criar memfd")

    cdef str saida = ""
    try:
        # Escreve o buffer inteiro na RAM
        write(fd, &pcap_data[0], pcap_data.shape[0])
        lseek(fd, 0, 0)
        # Gera o caminho virtual
        mem_path = f"/proc/self/fd/{fd}"
        
        # Aqui você chama a sua função que executa o tcptrace
        # Ex: subprocess.run(["tcptrace", mem_path])
        saida = wrapper_extrair_features(mem_path)
    finally:
        close(fd)
    
    return saida

def wrapper_extrair_features(str file_name):
    # 1. Converte a string Python para bytes (UTF-8)
    # Precisamos manter 'py_bytes' em uma variável para o Python não deletar da memória
    py_bytes = file_name.encode('utf-8')
    
    # 2. Obtém o ponteiro C (char*) a partir dos bytes
    cdef char* c_file_name = py_bytes
    
    # 3. Chama a função C e recebe o char* de retorno
    cdef char* resultado_c = extrair_features(c_file_name)
    
    # 4. Converte o resultado de volta para uma string Python (opcional)
    if resultado_c == NULL:
        return ""
        
    return resultado_c.decode('utf-8')