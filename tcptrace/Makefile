# Makefile for tcptrace
#
# Usage:
#   make              - Build everything
#   make run         - Build and run test
#   make clean       - Clean up

CC = gcc
CFLAGS = -fopenmp -g -Wall -I.
LDFLAGS = -lgomp -lpthread -lm -lpcap

# Define macros matching setup.py
DEFINES = -D_GNU_SOURCE -DHAVE_CONFIG_H -DHAVE_MKSTEMP
DEFINES += -DBUILT_USER='"tcptrace"' -DBUILT_DATE='"today"' -DBUILT_HOST='"local"'

# All Source files
SOURCES_MAIN = tcptrace.c

SOURCES_LIB = avl.c compress.c dstring.c dyncounter.c erf.c etherpeek.c \
             gcache.c ipv6.c mfiles.c names.c netm.c netscout.c \
             nlanr.c ns.c output.c plotter.c pool.c poolaccess.c \
             print.c rexmit.c snoop.c snprintf_vms.c tcpdump.c \
             thruput.c trace.c udp.c version.c filter.c

SOURCES_MOD = mod_collie.c mod_http.c mod_inbounds.c mod_realtime.c \
             mod_rttgraph.c mod_slice.c mod_tcplib.c \
             mod_traffic.c

SOURCES_FLEX = flex_bison/filt_scanner.c flex_bison/filt_parser.c

SOURCES_ACCESSORS = tcptrace_accessors.c

SOURCES = $(SOURCES_MAIN) $(SOURCES_LIB) $(SOURCES_MOD) $(SOURCES_FLEX) $(SOURCES_ACCESSORS)
OBJECTS = $(SOURCES:.c=.o)

BINARY = tcptrace_bin

all: $(BINARY)

$(BINARY): $(OBJECTS)
	$(CC) $(CFLAGS) $(DEFINES) $(OBJECTS) $(LDFLAGS) -o $(BINARY)

%.o: %.c
	$(CC) $(CFLAGS) $(DEFINES) -c $< -o $@

run: $(BINARY)
	@echo "Running test..."
	@./$(BINARY)

clean:
	rm -f $(BINARY) *.o flex_bison/*.o