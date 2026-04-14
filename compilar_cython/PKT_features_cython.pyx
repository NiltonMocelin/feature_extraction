# cython: language_level=3
import numpy as np
cimport numpy as np
cimport cython
from libc.string cimport memcpy, memset

# Headers de rede em C para acesso ultra-rápido
cdef extern from "arpa/inet.h":
    unsigned short ntohs(unsigned short netshort)

cdef struct eth_header:
    unsigned char h_dest[6]
    unsigned char h_source[6]
    unsigned short ether_type

cdef struct ip_header:
    unsigned char v_ihl
    unsigned char tos
    unsigned short total_len
    unsigned short id
    unsigned short frag_off
    unsigned char ttl
    unsigned char protocol
    unsigned short checksum
    unsigned int saddr
    unsigned int daddr

cdef struct transport_header:
    unsigned short source
    unsigned short dest
    # UDP e TCP compartilham os primeiros 4 bytes para portas

cdef struct tcp_header:
    unsigned short src_port
    unsigned short dst_port
    unsigned int seq_num
    unsigned int ack_num
    unsigned char doff_res
    unsigned char flags
    unsigned short window
    unsigned short checksum
    unsigned short urg_ptr

@cython.boundscheck(False)
@cython.wraparound(False)
def obter_tamanhos_exatos(unsigned char* pkt_data, int pkt_len, int proto):
    # 1. Calcular offset do IP (padrão Ethernet 14 bytes)
    cdef int ip_ihl = (pkt_data[14] & 0x0F) * 4
    cdef int transport_offset = 14 + ip_ihl
    
    cdef int header_size = 0
    cdef int payload_size = 0
    cdef tcp_header* tcp
    
    # --- Lógica para UDP ---
    if proto == 17: 
        header_size = 8
        # No UDP, o payload é o tamanho total menos os 8 bytes do header
        payload_size = pkt_len - transport_offset - header_size
        
    # --- Lógica para TCP ---
    elif proto == 6:
        tcp = <tcp_header*>(pkt_data + transport_offset)
        
        # Extraímos os 4 bits superiores (shift 4 para a direita)
        # Multiplicamos por 4 para converter palavras de 32 bits em bytes
        header_size = (tcp.doff_res >> 4) * 4
        
        # O payload é o que sobra após o cabeçalho variável
        payload_size = pkt_len - transport_offset - header_size
        
    return {
        "header_bytes": header_size,
        "payload_bytes": max(0, payload_size)
    }

@cython.boundscheck(False)
@cython.wraparound(False)
cdef int below(double [:] lista_valores, double valor):
    cdef np.ndarray[np.float64_t, ndim=1] array_valores = np.asarray(lista_valores)
    cdef int count = (array_valores < valor).sum()
    return count

@cython.boundscheck(False)
@cython.wraparound(False)
cdef int above(double [:] lista_valores, double valor):
    cdef np.ndarray[np.float64_t, ndim=1] array_valores = np.asarray(lista_valores)
    cdef int count = (array_valores >= valor).sum()
    return count

@cython.boundscheck(False)
@cython.wraparound(False)
cdef int between(double [:] lista_valores, double valor_e, double valor_d):
    cdef np.ndarray[np.float64_t, ndim=1] array_valores = np.asarray(lista_valores)
    cdef int count = ((array_valores >= valor_e) & (array_valores <= valor_d)).sum()
    return count


