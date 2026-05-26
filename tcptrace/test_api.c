/*
 * test_api.c - tcptrace API test program
 *
 * This test program demonstrates the new thread-safe tcptrace API.
 * It uses the fork() or OpenMP parallel processing depending on compiler flags.
 *
 * Compile:
 *   gcc -fopenmp -I. test_api.c -lgomp -lpthread -lm -o test_api
 *
 * Usage:
 *   ./test_api [pcap_file] [num_threads]
 */

#if _OPENMP
#include <omp.h>
#endif
#include "tcptrace.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>

/* External globals from trace.c and tcptrace.c */
extern u_long bad_ip_checksums;
extern u_long bad_tcp_checksums;
extern u_long bad_udp_checksums;

void print_usage(const char *prog);
double get_elapsed(struct timeval start, struct timeval end);
void print_results(trace_context *ctx);
int test_parallel(const char *filename, int num_threads);

int main(int argc, char *argv[])
{
    const char *pcap_file;
    int num_threads = 4;
    int result;

#ifdef _OPENMP
    printf("=== tcptrace API Test (OpenMP Mode) ===\n");
    printf("OpenMP supported: YES\n");
    printf("Max threads: %d\n", omp_get_max_threads());
    num_threads = omp_get_max_threads();
    if (num_threads > 8)
        num_threads = 8;
#else
    printf("=== tcptrace API Test (Fork Mode) ===\n");
    printf("OpenMP supported: NO (using fork)\n");
#endif

    if (argc < 2) {
        pcap_file = "part4/Data_lake/NonTor-fixed/qos/facebook_Audio/"
                   "flow_total_facebook_Audio_TCP_31.13.93.3_10.152.152.11_443_36323.pcap";
    } else {
        pcap_file = argv[1];
    }

    if (argc >= 3) {
        num_threads = atoi(argv[2]);
        if (num_threads <= 0)
            num_threads = 4;
    }

    if (access(pcap_file, F_OK) != 0) {
        fprintf(stderr, "Error: File not found: %s\n", pcap_file);
        fprintf(stderr, "\nUsage: %s [pcap_file] [num_threads]\n", argv[0]);
        return 1;
    }

    printf("\n");
    printf("File: %s\n", pcap_file);
    printf("Threads: %d\n\n", num_threads);

    result = test_parallel(pcap_file, num_threads);

    return result;
}

int test_parallel(const char *filename, int num_threads)
{
    trace_context *ctx;
    struct timeval wallclock_start, wallclock_finished;
    int result;

    ctx = tcptrace_create_context();
    if (!ctx) {
        fprintf(stderr, "Error: Failed to create context\n");
        return 1;
    }

    trace_init();
    udptrace_init();
    plot_init();

    printf("Starting analysis...\n\n");

    gettimeofday(&wallclock_start, NULL);

#ifdef _OPENMP
    printf("Using OpenMP parallel processing\n");
    result = tcptrace_analyze_file(ctx, filename, num_threads);
#else
    printf("Using fork() parallel processing\n");
    result = tcptrace_analyze_file(ctx, filename, num_threads);
#endif

    gettimeofday(&wallclock_finished, NULL);

    if (result != 0) {
        fprintf(stderr, "Error: Analysis failed with code: %d\n", result);
        trace_done();
        udptrace_done();
        plotter_done();
        tcptrace_destroy_context(ctx);
        return 1;
    }

    print_results(ctx);

    printf("\n");
    printf("Processing time: %s\n", elapsed2str(get_elapsed(wallclock_start, wallclock_finished)));

    trace_done();
    udptrace_done();
    plotter_done();
    tcptrace_destroy_context(ctx);

    return 0;
}

void print_results(trace_context *ctx)
{
    printf("=== Analysis Results ===\n");
    printf("Packets seen:      %lu\n", pnum);
    printf("TCP connections:   %lu\n", tcp_trace_count);
    printf("UDP connections: %lu\n", udp_trace_count);

    if (verify_checksums) {
        printf("Bad IP checksums:   %lu\n", bad_ip_checksums);
        printf("Bad TCP checksums: %lu\n", bad_tcp_checksums);
        if (do_udp)
            printf("Bad UDP checksums: %lu\n", bad_udp_checksums);
    }

    if (!ZERO_TIME(&first_packet) && !ZERO_TIME(&last_packet)) {
        printf("First packet:    %s\n", ts2ascii(&first_packet));
        printf("Last packet:     %s\n", ts2ascii(&last_packet));
        printf("Trace duration: %s\n", elapsed2str(elapsed(first_packet, last_packet)));
    }
}

double get_elapsed(struct timeval start, struct timeval end)
{
    double etime = (end.tv_sec - start.tv_sec) +
                  (end.tv_usec - start.tv_usec) / 1000000.0;
    if (etime < 0)
        etime = -etime;
    return etime;
}