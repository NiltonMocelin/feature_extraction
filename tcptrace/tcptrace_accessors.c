#include "tcptrace.h"

static char empty_string[] = "";

/* Forward declaration from tcptrace.c */
int tcptrace_analyze_packets_direct(
    trace_context *ctx,
    struct timeval *timestamps,
    int *captured_lens,
    unsigned char **packets,
    int num_packets,
    int linktype);

double get_trace_context_first_packet(void* ctx) {
    trace_context* c = (trace_context*)ctx;
    if (!c)
        return 0.0;
    return (double)c->first_packet.tv_sec + (double)c->first_packet.tv_usec / 1000000.0;
}

double get_trace_context_last_packet(void* ctx) {
    trace_context* c = (trace_context*)ctx;
    if (!c)
        return 0.0;
    return (double)c->last_packet.tv_sec + (double)c->last_packet.tv_usec / 1000000.0;
}

int get_num_tcp_connections(void* ctx) {
    trace_context* c = (trace_context*)ctx;
    if (!c)
        return 0;
    return c->num_tcp_conns;
}

int get_num_udp_connections(void* ctx) {
    trace_context* c = (trace_context*)ctx;
    if (!c)
        return 0;
    return c->num_udp_conns;
}

char* get_tcp_connection_a_endpoint(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return empty_string;
    if (!c->tcp_conns[idx].a_endpoint)
        return empty_string;
    return c->tcp_conns[idx].a_endpoint;
}

char* get_tcp_connection_b_endpoint(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return empty_string;
    if (!c->tcp_conns[idx].b_endpoint)
        return empty_string;
    return c->tcp_conns[idx].b_endpoint;
}

char* get_tcp_connection_a_hostname(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return empty_string;
    if (!c->tcp_conns[idx].a_hostname)
        return empty_string;
    return c->tcp_conns[idx].a_hostname;
}

char* get_tcp_connection_b_hostname(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return empty_string;
    if (!c->tcp_conns[idx].b_hostname)
        return empty_string;
    return c->tcp_conns[idx].b_hostname;
}

char* get_tcp_connection_a_portname(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return empty_string;
    if (!c->tcp_conns[idx].a_portname)
        return empty_string;
    return c->tcp_conns[idx].a_portname;
}

char* get_tcp_connection_b_portname(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return empty_string;
    if (!c->tcp_conns[idx].b_portname)
        return empty_string;
    return c->tcp_conns[idx].b_portname;
}

unsigned long long get_tcp_connection_a2b_packets(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_packets;
}

unsigned long long get_tcp_connection_a2b_data_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_data_bytes;
}

unsigned long long get_tcp_connection_b2a_packets(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_packets;
}

unsigned long long get_tcp_connection_b2a_data_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_data_bytes;
}

double get_tcp_connection_elapsed_time(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return c->tcp_conns[idx].elapsed_time;
}

double get_tcp_connection_a2b_throughput(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return c->tcp_conns[idx].a2b_throughput;
}

double get_tcp_connection_b2a_throughput(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return c->tcp_conns[idx].b2a_throughput;
}

int get_tcp_connection_complete(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].complete;
}

char* get_tcp_connection_filename(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return empty_string;
    if (!c->tcp_conns[idx].filename)
        return empty_string;
    return c->tcp_conns[idx].filename;
}

/* TCP host_letter accessors */
char* get_tcp_connection_host_letter_a(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return empty_string;
    if (!c->tcp_conns[idx].host_letter_a)
        return empty_string;
    return c->tcp_conns[idx].host_letter_a;
}

char* get_tcp_connection_host_letter_b(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return empty_string;
    if (!c->tcp_conns[idx].host_letter_b)
        return empty_string;
    return c->tcp_conns[idx].host_letter_b;
}

/* TCP time accessors */
double get_tcp_connection_first_time(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return (double)c->tcp_conns[idx].first_time.tv_sec + (double)c->tcp_conns[idx].first_time.tv_usec / 1000000.0;
}

