/*
 * test.c - Example program demonstrating tcptrace_analyze_file() API usage
 *
 * This file shows how to use the new thread-safe tcptrace API.
 * It can be compiled and run independently as a demonstration.
 *
 * Compile:
 *   gcc -fopenmp -I. test.c -lgomp -lpthread -lm -o test
 *
 * Usage:
 *   ./test [pcap_file] [num_threads]
 *
 * Example:
 *   ./test part4/Data_lake/NonTor-fixed/qos/facebook_Audio/\
 *          flow_total_facebook_Audio_TCP_31.13.93.3_10.152.152.11_443_36323.pcap 4
 */

#ifdef _OPENMP
#include <omp.h>
#endif
#include "tcptrace.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>

/* External globals that need to be declared */
extern u_long bad_ip_checksums;
extern u_long bad_tcp_checksums;
extern u_long bad_udp_checksums;

int main(int argc, char *argv[])
{
    trace_context *ctx;
    const char *pcap_file;
    int num_threads;
    int result;
    struct timeval start, end;

#ifdef _OPENMP
    printf("OpenMP Support: ENABLED\n");
    printf("Max threads: %d\n", omp_get_max_threads());
#else
    printf("OpenMP Support: DISABLED (fork mode)\n");
#endif

    if (argc < 2) {
        pcap_file = "part4/Data_lake/NonTor-fixed/qos/facebook_Audio/"
                   "flow_total_facebook_Audio_TCP_31.13.93.3_10.152.152.11_443_36323.pcap";
    } else {
        pcap_file = argv[1];
    }

    if (access(pcap_file, F_OK) != 0) {
        fprintf(stderr, "Error: File not found: %s\n", pcap_file);
        fprintf(stderr, "\nUsage: %s [pcap_file] [num_threads]\n", argv[0]);
        return 1;
    }

    num_threads = (argc >= 3) ? atoi(argv[2]) : 4;
    if (num_threads <= 0) num_threads = 4;

    printf("\nFile: %s\n", pcap_file);
    printf("Threads: %d\n\n", num_threads);

    /* Create thread-safe context */
    ctx = tcptrace_create_context();
    if (!ctx) {
        fprintf(stderr, "Error: Failed to create context\n");
        return 1;
    }

    /* Initialize modules */
    trace_init();
    udptrace_init();
    plot_init();

    printf("Starting analysis...\n");
    gettimeofday(&start, NULL);

    /* Call the new thread-safe API */
    result = tcptrace_analyze_file(ctx, pcap_file, num_threads);

    gettimeofday(&end, NULL);

    if (result != 0) {
        fprintf(stderr, "Analysis failed with code: %d\n", result);
    } else {
        printf("\n=== Results ===\n");
        printf("Packets:      %lu\n", pnum);
        printf("TCP conns:   %lu\n", tcp_trace_count);
        printf("UDP conns:   %lu\n", udp_trace_count);

        if (ctx->first_packet.tv_sec != 0 || ctx->first_packet.tv_usec != 0) {
            printf("First: %s\n", ts2ascii(&ctx->first_packet));
            printf("Last:  %s\n", ts2ascii(&ctx->last_packet));
        }

        double etime = (end.tv_sec - start.tv_sec) +
                     (end.tv_usec - start.tv_usec) / 1000000.0;
        printf("Time:  %.3f sec\n", etime);
    }

    /* Cleanup */
    trace_done();
    udptrace_done();
    plotter_done();
    tcptrace_destroy_context(ctx);

    return result;
}