# Se as funções de utils (calcular_mean, etc) não forem Cython, 
# o ganho será limitado a esta classe.
import numpy as np
cimport cython
cimport numpy as np

#usar assim2 pkt.getlayer('IP')

# Definindo a precisão como uma constante de compilação
DEF PRECISAO = 6

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double[:] get_IATs(list bloco):
    if bloco == []:
        return np.array([], dtype=np.float64)
    cdef double prev_time = bloco[0].time
    cdef list lista_IAT = []
    cdef double current_time
    for pkt in bloco:
        current_time = float(pkt.time)
        lista_IAT.append(round(current_time - prev_time, PRECISAO))
        prev_time = current_time
    return np.array(lista_IAT, dtype=np.float64)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef tuple calcular_tudo(list bloco_pacotes, str prefix, str proto):
    if bloco_pacotes == []:
        return ([], [])
    cdef np.ndarray[np.float64_t, ndim=1] lista_IATs = np.asarray(get_IATs(bloco_pacotes))
    cdef np.ndarray[np.float64_t, ndim=1] q = np.percentile(
        lista_IATs, [25, 50, 75], overwrite_input=True
    )
    cdef double connection_duration = Duration_Connection_duration(proto, bloco_pacotes)

    cdef list lista_cabecalhos = [f"{prefix}_below_mean_IAT",  f"{prefix}_above_mean_IAT",
    f"{prefix}_sum_IAT", f"{prefix}_std_IAT", f"{prefix}_max_IAT", f"{prefix}_var_IAT" 
    f"{prefix}_q3_IAT", f"{prefix}_q1_IAT", f"{prefix}_min_IAT",
    f"{prefix}_med_IAT", f"{prefix}_mean_IAT", f"{prefix}_idle_Percent_of_time",
    f"{prefix}_Time_spent_idle", f"{prefix}_bulk_Percent_of_time_spent", 
    f"{prefix}_Duration_Connection_duration", f"{prefix}_Time_spent_in_bulk", 
    f"{prefix}_No_transitions_bulkTrans"]

    cdef list lista_resultados = [below_mean_IAT(lista_IATs),  above_mean_IAT(lista_IATs),
    lista_IATs.sum(), lista_IATs.std(), lista_IATs.max(), lista_IATs.var(),
    q[2], q[0], lista_IATs.min(),
    q[1], lista_IATs.mean(), idle_Percent_of_time(lista_IATs, connection_duration),
    Time_spent_idle(lista_IATs), bulk_Percent_of_time_spent(proto, bloco_pacotes), 
    connection_duration, Time_spent_in_bulk(proto, bloco_pacotes), 
    No_transitions_bulkTrans(proto, bloco_pacotes)
    ]

    return (lista_cabecalhos, lista_resultados)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double below_mean_IAT(double [:] lista_IATs):
    cdef np.ndarray[np.float64_t, ndim=1] array_IATs = np.asarray(lista_IATs)
    cdef int count = 0
    cdef double mean = array_IATs.mean()
    for val in array_IATs:
        if val < mean:
            count += 1
    return count

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double above_mean_IAT(double [:] lista_IATs):
    cdef np.ndarray[np.float64_t, ndim=1] array_IATs = np.asarray(lista_IATs)
    cdef int count = 0
    cdef double mean = array_IATs.mean()
    for val in array_IATs:
        if val >= mean:
            count += 1
    return count

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double calcular_quartile(double [:] lista_valores, double quartile):
    cdef np.ndarray[np.float64_t, ndim=1] array_valores = np.asarray(lista_valores)
    cdef double[:] dados_ordenados = np.sort(array_valores)
    cdef int indice_q1 = <int>(quartile * (len(dados_ordenados) - 1))
    cdef double q1 = dados_ordenados[indice_q1]
    return q1

@cython.boundscheck(False)
@cython.wraparound(False)
cdef int No_transitions_bulkTrans(str proto, list bloco_pacotes):
    """210 No. transitions bulk/trans The number of transitions between transaction mode and bulk transfer mode,
    where bulk transfer mode is defined as the time when there are more than three successive packets in
    the same direction without any packets carrying data in the other direction"""
    if bloco_pacotes == []:
        return 0
    cdef str sip = bloco_pacotes[0].src
    cdef int sport = bloco_pacotes[0][proto].sport
    cdef int contador_pacotes = 0
    cdef int contador_bulk = 0
    if not bloco_pacotes[0].haslayer(proto):
        return contador_bulk
    for pkt in bloco_pacotes:
        try:
            if len(pkt.getlayer(proto).payload)  < 1:
                contador_pacotes = 0
                continue
            if pkt.getlayer('IP').src == sip and pkt.getlayer(proto).sport == sport:
                contador_pacotes += 1
            else:
                contador_pacotes -= 1
            if contador_pacotes > 3 or contador_pacotes < -3:
                contador_bulk+=1
        except:
            continue
    return contador_bulk

