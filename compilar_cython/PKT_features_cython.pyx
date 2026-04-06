import numpy as np
cimport numpy as np
cimport cython

DEF PRECISAO = 6
#cpdef aparece para o python, cdef puramente C -> usar apenas internamente no mesmo arquivo pyx
@cython.boundscheck(False)
@cython.wraparound(False)
cdef tuple calcular_tudo(list bloco_pacotes, str prefix, str proto):
    cdef n = len(bloco_pacotes)
    if n ==0 or not bloco_pacotes[0].haslayer('IP') or not bloco_pacotes[0].haslayer(proto):
        return ([],[])
    #pkt
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

    cdef double[:] q
    cdef int index = 0
    assert len(lista_cabecalhos) == 63
    cdef double[:] lista_resultados = np.empty(63, dtype=np.float64)  # 5 camadas de 11 + 8 genericos
    #len_pkt

    cdef np.ndarray[np.float64_t, ndim=1] lista_valores = np.array([len(pkt) for pkt in bloco_pacotes], dtype=np.float64)
    q = np.percentile(
        lista_valores, [25, 50, 75], overwrite_input=True
    )
    cdef double duracao = bloco_pacotes[n-1].time - bloco_pacotes[0].time
    cdef int number_pkts = len(bloco_pacotes)
    cdef int soma_bytes = lista_valores.sum()

    lista_resultados[index] = below(lista_valores, q[1]); index+=1
    lista_resultados[index] = above(lista_valores, q[1]); index+=1
    lista_resultados[index] = soma_bytes; index += 1
    lista_resultados[index] = lista_valores.std(); index += 1
    lista_resultados[index] = lista_valores.max(); index += 1

    lista_resultados[index] = lista_valores.var();    index += 1
    lista_resultados[index] = q[2];  index += 1
    lista_resultados[index] = q[0] ; index += 1
    lista_resultados[index] = lista_valores.min(); index += 1
    lista_resultados[index] = q[1]; index += 1
    lista_resultados[index] = lista_valores.mean();    index += 1

    lista_resultados[index] =round(number_pkts/duracao,PRECISAO) if duracao > 0 else number_pkts ;    index += 1
    lista_resultados[index] =round(soma_bytes/duracao,PRECISAO) if duracao > 0 else soma_bytes ;    index += 1
    lista_resultados[index] =number_pkts;    index += 1
    lista_resultados[index] =above(lista_valores, 128);    index += 1
    lista_resultados[index] =below(lista_valores, 128);    index += 1
    lista_resultados[index] =between(lista_valores, 128, 1024);    index += 1
    lista_resultados[index] =above(lista_valores, 1024);    index += 1
    lista_resultados[index] =below(lista_valores, 1024);    index += 1

    # len_header_ip
    cdef int index2 = 0
    for pkt in bloco_pacotes:
        lista_valores[index2] = len(pkt.getlayer('IP')) - len(pkt.getlayer('IP').payload); index2+=1
    q = np.percentile(
        lista_valores, [25, 50, 75], overwrite_input=True
    )
    soma_bytes = lista_valores.sum()
    lista_resultados[index] = below(lista_valores, q[1]); index += 1
    lista_resultados[index] = above(lista_valores, q[1]);index += 1
    lista_resultados[index] = soma_bytes;        index += 1
    lista_resultados[index] = lista_valores.std();        index += 1
    lista_resultados[index] = lista_valores.max();        index += 1
    lista_resultados[index] = lista_valores.var();        index += 1
    lista_resultados[index] = q[2];        index += 1
    lista_resultados[index] = q[0];        index += 1
    lista_resultados[index] = lista_valores.min();        index += 1
    lista_resultados[index] = q[1];        index += 1
    lista_resultados[index] = lista_valores.mean();        index += 1

    #len_ip
    index2 = 0
    for pkt in bloco_pacotes:
        lista_valores[index2] = len(pkt.getlayer('IP'));   index2 += 1
    q = np.percentile(
        lista_valores, [25, 50, 75], overwrite_input=True
    )
    soma_bytes = lista_valores.sum()
    lista_resultados[index] = below(lista_valores, q[1]);    index += 1
    lista_resultados[index] = above(lista_valores, q[1]);    index += 1
    lista_resultados[index] = soma_bytes;    index += 1
    lista_resultados[index] = lista_valores.std();    index += 1
    lista_resultados[index] = lista_valores.max();    index += 1
    lista_resultados[index] = lista_valores.var();    index += 1
    lista_resultados[index] = q[2];    index += 1
    lista_resultados[index] = q[0];    index += 1
    lista_resultados[index] = lista_valores.min();    index += 1
    lista_resultados[index] = q[1];    index += 1
    lista_resultados[index] = lista_valores.mean();    index += 1

    # len_proto
    index2 = 0
    for pkt in bloco_pacotes:
        lista_valores[index2] = len(pkt.getlayer(proto));
        index2 += 1
    q = np.percentile(
        lista_valores, [25, 50, 75], overwrite_input=True
    )
    soma_bytes = lista_valores.sum()
    lista_resultados[index] = below(lista_valores, q[1]);    index += 1
    lista_resultados[index] = above(lista_valores, q[1]);    index += 1
    lista_resultados[index] = soma_bytes;    index += 1
    lista_resultados[index] = lista_valores.std();    index += 1
    lista_resultados[index] = lista_valores.max();    index += 1
    lista_resultados[index] = lista_valores.var();    index += 1
    lista_resultados[index] = q[2];    index += 1
    lista_resultados[index] = q[0];    index += 1
    lista_resultados[index] = lista_valores.min();    index += 1
    lista_resultados[index] = q[1];    index += 1
    lista_resultados[index] = lista_valores.mean();    index += 1

    # len_payload
    index2 = 0
    for pkt in bloco_pacotes:
        lista_valores[index2] = len(pkt.getlayer(proto).payload);
        index2 += 1
    q = np.percentile(
        lista_valores, [25, 50, 75], overwrite_input=True
    )
    soma_bytes = lista_valores.sum()
    lista_resultados[index] = below(lista_valores, q[1]); index += 1
    lista_resultados[index] = above(lista_valores, q[1]);index += 1
    lista_resultados[index] = soma_bytes;        index += 1
    lista_resultados[index] = lista_valores.std();        index += 1
    lista_resultados[index] = lista_valores.max();        index += 1
    lista_resultados[index] = lista_valores.var();        index += 1
    lista_resultados[index] = q[2];        index += 1
    lista_resultados[index] = q[0];        index += 1
    lista_resultados[index] = lista_valores.min();        index += 1
    lista_resultados[index] = q[1];        index += 1
    lista_resultados[index] = lista_valores.mean();        index += 1

    return (lista_cabecalhos, lista_resultados)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double below(double [:] lista_valores, double valor):
    cdef np.ndarray[np.float64_t, ndim=1] array_valores = np.asarray(lista_valores)
    cdef int count = (array_valores < valor).sum()
    return count

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double above(double [:] lista_valores, double valor):
    cdef np.ndarray[np.float64_t, ndim=1] array_valores = np.asarray(lista_valores)
    cdef int count = (array_valores >= valor).sum()
    return count

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double between(double [:] lista_valores, double valor_e, double valor_d):
    cdef np.ndarray[np.float64_t, ndim=1] array_valores = np.asarray(lista_valores)
    cdef int count = ((array_valores >= valor_e) & (array_valores <= valor_d)).sum()
    return count