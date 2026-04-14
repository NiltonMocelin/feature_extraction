# No topo do seu arquivo .pyx
from libc.stdlib cimport malloc, free
from libc.string cimport memcpy

cdef extern from "netinet/ip.h":
    struct ip:
        pass  # O tcptrace só precisa do ponteiro, o conteúdo ele processa

# Estrutura para espelhar a my_packet_t do C
cdef struct my_packet_t:
    long tv_sec
    long tv_usec
    int len
    int tlen
    unsigned char *data