@cython.boundscheck(False)
@cython.wraparound(False)
cpdef tuple calcular_estatisticas_raw(list lista_raw_pkts, str prefix, str proto_name, int offset):
    """
    lista_raw_pkts: lista de tuplas (timestamp, bytes_brutos)
    """
    cdef int n = len(lista_raw_pkts)
    if n == 0: return ([], [])

    cdef list lista_cabecalhos = [f"{prefix}_below_mean_len_pkt",  f"{prefix}_above_mean_len_pkt",
    f"{prefix}_sum_len_pkt", f"{prefix}_std_len_pkt", f"{prefix}_max_len_pkt", f"{prefix}_var_len_pkt",
    f"{prefix}_q3_len_pkt", f"{prefix}_q1_len_pkt", f"{prefix}_min_len_pkt",
    f"{prefix}_med_len_pkt", f"{prefix}_mean_len_pkt",
    #genericos
    f"{prefix}_pkts_per_second", f"{prefix}_bytes_per_secs", f"{prefix}_number_pkts", 
    f"{prefix}_number_pkts_above_128bytes", f"{prefix}_number_pkts_below_128bytes", 
    f"{prefix}_number_pkts_between_128_1024bytes", f"{prefix}_number_pkts_above_1024bytes",
    f"{prefix}_number_pkts_below_1024bytes",
    #header_ip ?
    f"{prefix}_below_mean_len_header_ip",  f"{prefix}_above_mean_len_header_ip",
    f"{prefix}_sum_len_header_ip", f"{prefix}_std_len_header_ip", f"{prefix}_max_len_header_ip", f"{prefix}_var_len_header_ip",
    f"{prefix}_q3_len_header_ip", f"{prefix}_q1_len_header_ip", f"{prefix}_min_len_header_ip",
    f"{prefix}_med_len_header_ip", f"{prefix}_mean_len_header_ip",
    #ip
    f"{prefix}_below_mean_len_ip",  f"{prefix}_above_mean_len_ip",
    f"{prefix}_sum_len_ip", f"{prefix}_std_len_ip", f"{prefix}_max_len_ip", f"{prefix}_var_len_ip",
    f"{prefix}_q3_len_ip", f"{prefix}_q1_len_ip", f"{prefix}_min_len_ip",
    f"{prefix}_med_len_ip", f"{prefix}_mean_len_ip",
    #proto
    f"{prefix}_below_mean_len_proto",  f"{prefix}_above_mean_len_proto",
    f"{prefix}_sum_len_proto", f"{prefix}_std_len_proto", f"{prefix}_max_len_proto", f"{prefix}_var_len_proto",
    f"{prefix}_q3_len_proto", f"{prefix}_q1_len_proto", f"{prefix}_min_len_proto",
    f"{prefix}_med_len_proto", f"{prefix}_mean_len_proto",
    #dados
    f"{prefix}_below_mean_len_payload",  f"{prefix}_above_mean_len_payload",
    f"{prefix}_sum_len_payload", f"{prefix}_std_len_payload", f"{prefix}_max_len_payload", f"{prefix}_var_len_payload",
    f"{prefix}_q3_len_payload", f"{prefix}_q1_len_payload", f"{prefix}_min_len_payload",
    f"{prefix}_med_len_payload", f"{prefix}_mean_len_payload"
    ]

    # MemoryViews para cálculos NumPy rápidos
    cdef np.ndarray[np.float64_t, ndim=1] len_pkt = np.zeros(n, dtype=np.float64)
    cdef np.ndarray[np.float64_t, ndim=1] len_ip_header = np.zeros(n, dtype=np.float64)
    cdef np.ndarray[np.float64_t, ndim=1] len_ip_total = np.zeros(n, dtype=np.float64)
    cdef np.ndarray[np.float64_t, ndim=1] len_proto = np.zeros(n, dtype=np.float64)
    cdef np.ndarray[np.float64_t, ndim=1] len_payload = np.zeros(n, dtype=np.float64)
    cdef np.ndarray[np.float64_t, ndim=1] lista_resultados = np.zeros(63, dtype=np.float64)
    cdef np.ndarray[np.float64_t, ndim=1] lista_aux_3pos = np.zeros(3, dtype=np.float64)

    cdef unsigned char* data
    cdef eth_header* eth
    cdef eth_header stack_eth
    cdef ip_header* ip
    cdef int ihl, ip_t_len, proto_offset, proto_len, payload_len
    cdef double ts_first = lista_raw_pkts[0][0]
    cdef double ts_last = lista_raw_pkts[n-1][0]
    cdef double duracao = ts_last - ts_first
    cdef tcp_header* tcp;
    if duracao == 0.0:
        return ([],[])

    # --- LOOP DE EXTRAÇÃO (SEM SCAPY) ---
    for i in range(n):
        ts, pkt_bytes = lista_raw_pkts[i]
        data = <unsigned char*>pkt_bytes
        len_pkt[i] = len(pkt_bytes)

        # Ethernet
        if offset != 14: #linktype !=1
            memset(&stack_eth, 0, sizeof(eth_header))
            stack_eth.ether_type = 0x0008  # No x86, para resultar em 0x0800 na rede usamos htons ou invertemos
            eth = &stack_eth
        else:
            eth = <eth_header*>data
        if ntohs(eth.ether_type) != 0x0800: continue # Ignora se não for IPv4

        # IP
        ip = <ip_header*>(data + offset)
        ihl = (ip.v_ihl & 0x0F) * 4
        ip_t_len = ntohs(ip.total_len)
        
        len_ip_header[i] = ihl
        len_ip_total[i] = ip_t_len

        # Transporte (TCP/UDP)
        proto_offset = offset + ihl
        # Simplificação: assume que o protocolo solicitado é o que está no pacote
        proto_len = ip_t_len - ihl
        len_proto[i] = proto_len
        
        transport_header_size = 0
        payload_size = 0
        # ! arrumar ! o len_proto e o len_payload
        if proto_name == 'tcp' or proto_name == 'TCP':
            tcp = <tcp_header*>(data + proto_offset)
            # Extraímos os 4 bits superiores (shift 4 para a direita)
            # Multiplicamos por 4 para converter palavras de 32 bits em bytes
            transport_header_size = (tcp.doff_res >> 4) * 4

            # O payload é o que sobra após o cabeçalho variável
            payload_size = len(pkt_bytes) - proto_offset - transport_header_size
        elif proto_name == 'udp' or proto_name == 'UDP':
            transport_header_size = 8
            # No UDP, o payload é o tamanho total menos os 8 bytes do header
            payload_size = len(pkt_bytes) - proto_offset - transport_header_size

        len_payload[i] = payload_size

    # --- CÁLCULOS ESTATÍSTICOS (Reaproveitando sua lógica) ---
    # Aqui você chamaria uma função auxiliar para preencher o array lista_resultados
    # usando len_pkt, len_ip_total, etc., exatamente como no seu código original.
    
    # lista_resultados[0] = duracao
    # lista_resultados[1] = len(lista_raw_pkts)
    # lista_resultados[2] = len_pkt.sum()
    lista_aux_3pos =  np.percentile(
        len_pkt, [25, 50, 75], overwrite_input=True
    )
    lista_resultados[0] = below(len_pkt, lista_aux_3pos[1])
    lista_resultados[1] = above(len_pkt, lista_aux_3pos[1])
    lista_resultados[2] = len_pkt.sum()
    lista_resultados[3] = len_pkt.std()
    lista_resultados[4] = len_pkt.max()
    lista_resultados[5] = len_pkt.var()
    lista_resultados[6] = lista_aux_3pos[2]
    lista_resultados[7] = lista_aux_3pos[0]
    lista_resultados[8] = len_pkt.min()
    lista_resultados[9] = lista_aux_3pos[1]
    lista_resultados[10] = len_pkt.mean()

    lista_resultados[13]= len(lista_raw_pkts)
    lista_resultados[11]=round(lista_resultados[13]/duracao, 6)
    lista_resultados[12]=round(lista_resultados[2]/duracao, 6)
    lista_resultados[14]=above(len_pkt, 128)
    lista_resultados[15]=below(len_pkt, 128)
    lista_resultados[16]=between(len_pkt, 128, 1024)
    lista_resultados[17]=above(len_pkt, 1024)
    lista_resultados[18]=below(len_pkt, 1024)

    # len_header_ip --
    lista_aux_3pos =  np.percentile(
        len_ip_header, [25, 50, 75], overwrite_input=True
    )
    lista_resultados[19] = below(len_ip_header, lista_aux_3pos[1])
    lista_resultados[20] = above(len_ip_header, lista_aux_3pos[1])
    lista_resultados[21] = len_ip_header.sum()
    lista_resultados[22] = len_ip_header.std()
    lista_resultados[23] = len_ip_header.max()
    lista_resultados[24] = len_ip_header.var()
    lista_resultados[25] = lista_aux_3pos[2]
    lista_resultados[26] = lista_aux_3pos[0]
    lista_resultados[27] = len_ip_header.min()
    lista_resultados[28] = lista_aux_3pos[1]
    lista_resultados[29] = len_ip_header.mean()

    # len_ip --
    lista_aux_3pos =  np.percentile(
        len_ip_total, [25, 50, 75], overwrite_input=True
    )
    lista_resultados[30] = below(len_ip_total, lista_aux_3pos[1])
    lista_resultados[31] = above(len_ip_total, lista_aux_3pos[1])
    lista_resultados[32] = len_ip_total.sum()
    lista_resultados[33] = len_ip_total.std()
    lista_resultados[34] = len_ip_total.max()
    lista_resultados[35] = len_ip_total.var()
    lista_resultados[36] = lista_aux_3pos[2]
    lista_resultados[37] = lista_aux_3pos[0]
    lista_resultados[38] = len_ip_total.min()
    lista_resultados[39] = lista_aux_3pos[1]
    lista_resultados[40] = len_ip_total.mean() 

    # ! arrumar ! o len_proto e o len_payload
    # len_proto --
    lista_aux_3pos =  np.percentile(
        len_proto, [25, 50, 75], overwrite_input=True
    )
    lista_resultados[41] = below(len_proto, lista_aux_3pos[1])
    lista_resultados[42] = above(len_proto, lista_aux_3pos[1])
    lista_resultados[43] = len_proto.sum()
    lista_resultados[44] = len_proto.std()
    lista_resultados[45] = len_proto.max()
    lista_resultados[46] = len_proto.var()
    lista_resultados[47] = lista_aux_3pos[2]
    lista_resultados[48] = lista_aux_3pos[0]
    lista_resultados[49] = len_proto.min()
    lista_resultados[50] = lista_aux_3pos[1]
    lista_resultados[51] = len_proto.mean() 

    # len_payload --
    lista_aux_3pos =  np.percentile(
        len_payload, [25, 50, 75], overwrite_input=True
    )
    lista_resultados[52] = below(len_payload, lista_aux_3pos[1])
    lista_resultados[53] = above(len_payload, lista_aux_3pos[1])
    lista_resultados[54] = len_payload.sum()
    lista_resultados[55] = len_payload.std()
    lista_resultados[56] = len_payload.max()
    lista_resultados[57] = len_payload.var()
    lista_resultados[58] = lista_aux_3pos[2]
    lista_resultados[59] = lista_aux_3pos[0]
    lista_resultados[60] = len_payload.min()
    lista_resultados[61] = lista_aux_3pos[1]
    lista_resultados[62] = len_payload.mean() 

    # [O restante da sua lógica de percentis e lista_resultados entra aqui]
    
    return (lista_cabecalhos, lista_resultados) # Retornar cabecalhos e resultados preenchidos

