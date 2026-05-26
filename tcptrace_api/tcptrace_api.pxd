# cython.bind(dynamic_backend='pure')
# distutils: language = "c++"

cdef extern from "tcptrace.h":
    ctypedef struct trace_context:
        char *filename
        int thread_id
        int result
        unsigned long packet_count
        unsigned long tcp_count
        unsigned long udp_count
        double first_packet_tv_sec
        double first_packet_tv_usec
        double last_packet_tv_sec
        double last_packet_tv_usec
        double trace_duration
        double elapsed_time
        char *error_msg
        int num_tcp_pairs
        int max_tcp_pairs
        int num_udp_pairs
        unsigned long bad_ip_checksums
        unsigned long bad_tcp_checksums
        unsigned long bad_udp_checksums
        int only_conn_ix
        int more_conns_ignored
        int num_tcp_conns
        int num_udp_conns

    ctypedef struct tcp_conn_info:
        char *a_endpoint
        char *b_endpoint
        char *a_hostname
        char *b_hostname
        char *a_portname
        char *b_portname
        char *host_letter_a
        char *host_letter_b
        double first_time_tv_sec
        double first_time_tv_usec
        double last_time_tv_sec
        double last_time_tv_usec
        double elapsed_time
        int complete
        int is_reset
        unsigned long long a2b_packets
        unsigned long long a2b_data_bytes
        unsigned long long a2b_data_pkts
        unsigned long long a2b_rexmit_bytes
        unsigned long long a2b_rexmit_pkts
        unsigned long long a2b_unique_bytes
        unsigned long long a2b_ack_pkts
        unsigned long long a2b_pure_ack_pkts
        unsigned long long a2b_sack_pkts
        unsigned long long a2b_dsack_pkts
        unsigned long a2b_mss
        unsigned long a2b_max_seg_size
        unsigned long a2b_min_seg_size
        unsigned long a2b_win_max
        unsigned long a2b_win_min
        unsigned long a2b_win_zero_ct
        unsigned long long a2b_win_tot
        unsigned long long a2b_out_order_pkts
        unsigned long long a2b_zwnd_probes
        unsigned long long a2b_zwnd_probe_bytes
        unsigned long long a2b_urg_data_pkts
        unsigned long long a2b_urg_data_bytes
        unsigned long long a2b_trunc_bytes
        unsigned long long a2b_trunc_segs
        unsigned long long a2b_num_sacks
        unsigned long a2b_max_sack_blocks
        unsigned long long a2b_num_hardware_dups
        unsigned long a2b_syn_count
        unsigned long a2b_fin_count
        unsigned long a2b_reset_count
        unsigned long long a2b_sacks_sent
        unsigned long a2b_rtt_count
        unsigned long a2b_rtt_min
        unsigned long a2b_rtt_max
        double a2b_rtt_sum
        double a2b_rtt_sum2
        unsigned long long a2b_rtt_dupack
        unsigned long long a2b_rtt_triple_dupack
        unsigned long long a2b_rtt_amback
        unsigned long long a2b_rtt_cumack
        unsigned long long a2b_rtt_nosample
        unsigned long a2b_retr_max
        unsigned long a2b_retr_min_tm
        unsigned long a2b_retr_max_tm
        double a2b_retr_tm_sum
        double a2b_retr_tm_sum2
        unsigned long a2b_initialwin_bytes
        unsigned long a2b_initialwin_segs
        unsigned long long a2b_stream_length
        unsigned long long a2b_missed_data
        unsigned long long a2b_idle_max
        double a2b_throughput
        double a2b_data_xmit_time
        unsigned char a2b_window_scale
        bint a2b_f1323_ws
        bint a2b_f1323_ts
        bint a2b_fsack_req
        unsigned long long b2a_packets
        unsigned long long b2a_data_bytes
        unsigned long long b2a_data_pkts
        unsigned long long b2a_rexmit_bytes
        unsigned long long b2a_rexmit_pkts
        unsigned long long b2a_unique_bytes
        unsigned long long b2a_ack_pkts
        unsigned long long b2a_pure_ack_pkts
        unsigned long long b2a_sack_pkts
        unsigned long long b2a_dsack_pkts
        unsigned long b2a_mss
        unsigned long b2a_max_seg_size
        unsigned long b2a_min_seg_size
        unsigned long b2a_win_max
        unsigned long b2a_win_min
        unsigned long b2a_win_zero_ct
        unsigned long long b2a_win_tot
        unsigned long long b2a_out_order_pkts
        unsigned long long b2a_zwnd_probes
        unsigned long long b2a_zwnd_probe_bytes
        unsigned long long b2a_urg_data_pkts
        unsigned long long b2a_urg_data_bytes
        unsigned long long b2a_trunc_bytes
        unsigned long long b2a_trunc_segs
        unsigned long long b2a_num_sacks
        unsigned long b2a_max_sack_blocks
        unsigned long long b2a_num_hardware_dups
        unsigned long b2a_syn_count
        unsigned long b2a_fin_count
        unsigned long b2a_reset_count
        unsigned long long b2a_sacks_sent
        unsigned long b2a_rtt_count
        unsigned long b2a_rtt_min
        unsigned long b2a_rtt_max
        double b2a_rtt_sum
        double b2a_rtt_sum2
        unsigned long long b2a_rtt_dupack
        unsigned long long b2a_rtt_triple_dupack
        unsigned long long b2a_rtt_amback
        unsigned long long b2a_rtt_cumack
        unsigned long long b2a_rtt_nosample
        unsigned long b2a_retr_max
        unsigned long b2a_retr_min_tm
        unsigned long b2a_retr_max_tm
        double b2a_retr_tm_sum
        double b2a_retr_tm_sum2
        unsigned long b2a_initialwin_bytes
        unsigned long b2a_initialwin_segs
        unsigned long long b2a_stream_length
        unsigned long long b2a_missed_data
        unsigned long long b2a_idle_max
        double b2a_throughput
        double b2a_data_xmit_time
        unsigned char b2a_window_scale
        bint b2a_f1323_ws
        bint b2a_f1323_ts
        bint b2a_fsack_req
        char *filename

    ctypedef struct udp_conn_info:
        char *a_endpoint
        char *b_endpoint
        char *a_hostname
        char *b_hostname
        char *a_portname
        char *b_portname
        double first_time_tv_sec
        double first_time_tv_usec
        double last_time_tv_sec
        double last_time_tv_usec
        double elapsed_time
        unsigned long long a2b_packets
        unsigned long long a2b_data_bytes
        unsigned long a2b_min_dg_size
        unsigned long a2b_max_dg_size
        double a2b_throughput
        unsigned long long b2a_packets
        unsigned long long b2a_data_bytes
        unsigned long b2a_min_dg_size
        unsigned long b2a_max_dg_size
        double b2a_throughput
        char *filename

    trace_context* tcptrace_create_context()
    int tcptrace_analyze_file(void* ctx, const char* filename, int num_threads)
    void tcptrace_destroy_context(void* ctx)
    void trace_init()
    void trace_done()
    void plot_init()
    void plotter_done()
    void extract_tcp_connections(void* ctx)
    void extract_udp_connections(void* ctx)
    tcp_conn_info* get_tcp_connection_info(void* ctx, int idx)
    udp_conn_info* get_udp_connection_info(void* ctx, int idx)
    int get_num_tcp_connections(void* ctx)
    int get_num_udp_connections(void* ctx)
    double get_trace_context_first_packet(void* ctx)
    double get_trace_context_last_packet(void* ctx)
    int tcptrace_analyze_packets_with_linktype(void* ctx, double* timestamps, int* captured_lens, unsigned char* packets_flat, int num_packets, int linktype)
    unsigned long get_tcp_connection_a2b_data_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_rexmit_bytes(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_rexmit_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_unique_bytes(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_ack_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_pure_ack_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_sack_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_dsack_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_mss(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_max_seg_size(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_min_seg_size(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_win_max(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_win_min(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_win_zero_ct(void* ctx, int idx)
    unsigned long long get_tcp_connection_a2b_win_tot(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_avg_win_adv(void* ctx, int idx)
    unsigned long long get_tcp_connection_a2b_out_order_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_zwnd_probes(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_zwnd_probe_bytes(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_urg_data_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_urg_data_bytes(void* ctx, int idx)
    unsigned long long get_tcp_connection_a2b_trunc_bytes(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_trunc_segs(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_num_sacks(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_max_sack_blocks(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_num_hardware_dups(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_syn_count(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_fin_count(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_reset_count(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_sacks_sent(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_rtt_count(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_rtt_min(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_rtt_max(void* ctx, int idx)
    double get_tcp_connection_a2b_rtt_avg(void* ctx, int idx)
    double get_tcp_connection_a2b_rtt_stdev(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_rtt_3WHS(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_rtt_dupack(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_rtt_triple_dupack(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_rtt_amback(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_rtt_cumack(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_rtt_nosample(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_retr_max(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_retr_min_tm(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_retr_max_tm(void* ctx, int idx)
    double get_tcp_connection_a2b_retr_avg_tm(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_initialwin_bytes(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_initialwin_segs(void* ctx, int idx)
    unsigned long long get_tcp_connection_a2b_stream_length(void* ctx, int idx)
    unsigned long long get_tcp_connection_a2b_missed_data(void* ctx, int idx)
    unsigned long get_tcp_connection_a2b_idle_max(void* ctx, int idx)
    double get_tcp_connection_a2b_data_xmit_time(void* ctx, int idx)
    unsigned char get_tcp_connection_a2b_window_scale(void* ctx, int idx)
    bint get_tcp_connection_a2b_f1323_ws(void* ctx, int idx)
    bint get_tcp_connection_a2b_f1323_ts(void* ctx, int idx)
    bint get_tcp_connection_a2b_fsack_req(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_data_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_rexmit_bytes(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_rexmit_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_unique_bytes(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_ack_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_pure_ack_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_sack_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_dsack_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_mss(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_max_seg_size(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_min_seg_size(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_win_max(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_win_min(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_win_zero_ct(void* ctx, int idx)
    unsigned long long get_tcp_connection_b2a_win_tot(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_avg_win_adv(void* ctx, int idx)
    unsigned long long get_tcp_connection_b2a_out_order_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_zwnd_probes(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_zwnd_probe_bytes(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_urg_data_pkts(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_urg_data_bytes(void* ctx, int idx)
    unsigned long long get_tcp_connection_b2a_trunc_bytes(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_trunc_segs(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_num_sacks(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_max_sack_blocks(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_num_hardware_dups(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_syn_count(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_fin_count(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_reset_count(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_sacks_sent(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_rtt_count(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_rtt_min(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_rtt_max(void* ctx, int idx)
    double get_tcp_connection_b2a_rtt_avg(void* ctx, int idx)
    double get_tcp_connection_b2a_rtt_stdev(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_rtt_3WHS(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_rtt_dupack(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_rtt_triple_dupack(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_rtt_amback(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_rtt_cumack(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_rtt_nosample(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_retr_max(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_retr_min_tm(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_retr_max_tm(void* ctx, int idx)
    double get_tcp_connection_b2a_retr_avg_tm(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_initialwin_bytes(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_initialwin_segs(void* ctx, int idx)
    unsigned long long get_tcp_connection_b2a_stream_length(void* ctx, int idx)
    unsigned long long get_tcp_connection_b2a_missed_data(void* ctx, int idx)
    unsigned long get_tcp_connection_b2a_idle_max(void* ctx, int idx)
    double get_tcp_connection_b2a_data_xmit_time(void* ctx, int idx)
    unsigned char get_tcp_connection_b2a_window_scale(void* ctx, int idx)
    bint get_tcp_connection_b2a_f1323_ws(void* ctx, int idx)
    bint get_tcp_connection_b2a_f1323_ts(void* ctx, int idx)
    bint get_tcp_connection_b2a_fsack_req(void* ctx, int idx)
    int get_tcp_connection_is_reset(void* ctx, int idx)
    int get_tcp_connection_complete(void* ctx, int idx)

    char* get_tcp_connection_a_endpoint(void* ctx, int idx)
    char* get_tcp_connection_b_endpoint(void* ctx, int idx)
    char* get_tcp_connection_a_hostname(void* ctx, int idx)
    char* get_tcp_connection_b_hostname(void* ctx, int idx)
    char* get_tcp_connection_a_portname(void* ctx, int idx)
    char* get_tcp_connection_b_portname(void* ctx, int idx)
    char* get_tcp_connection_host_letter_a(void* ctx, int idx)
    char* get_tcp_connection_host_letter_b(void* ctx, int idx)
    double get_tcp_connection_first_time(void* ctx, int idx)
    double get_tcp_connection_last_time(void* ctx, int idx)
    double get_tcp_connection_elapsed_time(void* ctx, int idx)
    unsigned long long get_tcp_connection_a2b_packets(void* ctx, int idx)
    unsigned long long get_tcp_connection_a2b_data_bytes(void* ctx, int idx)
    double get_tcp_connection_a2b_rtt_sum(void* ctx, int idx)
    double get_tcp_connection_a2b_rtt_sum2(void* ctx, int idx)
    double get_tcp_connection_a2b_retr_tm_sum(void* ctx, int idx)
    double get_tcp_connection_a2b_retr_tm_sum2(void* ctx, int idx)
    double get_tcp_connection_a2b_throughput(void* ctx, int idx)
    double get_tcp_connection_b2a_rtt_sum(void* ctx, int idx)
    double get_tcp_connection_b2a_rtt_sum2(void* ctx, int idx)
    double get_tcp_connection_b2a_retr_tm_sum(void* ctx, int idx)
    double get_tcp_connection_b2a_retr_tm_sum2(void* ctx, int idx)
    double get_tcp_connection_b2a_throughput(void* ctx, int idx)
    unsigned long long get_tcp_connection_b2a_packets(void* ctx, int idx)
    unsigned long long get_tcp_connection_b2a_data_bytes(void* ctx, int idx)
    char* get_tcp_connection_filename(void* ctx, int idx)

    char* get_udp_connection_a_endpoint(void* ctx, int idx)
    char* get_udp_connection_b_endpoint(void* ctx, int idx)
    char* get_udp_connection_a_hostname(void* ctx, int idx)
    char* get_udp_connection_b_hostname(void* ctx, int idx)
    char* get_udp_connection_a_portname(void* ctx, int idx)
    char* get_udp_connection_b_portname(void* ctx, int idx)
    double get_udp_connection_first_time(void* ctx, int idx)
    double get_udp_connection_last_time(void* ctx, int idx)
    double get_udp_connection_elapsed_time(void* ctx, int idx)
    unsigned long get_udp_connection_a2b_packets(void* ctx, int idx)
    unsigned long long get_udp_connection_a2b_data_bytes(void* ctx, int idx)
    unsigned long get_udp_connection_a2b_min_dg_size(void* ctx, int idx)
    unsigned long get_udp_connection_a2b_max_dg_size(void* ctx, int idx)
    double get_udp_connection_a2b_throughput(void* ctx, int idx)
    unsigned long get_udp_connection_b2a_packets(void* ctx, int idx)
    unsigned long long get_udp_connection_b2a_data_bytes(void* ctx, int idx)
    unsigned long get_udp_connection_b2a_min_dg_size(void* ctx, int idx)
    unsigned long get_udp_connection_b2a_max_dg_size(void* ctx, int idx)
    double get_udp_connection_b2a_throughput(void* ctx, int idx)
    char* get_udp_connection_filename(void* ctx, int idx)