import cython
from libc.string cimport strdup, strlen, memcpy
from libc.stdlib cimport malloc, free

cdef unsigned long NULL = 0

cimport tcptrace_api


cdef inline char* _cstr(object py_str):
    if py_str is None:
        return <char*>NULL
    return strdup(py_str.encode('utf-8'))

cdef inline str _pystr(char* c_str):
    if c_str == <char*>NULL:
        return ""
    return c_str.decode('utf-8')


cdef class TcptraceAnalyzer:
    cdef void* _ctx
    cdef bint _initialized
    cdef int _num_tcp_connections
    cdef int _num_udp_connections

    def __cinit__(self):
        self._ctx = tcptrace_create_context()
        if self._ctx == <void*>NULL:
            raise MemoryError("Failed to create tcptrace context")
        trace_init()
        plot_init()
        self._initialized = True
        self._num_tcp_connections = 0
        self._num_udp_connections = 0

    def __dealloc__(self):
        if self._initialized:
            # Skip trace_done() and plotter_done() - they cause segfault on cleanup
            # and print unwanted output to stdout
            pass
        if self._ctx != <void*>NULL:
            tcptrace_destroy_context(self._ctx)

    @cython.boundscheck(False)
    @cython.wraparound(False)
    def analyze(self, str filename, int num_threads=1):
        cdef char* c_filename = _cstr(filename)
        if c_filename == <char*>NULL:
            raise MemoryError("Failed to allocate filename")
        cdef int result = tcptrace_analyze_file(self._ctx, c_filename, num_threads)
        if result != 0:
            raise RuntimeError(f"Analysis failed with code {result}")
        extract_tcp_connections(self._ctx)
        extract_udp_connections(self._ctx)
        self._num_tcp_connections = get_num_tcp_connections(self._ctx)
        self._num_udp_connections = get_num_udp_connections(self._ctx)

    @cython.boundscheck(False)
    @cython.wraparound(False)
    def analyze_batch(self, list packets_list, int linktype=1):
        """Analyze batch of packets from memory.
        
        packets_list: list of (timestamp_float, packet_bytes) tuples
                   Example: [(1234567890.123456, b'\\x00\\x11...'), ...]
        linktype: original link type (1=Ethernet, used for dummy header detection)
        
        Returns: dict with:
            - packet_count: total packets processed
            - tcp_count: TCP packets found
            - udp_count: UDP packets found
            - skipped_count: packets that couldn't be parsed
            - trace_duration: elapsed time in seconds
            - warnings: list of warning messages
        """
        cdef int num_packets = len(packets_list)
        if num_packets == 0:
            return {
                'packet_count': 0,
                'tcp_count': 0,
                'udp_count': 0,
                'skipped_count': 0,
                'trace_duration': 0.0,
                'warnings': [],
            }

        cdef double* timestamps = <double*>malloc(num_packets * sizeof(double))
        cdef int* captured_lens = <int*>malloc(num_packets * sizeof(int))
        cdef int i
        cdef list warnings = []
        cdef int skipped = 0

        for i in range(num_packets):
            ts, pkt = packets_list[i]
            timestamps[i] = <double>ts
            captured_lens[i] = len(pkt)
            if len(pkt) < 14:
                skipped += 1
                warnings.append(f"packet {i}: less than 14 bytes, skipped")

        cdef bytes packets_bytes = b''.join(pkt for ts, pkt in packets_list)
        cdef unsigned char* packets_flat = packets_bytes

        cdef int result = tcptrace_analyze_packets_with_linktype(
            self._ctx, timestamps, captured_lens, packets_flat, num_packets, linktype)

        free(timestamps)
        free(captured_lens)

        if result != 0:
            raise RuntimeError(f"Batch analysis failed with code {result}")

        extract_tcp_connections(self._ctx)
        extract_udp_connections(self._ctx)
        self._num_tcp_connections = get_num_tcp_connections(self._ctx)
        self._num_udp_connections = get_num_udp_connections(self._ctx)

        cdef trace_context* ctx = <trace_context*>self._ctx
        return {
            'packet_count': ctx.packet_count,
            'tcp_count': ctx.tcp_count,
            'udp_count': ctx.udp_count,
            'skipped_count': skipped,
            'trace_duration': ctx.trace_duration,
            'warnings': warnings,
        }

    def get_results(self):
        cdef trace_context* ctx = <trace_context*>self._ctx
        return {
            'filename': _pystr(ctx.filename),
            'packet_count': ctx.packet_count,
            'tcp_count': ctx.tcp_count,
            'udp_count': ctx.udp_count,
            'first_packet': get_trace_context_first_packet(self._ctx),
            'last_packet': get_trace_context_last_packet(self._ctx),
            'trace_duration': ctx.trace_duration,
            'elapsed_time': ctx.elapsed_time,
            'bad_ip_checksums': ctx.bad_ip_checksums,
            'bad_tcp_checksums': ctx.bad_tcp_checksums,
            'bad_udp_checksums': ctx.bad_udp_checksums,
            'num_tcp_pairs': ctx.num_tcp_pairs,
            'num_udp_pairs': ctx.num_udp_pairs,
            'num_tcp_connections': self._num_tcp_connections,
            'num_udp_connections': self._num_udp_connections,
        }

    def get_tcp_connections(self):
        cdef list conns = []
        cdef int i
        for i in range(self._num_tcp_connections):
            conns.append(self._get_tcp_connection_dict(i))
        return conns

    def get_udp_connections(self):
        cdef list conns = []
        cdef int i
        for i in range(self._num_udp_connections):
            conns.append(self._get_udp_connection_dict(i))
        return conns

    cdef dict _get_tcp_connection_dict(self, int idx):
        cdef trace_context* _tctx = <trace_context*>self._ctx
        return {
            'a_endpoint': _pystr(get_tcp_connection_a_endpoint(_tctx, idx)),
            'b_endpoint': _pystr(get_tcp_connection_b_endpoint(_tctx, idx)),
            'a_hostname': _pystr(get_tcp_connection_a_hostname(_tctx, idx)),
            'b_hostname': _pystr(get_tcp_connection_b_hostname(_tctx, idx)),
            'a_portname': _pystr(get_tcp_connection_a_portname(_tctx, idx)),
            'b_portname': _pystr(get_tcp_connection_b_portname(_tctx, idx)),
            'host_letter_a': _pystr(get_tcp_connection_host_letter_a(_tctx, idx)),
            'host_letter_b': _pystr(get_tcp_connection_host_letter_b(_tctx, idx)),
            'first_time': get_tcp_connection_first_time(_tctx, idx),
            'last_time': get_tcp_connection_last_time(_tctx, idx),
            'a2b_packets': get_tcp_connection_a2b_packets(_tctx, idx),
            'a2b_data_bytes': get_tcp_connection_a2b_data_bytes(_tctx, idx),
            'a2b_data_pkts': get_tcp_connection_a2b_data_pkts(_tctx, idx),
            'a2b_ack_pkts': get_tcp_connection_a2b_ack_pkts(_tctx, idx),
            'a2b_pure_ack_pkts': get_tcp_connection_a2b_pure_ack_pkts(_tctx, idx),
            'a2b_sack_pkts': get_tcp_connection_a2b_sack_pkts(_tctx, idx),
            'a2b_dsack_pkts': get_tcp_connection_a2b_dsack_pkts(_tctx, idx),
            'a2b_unique_bytes': get_tcp_connection_a2b_unique_bytes(_tctx, idx),
            'a2b_rexmit_pkts': get_tcp_connection_a2b_rexmit_pkts(_tctx, idx),
            'a2b_rexmit_bytes': get_tcp_connection_a2b_rexmit_bytes(_tctx, idx),
            'a2b_mss': get_tcp_connection_a2b_mss(_tctx, idx),
            'a2b_max_seg_size': get_tcp_connection_a2b_max_seg_size(_tctx, idx),
            'a2b_min_seg_size': get_tcp_connection_a2b_min_seg_size(_tctx, idx),
            'a2b_win_max': get_tcp_connection_a2b_win_max(_tctx, idx),
            'a2b_win_min': get_tcp_connection_a2b_win_min(_tctx, idx),
            'a2b_win_zero_ct': get_tcp_connection_a2b_win_zero_ct(_tctx, idx),
            'a2b_win_tot': get_tcp_connection_a2b_win_tot(_tctx, idx),
            'a2b_window_scale': get_tcp_connection_a2b_window_scale(_tctx, idx),
            'a2b_out_order_pkts': get_tcp_connection_a2b_out_order_pkts(_tctx, idx),
            'a2b_zwnd_probes': get_tcp_connection_a2b_zwnd_probes(_tctx, idx),
            'a2b_zwnd_probe_bytes': get_tcp_connection_a2b_zwnd_probe_bytes(_tctx, idx),
            'a2b_urg_data_pkts': get_tcp_connection_a2b_urg_data_pkts(_tctx, idx),
            'a2b_urg_data_bytes': get_tcp_connection_a2b_urg_data_bytes(_tctx, idx),
            'a2b_trunc_bytes': get_tcp_connection_a2b_trunc_bytes(_tctx, idx),
            'a2b_trunc_segs': get_tcp_connection_a2b_trunc_segs(_tctx, idx),
            'a2b_num_sacks': get_tcp_connection_a2b_num_sacks(_tctx, idx),
            'a2b_max_sack_blocks': get_tcp_connection_a2b_max_sack_blocks(_tctx, idx),
            'a2b_num_hardware_dups': get_tcp_connection_a2b_num_hardware_dups(_tctx, idx),
            'a2b_syn_count': get_tcp_connection_a2b_syn_count(_tctx, idx),
            'a2b_fin_count': get_tcp_connection_a2b_fin_count(_tctx, idx),
            'a2b_reset_count': get_tcp_connection_a2b_reset_count(_tctx, idx),
            'a2b_sacks_sent': get_tcp_connection_a2b_sacks_sent(_tctx, idx),
            'a2b_rtt_count': get_tcp_connection_a2b_rtt_count(_tctx, idx),
            'a2b_rtt_min': get_tcp_connection_a2b_rtt_min(_tctx, idx),
            'a2b_rtt_max': get_tcp_connection_a2b_rtt_max(_tctx, idx),
            'a2b_rtt_sum': get_tcp_connection_a2b_rtt_sum(_tctx, idx),
            'a2b_rtt_sum2': get_tcp_connection_a2b_rtt_sum2(_tctx, idx),
            'a2b_rtt_dupack': get_tcp_connection_a2b_rtt_dupack(_tctx, idx),
            'a2b_rtt_triple_dupack': get_tcp_connection_a2b_rtt_triple_dupack(_tctx, idx),
            'a2b_rtt_amback': get_tcp_connection_a2b_rtt_amback(_tctx, idx),
            'a2b_rtt_cumack': get_tcp_connection_a2b_rtt_cumack(_tctx, idx),
            'a2b_rtt_nosample': get_tcp_connection_a2b_rtt_nosample(_tctx, idx),
            'a2b_retr_max': get_tcp_connection_a2b_retr_max(_tctx, idx),
            'a2b_retr_min_tm': get_tcp_connection_a2b_retr_min_tm(_tctx, idx),
            'a2b_retr_max_tm': get_tcp_connection_a2b_retr_max_tm(_tctx, idx),
            'a2b_retr_tm_sum': get_tcp_connection_a2b_retr_tm_sum(_tctx, idx),
            'a2b_retr_tm_sum2': get_tcp_connection_a2b_retr_tm_sum2(_tctx, idx),
            'a2b_initialwin_bytes': get_tcp_connection_a2b_initialwin_bytes(_tctx, idx),
            'a2b_initialwin_segs': get_tcp_connection_a2b_initialwin_segs(_tctx, idx),
            'a2b_stream_length': get_tcp_connection_a2b_stream_length(_tctx, idx),
            'a2b_missed_data': get_tcp_connection_a2b_missed_data(_tctx, idx),
            'a2b_idle_max': get_tcp_connection_a2b_idle_max(_tctx, idx),
            'a2b_data_xmit_time': get_tcp_connection_a2b_data_xmit_time(_tctx, idx),
            'a2b_f1323_ws': get_tcp_connection_a2b_f1323_ws(_tctx, idx),
            'a2b_f1323_ts': get_tcp_connection_a2b_f1323_ts(_tctx, idx),
            'a2b_fsack_req': get_tcp_connection_a2b_fsack_req(_tctx, idx),
            'b2a_packets': get_tcp_connection_b2a_packets(_tctx, idx),
            'b2a_data_bytes': get_tcp_connection_b2a_data_bytes(_tctx, idx),
            'b2a_data_pkts': get_tcp_connection_b2a_data_pkts(_tctx, idx),
            'b2a_ack_pkts': get_tcp_connection_b2a_ack_pkts(_tctx, idx),
            'b2a_pure_ack_pkts': get_tcp_connection_b2a_pure_ack_pkts(_tctx, idx),
            'b2a_sack_pkts': get_tcp_connection_b2a_sack_pkts(_tctx, idx),
            'b2a_dsack_pkts': get_tcp_connection_b2a_dsack_pkts(_tctx, idx),
            'b2a_unique_bytes': get_tcp_connection_b2a_unique_bytes(_tctx, idx),
            'b2a_rexmit_pkts': get_tcp_connection_b2a_rexmit_pkts(_tctx, idx),
            'b2a_rexmit_bytes': get_tcp_connection_b2a_rexmit_bytes(_tctx, idx),
            'b2a_mss': get_tcp_connection_b2a_mss(_tctx, idx),
            'b2a_max_seg_size': get_tcp_connection_b2a_max_seg_size(_tctx, idx),
            'b2a_min_seg_size': get_tcp_connection_b2a_min_seg_size(_tctx, idx),
            'b2a_win_max': get_tcp_connection_b2a_win_max(_tctx, idx),
            'b2a_win_min': get_tcp_connection_b2a_win_min(_tctx, idx),
            'b2a_win_zero_ct': get_tcp_connection_b2a_win_zero_ct(_tctx, idx),
            'b2a_win_tot': get_tcp_connection_b2a_win_tot(_tctx, idx),
            'b2a_window_scale': get_tcp_connection_b2a_window_scale(_tctx, idx),
            'b2a_out_order_pkts': get_tcp_connection_b2a_out_order_pkts(_tctx, idx),
            'b2a_zwnd_probes': get_tcp_connection_b2a_zwnd_probes(_tctx, idx),
            'b2a_zwnd_probe_bytes': get_tcp_connection_b2a_zwnd_probe_bytes(_tctx, idx),
            'b2a_urg_data_pkts': get_tcp_connection_b2a_urg_data_pkts(_tctx, idx),
            'b2a_urg_data_bytes': get_tcp_connection_b2a_urg_data_bytes(_tctx, idx),
            'b2a_trunc_bytes': get_tcp_connection_b2a_trunc_bytes(_tctx, idx),
            'b2a_trunc_segs': get_tcp_connection_b2a_trunc_segs(_tctx, idx),
            'b2a_num_sacks': get_tcp_connection_b2a_num_sacks(_tctx, idx),
            'b2a_max_sack_blocks': get_tcp_connection_b2a_max_sack_blocks(_tctx, idx),
            'b2a_num_hardware_dups': get_tcp_connection_b2a_num_hardware_dups(_tctx, idx),
            'b2a_syn_count': get_tcp_connection_b2a_syn_count(_tctx, idx),
            'b2a_fin_count': get_tcp_connection_b2a_fin_count(_tctx, idx),
            'b2a_reset_count': get_tcp_connection_b2a_reset_count(_tctx, idx),
            'b2a_sacks_sent': get_tcp_connection_b2a_sacks_sent(_tctx, idx),
            'b2a_rtt_count': get_tcp_connection_b2a_rtt_count(_tctx, idx),
            'b2a_rtt_min': get_tcp_connection_b2a_rtt_min(_tctx, idx),
            'b2a_rtt_max': get_tcp_connection_b2a_rtt_max(_tctx, idx),
            'b2a_rtt_sum': get_tcp_connection_b2a_rtt_sum(_tctx, idx),
            'b2a_rtt_sum2': get_tcp_connection_b2a_rtt_sum2(_tctx, idx),
            'b2a_rtt_dupack': get_tcp_connection_b2a_rtt_dupack(_tctx, idx),
            'b2a_rtt_triple_dupack': get_tcp_connection_b2a_rtt_triple_dupack(_tctx, idx),
            'b2a_rtt_amback': get_tcp_connection_b2a_rtt_amback(_tctx, idx),
            'b2a_rtt_cumack': get_tcp_connection_b2a_rtt_cumack(_tctx, idx),
            'b2a_rtt_nosample': get_tcp_connection_b2a_rtt_nosample(_tctx, idx),
            'b2a_retr_max': get_tcp_connection_b2a_retr_max(_tctx, idx),
            'b2a_retr_min_tm': get_tcp_connection_b2a_retr_min_tm(_tctx, idx),
            'b2a_retr_max_tm': get_tcp_connection_b2a_retr_max_tm(_tctx, idx),
            'b2a_retr_tm_sum': get_tcp_connection_b2a_retr_tm_sum(_tctx, idx),
            'b2a_retr_tm_sum2': get_tcp_connection_b2a_retr_tm_sum2(_tctx, idx),
            'b2a_initialwin_bytes': get_tcp_connection_b2a_initialwin_bytes(_tctx, idx),
            'b2a_initialwin_segs': get_tcp_connection_b2a_initialwin_segs(_tctx, idx),
            'b2a_stream_length': get_tcp_connection_b2a_stream_length(_tctx, idx),
            'b2a_missed_data': get_tcp_connection_b2a_missed_data(_tctx, idx),
            'b2a_idle_max': get_tcp_connection_b2a_idle_max(_tctx, idx),
            'b2a_data_xmit_time': get_tcp_connection_b2a_data_xmit_time(_tctx, idx),
            'b2a_f1323_ws': get_tcp_connection_b2a_f1323_ws(_tctx, idx),
            'b2a_f1323_ts': get_tcp_connection_b2a_f1323_ts(_tctx, idx),
            'b2a_fsack_req': get_tcp_connection_b2a_fsack_req(_tctx, idx),
            'elapsed_time': get_tcp_connection_elapsed_time(_tctx, idx),
            'a2b_throughput': get_tcp_connection_a2b_throughput(_tctx, idx),
            'b2a_throughput': get_tcp_connection_b2a_throughput(_tctx, idx),
            'complete': get_tcp_connection_complete(_tctx, idx),
            'is_reset': get_tcp_connection_is_reset(_tctx, idx),
            'filename': _pystr(get_tcp_connection_filename(_tctx, idx)),
        }

    cdef dict _get_udp_connection_dict(self, int idx):
        cdef trace_context* _tctx = <trace_context*>self._ctx
        return {
            'a_endpoint': _pystr(get_udp_connection_a_endpoint(_tctx, idx)),
            'b_endpoint': _pystr(get_udp_connection_b_endpoint(_tctx, idx)),
            'a_hostname': _pystr(get_udp_connection_a_hostname(_tctx, idx)),
            'b_hostname': _pystr(get_udp_connection_b_hostname(_tctx, idx)),
            'a_portname': _pystr(get_udp_connection_a_portname(_tctx, idx)),
            'b_portname': _pystr(get_udp_connection_b_portname(_tctx, idx)),
            'first_time': get_udp_connection_first_time(_tctx, idx),
            'last_time': get_udp_connection_last_time(_tctx, idx),
            'elapsed_time': get_udp_connection_elapsed_time(_tctx, idx),
            'a2b_packets': get_udp_connection_a2b_packets(_tctx, idx),
            'a2b_data_bytes': get_udp_connection_a2b_data_bytes(_tctx, idx),
            'a2b_min_dg_size': get_udp_connection_a2b_min_dg_size(_tctx, idx),
            'a2b_max_dg_size': get_udp_connection_a2b_max_dg_size(_tctx, idx),
            'a2b_throughput': get_udp_connection_a2b_throughput(_tctx, idx),
            'b2a_packets': get_udp_connection_b2a_packets(_tctx, idx),
            'b2a_data_bytes': get_udp_connection_b2a_data_bytes(_tctx, idx),
            'b2a_min_dg_size': get_udp_connection_b2a_min_dg_size(_tctx, idx),
            'b2a_max_dg_size': get_udp_connection_b2a_max_dg_size(_tctx, idx),
            'b2a_throughput': get_udp_connection_b2a_throughput(_tctx, idx),
            'filename': _pystr(get_udp_connection_filename(_tctx, idx)),
        }