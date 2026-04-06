#scapy doc: https://scapy.readthedocs.io/en/latest/api/scapy.packet.html#scapy.packet.Packet
from scapy.utils import rdpcap, RawPcapReader, RawPcapWriter
from scapy.packet import Packet
from scapy.all import IP, UDP, TCP, Padding, Raw
from scapy.plist import PacketList
import numpy as np
cimport numpy as np
cimport cython

import math

DEF PRECISAO = 6# zeros

#### PKT
cpdef int len_pkt(object pkt):
    return len(pkt) ## ver se isso tem diferenca

# def sent_time(pkt: Packet) -> float:
#     return float(sent_time())

cpdef float time(object pkt):
    return float(pkt.time)

cpdef int len_payload_UDP(object pkt):
    return len(pkt[UDP] - pkt[UDP].payload)

#### TCP

cpdef int len_payload_TCP(object pkt):
    return len(pkt[TCP].payload)

cpdef int len_header_TCP(object pkt):
    return len(pkt[TCP] - pkt[TCP].payload)

cpdef int len_TCP(object pkt):
    return len(pkt[TCP])

cpdef bint check_ACK_flag(object pkt):
    if 'A' in pkt[TCP].flags:
        return True
    
    return False


cpdef bint check_SYN_flag(object pkt):
    if 'S' in pkt[TCP].flags:
        return True
    
    return False

cpdef bint check_FYN_flag(object pkt):
    if 'F' in pkt[TCP].flags:
        return True
    
    return False

cpdef bint check_RST_flag(object pkt):
    if 'R' in pkt[TCP].flags:
        return True
    
    return False

# Desativamos verificações extras para máxima velocidade
@cython.boundscheck(False) # Desativa verificação de índices fora dos limites
@cython.wraparound(False)  # Desativa suporte a índices negativos (ex: arr[-1])
cpdef int contador_flags(object[:] lista_flags, str flag = ""):
    cdef int contador =0
    if flag:
        for val in lista_flags:
            if flag in val:
                contador +=1
    else:
        contador = len(lista_flags)
    return contador

#### calculos base
# Desativamos verificações extras para máxima velocidade
@cython.boundscheck(False) # Desativa verificação de índices fora dos limites
@cython.wraparound(False)  # Desativa suporte a índices negativos (ex: arr[-1])
cpdef float calcular_mean(float[:] lista_valores):
    if len(lista_valores) == 0:
        return 0.0
    
    cdef float soma = 0.0
    for val in lista_valores:
        soma += val
    
    soma = soma/len(lista_valores)
    soma = round(soma, PRECISAO)
    return soma
    
# Desativamos verificações extras para máxima velocidade
@cython.boundscheck(False)
@cython.wraparound(False)
cpdef float calcular_median(float[:] lista_valores):
    cdef int n = lista_valores.shape[0]
    
    if n == 0:
        return 0.0
    
    # Criamos uma cópia ordenada usando NumPy (rápido em C)
    # .base_get() ou np.array() garante que temos um array manipulável
    cdef double[:] lista_ordenada = np.sort(np.asarray(lista_valores))
    
    cdef int meio = n // 2
    
    # Se o número de elementos for ímpar
    if n % 2 != 0:
        return lista_ordenada[meio]
    
    # Se for par, média dos dois valores centrais
    cdef double soma = (lista_ordenada[meio - 1] + lista_ordenada[meio]) / 2.0
    return round(soma, PRECISAO)

# Desativamos verificações extras para máxima velocidade
@cython.boundscheck(False) # Desativa verificação de índices fora dos limites
@cython.wraparound(False)  # Desativa suporte a índices negativos (ex: arr[-1])
cpdef double calcular_q1(double[:] lista_valores):
    if len(lista_valores) == 0:
        return 0.0
    
    cdef double[:] lista_ordenada = np.sort(np.asarray(lista_valores))
    
    cdef int quartil = int(len(lista_ordenada) * 0.25)
    return lista_ordenada[quartil]