# o que é bulk transfer mode: is defined as the time when there are more than three successive packets in
    # the same direction without any packets carrying data in the other direction"""
@cython.boundscheck(False)
@cython.wraparound(False)
cdef double Time_spent_in_bulk(str proto, list bloco_total):
    """211 Time spent in bulk Amount of time spent in bulk transfer mode -- silent pq tem outra funcao que utiliza o resultado"""
    if bloco_total == []:
        return 0
    cdef double prev_time = bloco_total[0].time
    cdef int contador_pacotes = 0
    cdef double time_spent_bulk_mode = 0.0
    cdef str sip = bloco_total[0].src
    cdef int sport = bloco_total[0][proto].sport
    if not bloco_total[0].haslayer(proto):
        return 0
    for pkt in bloco_total:
        if len(pkt[proto].payload)  < 1:
            contador_pacotes = 0
            prev_time = float(pkt.time)
            continue
        if pkt.getlayer('IP').src == sip and pkt.getlayer(proto).sport == sport:
            contador_pacotes += 1
        else:
            contador_pacotes -= 1
        
        if contador_pacotes > 3 or contador_pacotes < -3:
            time_spent_bulk_mode += float(pkt.time - prev_time)
            prev_time = float(pkt.time)
    return round(time_spent_bulk_mode, PRECISAO)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double Duration_Connection_duration(str proto, list bloco_total):
    """212 Duration Connection duration"""
    if bloco_total == []:
        return 0
    cdef int n = len(bloco_total)
    cdef time_i = bloco_total[0].time
    cdef time_f = bloco_total[n-1].time

    if proto != 'TCP':
        return round(float(time_f - time_i), PRECISAO)

    for pkt in bloco_total:
        if check_FYN_flag(pkt):
            time_f = pkt.time
            return round(float(time_f - time_i), PRECISAO)
    
    return round(float(time_f - time_i), PRECISAO)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double bulk_Percent_of_time_spent(str proto, list bloco_total):
    """213 % bulk Percent of time spent in bulk transfer"""
    if bloco_total == []:
        return 0
    cdef int n = len(bloco_total)
    cdef double duration_connection = float(bloco_total[n-1].time - bloco_total[0].time)
    if duration_connection == 0:
        return 0
    cdef double time_bulk = Time_spent_in_bulk(proto, bloco_total)
    cdef double resultado =  time_bulk/ duration_connection
    return resultado

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double Time_spent_idle(double[:] lista_IAT_total):
    """214 Time spent idle The time spent idle (where idle time is the accumulation of all periods of 2 seconds or greater when no
    packet was seen in either direction)"""
    cdef np.ndarray[np.float64_t, ndim=1] array_IAT_total = np.asarray(lista_IAT_total)
    cdef double time_idle = 0.0
    for val in array_IAT_total:
        if val >= 2.0:
            time_idle += val
    return time_idle

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double idle_Percent_of_time(double[:] lista_IAT_total, double duration_connection):
    """215 % idle Percent of time spent idle"""
    if duration_connection == 0:
        return 0
    cdef double time_idle = Time_spent_idle(lista_IAT_total)
    if time_idle == 0:
        return 0    
    return round(time_idle/duration_connection, PRECISAO)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double Time_since_last_connection(list bloco_total, str proto):
    """209 Time since last connection Time since the last connection between these hosts"""
    # O tempo entre um FYN e o próximo SYN ACK ? Se tiver vários, tirar a media OU pegar só a última ocorrencia. 
    cdef list lista_tempos = []
    cdef double prev_tempo = 0
    cdef object pkt
    cdef object pkt2
    cdef int n = len(bloco_total)
    cdef count_connections = 0
    if proto != 'TCP':
        return 0
    for i in range(len(bloco_total)):
        pkt = bloco_total[i]
        if check_FYN_flag(pkt):
            prev_tempo = float(pkt.time)
        
        for j in range(i+1, len(bloco_total)):
            pkt2 = bloco_total[j]
            if check_SYN_flag(pkt2):
                lista_tempos.append(float(pkt2.time-prev_tempo))
                count_connections+=1

    if lista_tempos == []:
        return 0
    return lista_tempos[count_connections-1]

cdef check_SYN_flag(object pkt):
    if 'S' in pkt.getlayer('TCP').flags:
        return True
    
    return False

cdef check_FYN_flag(object pkt):
    if 'F' in pkt.getlayer('TCP').flags:
        return True
    
    return False