double get_tcp_connection_last_time(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return (double)c->tcp_conns[idx].last_time.tv_sec + (double)c->tcp_conns[idx].last_time.tv_usec / 1000000.0;
}

int get_tcp_connection_is_reset(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].is_reset;
}

/* A->B direction packet/data accessors */
u_llong get_tcp_connection_a2b_data_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_data_pkts;
}

u_llong get_tcp_connection_a2b_ack_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_ack_pkts;
}

u_llong get_tcp_connection_a2b_pure_ack_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_pure_ack_pkts;
}

u_llong get_tcp_connection_a2b_sack_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_sack_pkts;
}

u_llong get_tcp_connection_a2b_dsack_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_dsack_pkts;
}

u_llong get_tcp_connection_a2b_unique_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_unique_bytes;
}

u_llong get_tcp_connection_a2b_rexmit_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_rexmit_pkts;
}

u_llong get_tcp_connection_a2b_rexmit_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_rexmit_bytes;
}

/* B->A direction packet/data accessors */
u_llong get_tcp_connection_b2a_data_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_data_pkts;
}

u_llong get_tcp_connection_b2a_ack_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_ack_pkts;
}

u_llong get_tcp_connection_b2a_pure_ack_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_pure_ack_pkts;
}

u_llong get_tcp_connection_b2a_sack_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_sack_pkts;
}

u_llong get_tcp_connection_b2a_dsack_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_dsack_pkts;
}

u_llong get_tcp_connection_b2a_unique_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_unique_bytes;
}

u_llong get_tcp_connection_b2a_rexmit_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_rexmit_pkts;
}

u_llong get_tcp_connection_b2a_rexmit_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_rexmit_bytes;
}

/* A->B direction MSS and segment size accessors */
u_long get_tcp_connection_a2b_mss(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_mss;
}

u_long get_tcp_connection_a2b_max_seg_size(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_max_seg_size;
}

u_long get_tcp_connection_a2b_min_seg_size(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_min_seg_size;
}

/* B->A direction MSS and segment size accessors */
u_long get_tcp_connection_b2a_mss(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_mss;
}

u_long get_tcp_connection_b2a_max_seg_size(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_max_seg_size;
}

u_long get_tcp_connection_b2a_min_seg_size(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_min_seg_size;
}

/* A->B direction window accessors */
u_long get_tcp_connection_a2b_win_max(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_win_max;
}

u_long get_tcp_connection_a2b_win_min(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_win_min;
}

u_long get_tcp_connection_a2b_win_zero_ct(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_win_zero_ct;
}

u_llong get_tcp_connection_a2b_win_tot(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_win_tot;
}

u_char get_tcp_connection_a2b_window_scale(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_window_scale;
}

/* B->A direction window accessors */
u_long get_tcp_connection_b2a_win_max(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_win_max;
}

u_long get_tcp_connection_b2a_win_min(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_win_min;
}

u_long get_tcp_connection_b2a_win_zero_ct(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_win_zero_ct;
}

u_llong get_tcp_connection_b2a_win_tot(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_win_tot;
}

u_char get_tcp_connection_b2a_window_scale(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_window_scale;
}

/* A->B direction other stats accessors */
u_llong get_tcp_connection_a2b_out_order_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_out_order_pkts;
}

u_llong get_tcp_connection_a2b_zwnd_probes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_zwnd_probes;
}

u_llong get_tcp_connection_a2b_zwnd_probe_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_zwnd_probe_bytes;
}

u_llong get_tcp_connection_a2b_urg_data_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_urg_data_pkts;
}

u_llong get_tcp_connection_a2b_urg_data_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_urg_data_bytes;
}

u_llong get_tcp_connection_a2b_trunc_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_trunc_bytes;
}

u_llong get_tcp_connection_a2b_trunc_segs(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_trunc_segs;
}

u_llong get_tcp_connection_a2b_num_sacks(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_num_sacks;
}

