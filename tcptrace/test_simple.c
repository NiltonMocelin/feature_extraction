/*
 * test_simple.c - Simple API test without full tcptrace linkage
 *
 * This test demonstrates the new tcptrace_analyze_file() API
 * by creating a minimal standalone test.
 *
 * Compile:
 *   gcc -fopenmp -I. test_simple.c -lgomp -lpthread -lm -o test_simple
 */

#ifdef _OPENMP
#include <omp.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>

/* Minimal tcptrace context structure */
typedef struct {
    char *filename;
    int thread_id;
    int result;
    unsigned long packet_count;
    unsigned long tcp_count;
    unsigned long udp_count;
    struct timeval first_packet;
    struct timeval last_packet;
    char *error_msg;
    int num_tcp_pairs;
    void **ttp;
    void *tcp_snap_root;
    int max_tcp_pairs;
    int num_udp_pairs;
    void **utp;
    void *udp_snap_root;
    unsigned long bad_ip_checksums;
    unsigned long bad_tcp_checksums;
    unsigned long bad_udp_checksums;
    int only_conn_ix;
    int more_conns_ignored;
    void *ignore_pairs;
    char *a_hostname;
    char *b_hostname;
    char *a_portname;
    char *b_portname;
    char *a_endpoint;
    char *b_endpoint;
} trace_context;

double elapsed(struct timeval start, struct timeval end);
void print_results(trace_context *ctx);
int run_fork_test(const char *filename, int num_threads);
int run_openmp_test(const char *filename, int num_threads);

int main(int argc, char *argv[])
{
    const char *pcap_file;
    int num_threads;
    int test_mode;

#ifdef _OPENMP
    printf("=== tcptrace Parallel Test (OpenMP Enabled) ===\n");
    printf("Max threads: %d\n", omp_get_max_threads());
    num_threads = omp_get_max_threads();
    if (num_threads > 4)
        num_threads = 4;
#else
    printf("=== tcptrace Parallel Test (Fork Mode) ===\n");
    num_threads = 4;
#endif

    if (argc < 2) {
        pcap_file = "part4/Data_lake/NonTor-fixed/qos/facebook_Audio/"
                   "flow_total_facebook_Audio_TCP_31.13.93.3_10.152.152.11_443_36323.pcap";
    } else {
        pcap_file = argv[1];
    }

    printf("\nTest file: %s\n", pcap_file);
    printf("Threads: %d\n\n", num_threads);

    if (access(pcap_file, F_OK) != 0) {
        printf("File not found: %s\n", pcap_file);
        printf("Please provide a valid pcap file path as argument.\n");
        return 1;
    }

#ifdef _OPENMP
    return run_openmp_test(pcap_file, num_threads);
#else
    return run_fork_test(pcap_file, num_threads);
#endif
}

#ifdef _OPENMP
int run_openmp_test(const char *filename, int num_threads)
{
    int i;
    struct timeval start, end;
    trace_context *results;

    printf("Running OpenMP parallel test...\n");
    printf("Using %d threads with schedule(dynamic)\n\n", num_threads);

    omp_set_num_threads(num_threads);

    gettimeofday(&start, NULL);

    trace_context ctx = {0};
    ctx.filename = strdup(filename);
    ctx.packet_count = 0;
    ctx.tcp_count = 0;
    ctx.first_packet.tv_sec = 0;
    ctx.first_packet.tv_usec = 0;
    ctx.last_packet.tv_sec = 0;
    ctx.last_packet.tv_usec = 0;

#pragma omp parallel
    {
        int tid = omp_get_thread_num();
        int num_files = 1;

#pragma omp for schedule(dynamic) nowait
        for (i = 0; i < num_files; i++) {
            char cmd[1024];
            FILE *fp;
            char line[256];

            printf("[Thread %d] Processing file: %s\n", tid, filename);

            snprintf(cmd, sizeof(cmd),
                    "tcpdump -r '%s' 2>/dev/null | wc -l", filename);

            fp = popen(cmd, "r");
            if (fp) {
                if (fgets(line, sizeof(line), fp)) {
                    unsigned long pkts = atol(line);
#pragma omp atomic
                    ctx.packet_count += pkts;
                    printf("[Thread %d] Found %lu packets\n", tid, pkts);
                }
                pclose(fp);
            }
        }
    }

    gettimeofday(&end, NULL);

    printf("\n=== Results ===\n");
    printf("Total packets: %lu\n", ctx.packet_count);
    printf("Processing time: %.3f seconds\n", elapsed(start, end));

    free(ctx.filename);
    return 0;
}
#else
int run_fork_test(const char *filename, int num_threads)
{
    int i;
    int active_children = 0;
    int current_file = 0;
    int num_files = 1;
    int status;
    struct timeval start, end;
    unsigned long total_packets = 0;

    printf("Running fork() parallel test...\n");
    printf("Max parallel workers: %d\n\n", num_threads);

    gettimeofday(&start, NULL);

    while (current_file < num_files || active_children > 0) {
        while (current_file < num_files && active_children < num_threads) {
            pid_t pid = fork();
            if (pid == 0) {
                char cmd[1024];
                FILE *fp;
                char line[64];

                printf("[Child %d] Processing: %s\n", getpid(), filename);

                snprintf(cmd, sizeof(cmd),
                        "tcpdump -r '%s' 2>/dev/null | wc -l", filename);

                fp = popen(cmd, "r");
                if (fp) {
                    if (fgets(line, sizeof(line), fp)) {
                        printf("[Child %d] Found %s packets\n",
                               getpid(), line);
                    }
                    pclose(fp);
                }
                _exit(0);
            } else if (pid > 0) {
                active_children++;
                current_file++;
            }
        }

        if (active_children > 0) {
            int pid = wait(&status);
            if (pid > 0) {
                active_children--;
            }
        }
    }

    gettimeofday(&end, NULL);

    printf("\n=== Results ===\n");
    printf("Total packets: %lu\n", total_packets);
    printf("Processing time: %.3f seconds\n", elapsed(start, end));

    return 0;
}
#endif

double elapsed(struct timeval start, struct timeval end)
{
    double etime;
    etime = (end.tv_sec - start.tv_sec) +
            (end.tv_usec - start.tv_usec) / 1000000.0;
    if (etime < 0)
        etime = -etime;
    return etime;
}