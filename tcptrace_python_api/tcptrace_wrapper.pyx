from scapy.all import rdpcap, Raw

def process_pcap_to_tcptrace(filename):
    # 1. Ler pacotes com Scapy
    packets = rdpcap(filename)
    cdef int num_pkts = len(packets)
    
    # 2. Alocar array de estruturas my_packet_t no C
    cdef my_packet_t *packet_list = <my_packet_t *>malloc(num_pkts * sizeof(my_packet_t))
    
    if not packet_list:
        raise MemoryError("Falha ao alocar lista de pacotes")

    try:
        for i, pkt in enumerate(packets):
            # Extrair dados brutos (bytes)
            raw_data = bytes(pkt)
            data_len = len(raw_data)
            
            # Preencher a estrutura para o C
            packet_list[i].tv_sec = int(pkt.time)
            packet_list[i].tv_usec = int((pkt.time - int(pkt.time)) * 1000000)
            packet_list[i].len = data_len
            packet_list[i].tlen = data_len
            
            # Alocar memória para os bytes do pacote
            packet_list[i].data = <unsigned char *>malloc(data_len)
            memcpy(packet_list[i].data, <char *>raw_data, data_len)

        # 3. Chamar a função C do tcptrace (exposta via extern)
        # Assumindo que você compilou o tcptrace como biblioteca
        c_process_memory_list(packet_list, num_pkts)

    finally:
        # 4. Limpeza (importante para evitar memory leak)
        for i in range(num_pkts):
            if packet_list[i].data:
                free(packet_list[i].data)
        free(packet_list)