u_long get_tcp_connection_a2b_max_sack_blocks(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_max_sack_blocks;
}

u_llong get_tcp_connection_a2b_num_hardware_dups(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_num_hardware_dups;
}

u_long get_tcp_connection_a2b_syn_count(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_syn_count;
}

u_long get_tcp_connection_a2b_fin_count(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_fin_count;
}

u_long get_tcp_connection_a2b_reset_count(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_reset_count;
}

u_llong get_tcp_connection_a2b_sacks_sent(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_sacks_sent;
}

/* B->A direction other stats accessors */
u_llong get_tcp_connection_b2a_out_order_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_out_order_pkts;
}

u_llong get_tcp_connection_b2a_zwnd_probes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_zwnd_probes;
}

u_llong get_tcp_connection_b2a_zwnd_probe_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_zwnd_probe_bytes;
}

u_llong get_tcp_connection_b2a_urg_data_pkts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_urg_data_pkts;
}

u_llong get_tcp_connection_b2a_urg_data_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_urg_data_bytes;
}

u_llong get_tcp_connection_b2a_trunc_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_trunc_bytes;
}

u_llong get_tcp_connection_b2a_trunc_segs(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_trunc_segs;
}

u_llong get_tcp_connection_b2a_num_sacks(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_num_sacks;
}

u_long get_tcp_connection_b2a_max_sack_blocks(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_max_sack_blocks;
}

u_llong get_tcp_connection_b2a_num_hardware_dups(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_num_hardware_dups;
}

u_long get_tcp_connection_b2a_syn_count(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_syn_count;
}

u_long get_tcp_connection_b2a_fin_count(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_fin_count;
}

u_long get_tcp_connection_b2a_reset_count(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_reset_count;
}

u_llong get_tcp_connection_b2a_sacks_sent(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_sacks_sent;
}

/* A->B direction RTT stats accessors */
u_long get_tcp_connection_a2b_rtt_count(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_rtt_count;
}

u_long get_tcp_connection_a2b_rtt_min(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_rtt_min;
}

u_long get_tcp_connection_a2b_rtt_max(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_rtt_max;
}

double get_tcp_connection_a2b_rtt_sum(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return c->tcp_conns[idx].a2b_rtt_sum;
}

double get_tcp_connection_a2b_rtt_sum2(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return c->tcp_conns[idx].a2b_rtt_sum2;
}

u_llong get_tcp_connection_a2b_rtt_dupack(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_rtt_dupack;
}

u_llong get_tcp_connection_a2b_rtt_triple_dupack(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_rtt_triple_dupack;
}

u_llong get_tcp_connection_a2b_rtt_amback(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_rtt_amback;
}

u_llong get_tcp_connection_a2b_rtt_cumack(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_rtt_cumack;
}

u_llong get_tcp_connection_a2b_rtt_nosample(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_rtt_nosample;
}

/* A->B direction retransmission timing accessors */
u_long get_tcp_connection_a2b_retr_max(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_retr_max;
}

u_long get_tcp_connection_a2b_retr_min_tm(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_retr_min_tm;
}

u_long get_tcp_connection_a2b_retr_max_tm(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_retr_max_tm;
}

double get_tcp_connection_a2b_retr_tm_sum(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return c->tcp_conns[idx].a2b_retr_tm_sum;
}

double get_tcp_connection_a2b_retr_tm_sum2(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return c->tcp_conns[idx].a2b_retr_tm_sum2;
}

/* B->A direction RTT stats accessors */
u_long get_tcp_connection_b2a_rtt_count(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_rtt_count;
}

u_long get_tcp_connection_b2a_rtt_min(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_rtt_min;
}

u_long get_tcp_connection_b2a_rtt_max(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_rtt_max;
}

double get_tcp_connection_b2a_rtt_sum(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return c->tcp_conns[idx].b2a_rtt_sum;
}

double get_tcp_connection_b2a_rtt_sum2(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return c->tcp_conns[idx].b2a_rtt_sum2;
}

