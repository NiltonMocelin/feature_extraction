# cython: language_level=3
import numpy as np
cimport numpy as np
cimport cython
from libc.string cimport memcpy

# Constantes de rede
cdef unsigned char TCP_PROTO = 6
cdef unsigned char UDP_PROTO = 17
DEF PRECISAO = 6

# Estruturas C para mapeamento direto (Zero-copy)
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

# Auxiliares para cálculo de flags TCP via Bitwise
@cython.inline
cdef bint check_tcp_flag(unsigned char flags_byte, unsigned char mask):
    return (flags_byte & mask) != 0

# Máscaras de Flags TCP
cdef unsigned char TH_FIN = 0x01
cdef unsigned char TH_SYN = 0x02

@cython.boundscheck(False)
@cython.wraparound(False)
cdef np.ndarray[np.float64_t, ndim=1] get_IATs_raw(list timestamps):
    cdef int n = len(timestamps)
    if n < 2:
        return np.array([], dtype=np.float64)
    
    cdef np.ndarray[np.float64_t, ndim=1] lista_IAT = np.empty(n - 1, dtype=np.float64)
    cdef double prev_time = timestamps[0]
    cdef double current_time
    
    for i in range(1, n):
        current_time = timestamps[i]
        lista_IAT[i-1] = current_time - prev_time
        prev_time = current_time
    return lista_IAT

@cython.boundscheck(False)
@cython.wraparound(False)
cpdef tuple calcular_estatisticas_raw(list bloco_raw_pkts, str prefix, str proto_str, int offset):
    """
    offset: para o linktype, em caso seja um raw pkt sem eth
    bloco_raw_pkts: Lista de tuplas (timestamp, bytes_do_pacote)
    """
    if not bloco_raw_pkts:
        return ([], [])

    cdef int n = len(bloco_raw_pkts)
    cdef list timestamps = [p[0] for p in bloco_raw_pkts]
    cdef np.ndarray[np.float64_t, ndim=1] lista_IATs = get_IATs_raw(timestamps)
    
    if lista_IATs.size == 0:
        return ([], [])

    # Estatísticas IAT com NumPy
    cdef double iat_mean = lista_IATs.mean()
    cdef np.ndarray[np.float64_t, ndim=1] q = np.percentile(lista_IATs, [25, 50, 75])
    
    # Cálculos de Bulk e Duration usando ponteiros brutos
    cdef double conn_duration = Duration_Connection_raw(bloco_raw_pkts, proto_str, offset)
    if conn_duration == 0.0:
        return ([], [])
    cdef tuple transitions_aux = No_transitions_bulk_raw(bloco_raw_pkts, proto_str, offset)
    cdef int nro_transitions= transitions_aux[0]
    cdef int time_spent_in_bulk_mode =  transitions_aux[1]
    cdef double time_idle = Time_spent_idle_raw(lista_IATs)

    cdef list lista_cabecalhos = [
        f"{prefix}_below_mean_IAT", f"{prefix}_above_mean_IAT", f"{prefix}_sum_IAT",
        f"{prefix}_std_IAT", f"{prefix}_max_IAT", f"{prefix}_var_IAT",
        f"{prefix}_q3_IAT", f"{prefix}_q1_IAT", f"{prefix}_min_IAT",
        f"{prefix}_med_IAT", f"{prefix}_mean_IAT", f"{prefix}_idle_Percent_of_time",
        f"{prefix}_Time_spent_idle", f"{prefix}_bulk_Percent_of_time_spent",
        f"{prefix}_Duration_Connection_duration", f"{prefix}_Time_spent_in_bulk",
        f"{prefix}_No_transitions_bulkTrans"
    ]

    cdef list lista_resultados = [
        np.sum(lista_IATs < iat_mean),
        np.sum(lista_IATs >= iat_mean),
        lista_IATs.sum(), lista_IATs.std(), lista_IATs.max(), lista_IATs.var(),
        q[2], q[0], lista_IATs.min(), q[1], iat_mean,
        (time_idle / conn_duration) if conn_duration > 0 else 0,
        time_idle,
        (time_spent_in_bulk_mode / conn_duration) if conn_duration > 0 else 0,
        conn_duration, time_spent_in_bulk_mode, nro_transitions
    ]

    return (lista_cabecalhos, lista_resultados)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double Duration_Connection_raw(list bloco, str proto_str, int offset):
    cdef int n = len(bloco)
    if n == 0: return 0
    cdef double t_start = bloco[0][0]
    cdef double t_end = bloco[n-1][0]
    
    cdef unsigned char* data
    cdef ip_header* ip
    cdef tcp_header* tcp
    cdef int ihl

    if proto_str == "TCP":
        for i in range(n):
            data = <unsigned char*>bloco[i][1]
            # Offset Ethernet(14) + IP IHL
            ip = <ip_header*>(data + offset)
            ihl = (ip.v_ihl & 0x0F) * 4
            tcp = <tcp_header*>(data + offset + ihl)
            if check_tcp_flag(tcp.flags, TH_FIN):
                t_end = bloco[i][0]
                break
                
    return round(t_end - t_start, PRECISAO)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef tuple No_transitions_bulk_raw(list bloco, str proto_str, int offset):
    if not bloco: return (0.0,0.0)
    
    cdef unsigned char* data = <unsigned char*>bloco[0][1]
    cdef ip_header* ip = <ip_header*>(data + offset)
    cdef int ihl = (ip.v_ihl & 0x0F) * 4
    cdef unsigned int sip = ip.saddr
    
    # Assumindo estrutura simplificada para porta (primeiros 2 bytes do transporte)
    cdef unsigned short sport = (<unsigned short*>(data + offset + ihl))[0]
    
    cdef int contador_pacotes = 0
    cdef int contador_bulk = 0
    cdef int payload_len
    
    time_spent_bulk_mode = 0.0
    prev_time = bloco[0][0] #ts do primeiro pacote
    for i in range(len(bloco)):
        data = <unsigned char*>bloco[i][1]
        ip = <ip_header*>(data + offset)
        ihl = (ip.v_ihl & 0x0F) * 4
        payload_len = 0
        # Payload len = Total IP Len - IHL - Transport Header (fixo 20 p/ simplificar ou dinâmico)
        if ip.protocol == TCP_PROTO:
            tcp = <tcp_header*>(data + offset + ihl)
            payload_len = len(bloco[i][1]) - offset - ihl - ((tcp.doff_res >> 4) * 4)
        elif ip.protocol == UDP_PROTO:
            payload_len = len(bloco[i][1]) - offset - ihl - 8 # UDP header é fixo de 8 bytes

        if payload_len < 1:
            contador_pacotes = 0
            prev_time = bloco[i][0]
            continue
            
        if ip.saddr == sip: # Mesma direção
            contador_pacotes += 1
        else:
            contador_pacotes -= 1
            
        if contador_pacotes > 3 or contador_pacotes < -3:
            contador_bulk += 1
            time_spent_bulk_mode += bloco[i][0] - prev_time
            prev_time = bloco[i][0]
            
    return (contador_bulk, time_spent_bulk_mode)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double Time_spent_idle_raw(double[:] iats):
    cdef double idle = 0
    cdef int i
    for i in range(iats.shape[0]):
        if iats[i] >= 2.0:
            idle += iats[i]
    return idle

# [As outras funções seguem a mesma lógica de conversão de ponteiros...]