# Desativamos verificações extras para máxima velocidade
@cython.boundscheck(False) # Desativa verificação de índices fora dos limites
@cython.wraparound(False)  # Desativa suporte a índices negativos (ex: arr[-1])
cpdef double  calcular_q3(double[:] lista_valores):
    if len(lista_valores) == 0:
        return 0.0
    
    cdef double[:] lista_ordenada = np.sort(np.asarray(lista_valores))
    
    cdef int quartil = int(len(lista_ordenada) * 0.75)
    return lista_ordenada[quartil]

# Desativamos verificações extras para máxima velocidade
@cython.boundscheck(False) # Desativa verificação de índices fora dos limites
@cython.wraparound(False)  # Desativa suporte a índices negativos (ex: arr[-1])
cpdef double calcular_max(double[:] lista_valores):
    if len(lista_valores) == 0:
        return 0.0
    
    cdef double max = -999999.0

    for val in lista_valores:
        if val > max:
            max = val
    return round(max, PRECISAO)

# Desativamos verificações extras para máxima velocidade
@cython.boundscheck(False) # Desativa verificação de índices fora dos limites
@cython.wraparound(False)  # Desativa suporte a índices negativos (ex: arr[-1])
cpdef double calcular_min(double[:] lista_valores):
    if len(lista_valores) == 0:
        return 0.0
    
    cdef double min = 999999.0

    for val in lista_valores:
        if val < min:
            min = val
    return round(min, PRECISAO)

# Desativamos verificações extras para máxima velocidade
@cython.boundscheck(False) # Desativa verificação de índices fora dos limites
@cython.wraparound(False)  # Desativa suporte a índices negativos (ex: arr[-1])
cpdef double calcular_std(double[:] lista_valores):
    if len(lista_valores) == 0:
        return 0.0
    
    return round(math.sqrt(calcular_var(lista_valores)), PRECISAO)

# Desativamos verificações extras para máxima velocidade
@cython.boundscheck(False) # Desativa verificação de índices fora dos limites
@cython.wraparound(False)  # Desativa suporte a índices negativos (ex: arr[-1])
cpdef double calcular_var(double[:] lista_valores):

    if len(lista_valores) == 0:
        return 0.0

    cdef double media = calcular_mean(lista_valores)

    cdef double soma = 0.0
    cdef double aux = 0
    for val in lista_valores:
        aux = (val - media)
        soma += aux * aux 
    return round(soma/len(lista_valores), PRECISAO)

# Desativamos verificações extras para máxima velocidade
@cython.boundscheck(False) # Desativa verificação de índices fora dos limites
@cython.wraparound(False)  # Desativa suporte a índices negativos (ex: arr[-1])
cpdef double calcular_sum(double[:] lista_valores):
    if len(lista_valores) == 0:
        return 0.0
    cdef double soma = 0.0
    for val in lista_valores:
        soma+=val

    return soma

# Desativamos verificações extras para máxima velocidade
@cython.boundscheck(False) # Desativa verificação de índices fora dos limites
@cython.wraparound(False)  # Desativa suporte a índices negativos (ex: arr[-1])
cpdef int calcular_maior_media(double[:] lista_valores):
    if len(lista_valores) == 0:
        return 0

    cdef double media = calcular_mean(lista_valores)

    cdef int somatorio = 0
    for val in lista_valores:
        if val > media:
            somatorio+=1
    return somatorio

# Desativamos verificações extras para máxima velocidade
@cython.boundscheck(False) # Desativa verificação de índices fora dos limites
@cython.wraparound(False)  # Desativa suporte a índices negativos (ex: arr[-1])
cpdef int calcular_menor_media(double[:] lista_valores):
    if len(lista_valores) == 0:
        return 0
    
    cdef double media = calcular_mean(lista_valores)

    cdef int somatorio = 0
    for val in lista_valores:
        if val < media:
            somatorio+=1
    return somatorio

### outra forma de obter as flags
# FIN = 0x01
# SYN = 0x02
# RST = 0x04
# PSH = 0x08
# ACK = 0x10
# URG = 0x20
# ECE = 0x40
# CWR = 0x80
# And test them like this:

# F = p['TCP'].flags    # this should give you an integer
# if F & FIN:
#     # FIN flag activated
# if F & SYN:
#     # SYN flag activated
# # rest of the flags here