u_llong get_tcp_connection_b2a_rtt_dupack(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_rtt_dupack;
}

u_llong get_tcp_connection_b2a_rtt_triple_dupack(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_rtt_triple_dupack;
}

u_llong get_tcp_connection_b2a_rtt_amback(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_rtt_amback;
}

u_llong get_tcp_connection_b2a_rtt_cumack(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_rtt_cumack;
}

u_llong get_tcp_connection_b2a_rtt_nosample(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_rtt_nosample;
}

/* B->A direction retransmission timing accessors */
u_long get_tcp_connection_b2a_retr_max(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_retr_max;
}

u_long get_tcp_connection_b2a_retr_min_tm(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_retr_min_tm;
}

u_long get_tcp_connection_b2a_retr_max_tm(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_retr_max_tm;
}

double get_tcp_connection_b2a_retr_tm_sum(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return c->tcp_conns[idx].b2a_retr_tm_sum;
}

double get_tcp_connection_b2a_retr_tm_sum2(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return c->tcp_conns[idx].b2a_retr_tm_sum2;
}

/* Initial window, stream length, missed data accessors */
u_long get_tcp_connection_a2b_initialwin_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_initialwin_bytes;
}

u_long get_tcp_connection_a2b_initialwin_segs(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_initialwin_segs;
}

u_llong get_tcp_connection_a2b_stream_length(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_stream_length;
}

u_llong get_tcp_connection_a2b_missed_data(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_missed_data;
}

u_llong get_tcp_connection_a2b_idle_max(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_idle_max;
}

double get_tcp_connection_a2b_data_xmit_time(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return c->tcp_conns[idx].a2b_data_xmit_time;
}

u_long get_tcp_connection_b2a_initialwin_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_initialwin_bytes;
}

u_long get_tcp_connection_b2a_initialwin_segs(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_initialwin_segs;
}

u_llong get_tcp_connection_b2a_stream_length(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_stream_length;
}

u_llong get_tcp_connection_b2a_missed_data(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_missed_data;
}

u_llong get_tcp_connection_b2a_idle_max(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_idle_max;
}

double get_tcp_connection_b2a_data_xmit_time(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0.0;
    return c->tcp_conns[idx].b2a_data_xmit_time;
}

/* TCP options accessors */
Bool get_tcp_connection_a2b_f1323_ws(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_f1323_ws;
}

Bool get_tcp_connection_a2b_f1323_ts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_f1323_ts;
}

Bool get_tcp_connection_a2b_fsack_req(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].a2b_fsack_req;
}

Bool get_tcp_connection_b2a_f1323_ws(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_f1323_ws;
}

Bool get_tcp_connection_b2a_f1323_ts(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_f1323_ts;
}

Bool get_tcp_connection_b2a_fsack_req(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->tcp_conns || idx < 0 || idx >= c->num_tcp_conns)
        return 0;
    return c->tcp_conns[idx].b2a_fsack_req;
}

/* UDP connection accessors */
char* get_udp_connection_a_endpoint(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return empty_string;
    if (!c->udp_conns[idx].a_endpoint)
        return empty_string;
    return c->udp_conns[idx].a_endpoint;
}

char* get_udp_connection_b_endpoint(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return empty_string;
    if (!c->udp_conns[idx].b_endpoint)
        return empty_string;
    return c->udp_conns[idx].b_endpoint;
}

char* get_udp_connection_a_hostname(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return empty_string;
    if (!c->udp_conns[idx].a_hostname)
        return empty_string;
    return c->udp_conns[idx].a_hostname;
}

char* get_udp_connection_b_hostname(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return empty_string;
    if (!c->udp_conns[idx].b_hostname)
        return empty_string;
    return c->udp_conns[idx].b_hostname;
}

char* get_udp_connection_a_portname(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return empty_string;
    if (!c->udp_conns[idx].a_portname)
        return empty_string;
    return c->udp_conns[idx].a_portname;
}

char* get_udp_connection_b_portname(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return empty_string;
    if (!c->udp_conns[idx].b_portname)
        return empty_string;
    return c->udp_conns[idx].b_portname;
}

double get_udp_connection_first_time(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return 0.0;
    return (double)c->udp_conns[idx].first_time.tv_sec + (double)c->udp_conns[idx].first_time.tv_usec / 1000000.0;
}

double get_udp_connection_last_time(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return 0.0;
    return (double)c->udp_conns[idx].last_time.tv_sec + (double)c->udp_conns[idx].last_time.tv_usec / 1000000.0;
}

double get_udp_connection_elapsed_time(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return 0.0;
    return c->udp_conns[idx].elapsed_time;
}

u_llong get_udp_connection_a2b_packets(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return 0;
    return c->udp_conns[idx].a2b_packets;
}

u_llong get_udp_connection_a2b_data_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return 0;
    return c->udp_conns[idx].a2b_data_bytes;
}

u_long get_udp_connection_a2b_min_dg_size(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return 0;
    return c->udp_conns[idx].a2b_min_dg_size;
}

u_long get_udp_connection_a2b_max_dg_size(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return 0;
    return c->udp_conns[idx].a2b_max_dg_size;
}

double get_udp_connection_a2b_throughput(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return 0.0;
    return c->udp_conns[idx].a2b_throughput;
}

u_llong get_udp_connection_b2a_packets(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return 0;
    return c->udp_conns[idx].b2a_packets;
}

u_llong get_udp_connection_b2a_data_bytes(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return 0;
    return c->udp_conns[idx].b2a_data_bytes;
}

u_long get_udp_connection_b2a_min_dg_size(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return 0;
    return c->udp_conns[idx].b2a_min_dg_size;
}

u_long get_udp_connection_b2a_max_dg_size(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return 0;
    return c->udp_conns[idx].b2a_max_dg_size;
}

double get_udp_connection_b2a_throughput(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return 0.0;
    return c->udp_conns[idx].b2a_throughput;
}

char* get_udp_connection_filename(void* ctx, int idx) {
    trace_context* c = (trace_context*)ctx;
    if (!c || !c->udp_conns || idx < 0 || idx >= c->num_udp_conns)
        return empty_string;
    if (!c->udp_conns[idx].filename)
        return empty_string;
    return c->udp_conns[idx].filename;
}

int tcptrace_analyze_packets(void* ctx,
                            double* timestamps,
                            int* captured_lens,
                            unsigned char* packets_flat,
                            int num_packets,
                            int linktype) {
    int i;
    struct timeval *tv_array;
    unsigned char **packet_ptrs;

    if (!ctx || !timestamps || !captured_lens || !packets_flat || num_packets <= 0)
        return -1;

    tv_array = (struct timeval *)malloc(num_packets * sizeof(struct timeval));
    if (!tv_array)
        return -1;

    packet_ptrs = (unsigned char **)malloc(num_packets * sizeof(unsigned char *));
    if (!packet_ptrs) {
        free(tv_array);
        return -1;
    }

    int offset = 0;
    for (i = 0; i < num_packets; i++) {
        double ts = timestamps[i];
        long tv_sec = (long)ts;
        long tv_usec = (long)((ts - (double)tv_sec) * 1000000.0);
        tv_array[i].tv_sec = tv_sec;
        tv_array[i].tv_usec = tv_usec;
        packet_ptrs[i] = packets_flat + offset;
        offset += captured_lens[i];
    }

    int result = tcptrace_analyze_packets_direct(ctx, tv_array, captured_lens, packet_ptrs, num_packets, linktype);

    free(tv_array);
    free(packet_ptrs);

    return result;
}

int tcptrace_analyze_packets_with_linktype(void* ctx,
                                   double* timestamps,
                                   int* captured_lens,
                                   unsigned char* packets_flat,
                                   int num_packets,
                                   int linktype) {
    return tcptrace_analyze_packets(ctx, timestamps, captured_lens, packets_flat, num_packets, linktype);
}