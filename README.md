# HFT DEFY Challenge - Tunnel Performance Test Results

## Test Environment

- **Date**: September 25, 2025
- **Server1**: 91.98.144.4 (Forwarding node)
- **Server2**: 91.98.95.57 (Testing client)
- **Private Network**: 10.0.0.0/24
  - Server1 Private IP: 10.0.0.2
  - Server2 Private IP: 10.0.0.3

## Tunnel Configuration

### Network Assignments
- **IPIP Tunnel**: 192.168.1.0/24
  - Server1: 192.168.1.1
  - Server2: 192.168.1.2
- **GRE Tunnel**: 192.168.2.0/24
  - Server1: 192.168.2.1
  - Server2: 192.168.2.2
- **Wireguard Tunnel**: 192.168.3.0/24
  - Server1: 192.168.3.1
  - Server.2: 192.168.3.2

## Connectivity Tests

### Basic Tunnel Connectivity
```
# IPIP Tunnel
✅ WORKING: 3 packets transmitted, 3 received, 0% packet loss

# GRE Tunnel  
❌ ISSUE: Connection hanging/timeout

# Wireguard Tunnel
❌ ISSUE: "Required key not available" - Wireguard keys not properly configured
```

## Latency Testing Results

### IPIP Tunnel Latency
```bash
# ping -c 10 192.168.1.1
10 packets transmitted, 10 received, 0% packet loss, time 9195ms
rtt min/avg/max/mdev = 0.561/0.746/1.639/0.309 ms
```

**IPIP RTT**: 0.561 / 0.746 / 1.639 / 0.309 ms (min/avg/max/mdev)

### GRE Tunnel Latency
```bash
# ping -c 10 192.168.2.1
[PENDING - TO BE CAPTURED]
```

**GRE RTT**: ___ / ___ / ___ / ___ ms (min/avg/max/mdev)

### Wireguard Tunnel Latency
```bash
# ping -c 10 192.168.3.1
[PENDING - TO BE CAPTURED]
```

**Wireguard RTT**: ___ / ___ / ___ / ___ ms (min/avg/max/mdev)

### Baseline Latency (Direct Connection)
```bash
# ping -c 10 10.0.0.2  # Private network baseline  
10 packets transmitted, 10 received, 0% packet loss, time 9176ms
rtt min/avg/max/mdev = 0.533/0.742/2.089/0.452 ms
```

**Direct Private RTT**: 0.533 / 0.742 / 2.089 / 0.452 ms (min/avg/max/mdev)

```bash
# ping -c 10 91.98.144.4  # Public IP baseline
10 packets transmitted, 10 received, 0% packet loss, time 9223ms  
rtt min/avg/max/mdev = 0.434/0.903/4.116/1.072 ms
```

**Direct Public RTT**: 0.434 / 0.903 / 4.116 / 1.072 ms (min/avg/max/mdev)

## Throughput Testing Results

### IPIP Tunnel Throughput
```bash
# iperf3 -c 192.168.1.1 -t 10 -f M
[  5]   0.00-10.00  sec  2.32 GBytes   238 MBytes/sec    0            sender
[  5]   0.00-10.00  sec  2.32 GBytes   237 MBytes/sec                  receiver
```

**IPIP Throughput**: 
- Sender: 238 MBytes/sec
- Receiver: 237 MBytes/sec

### GRE Tunnel Throughput
```bash
# iperf3 -c 192.168.2.1 -t 10 -f M
[PENDING - TO BE CAPTURED]
```

**GRE Throughput**: 
- Sender: ___ Mbits/sec
- Receiver: ___ Mbits/sec

### Wireguard Tunnel Throughput
```bash
# iperf3 -c 192.168.3.1 -t 10 -f M
[PENDING - TO BE CAPTURED]
```

**Wireguard Throughput**: 
- Sender: ___ Mbits/sec
- Receiver: ___ Mbits/sec

### Baseline Throughput (Direct Connection)
```bash
# iperf3 -c 10.0.0.2 -t 10 -f M  # Private network baseline
[  5]   0.00-10.00  sec  8.24 GBytes   843 MBytes/sec  33354            sender
[  5]   0.00-10.00  sec  8.21 GBytes   841 MBytes/sec                  receiver
```

**Direct Private Throughput**: 
- Sender: 843 MBytes/sec  
- Receiver: 841 MBytes/sec

```bash
# iperf3 -c 91.98.144.4 -t 10 -f M  # Public IP baseline
[PENDING - TO BE CAPTURED]
```

**Direct Public Throughput**: 
- Sender: ___ Mbits/sec
- Receiver: ___ Mbits/sec

## Forwarding Path Testing

### GRE → Wireguard Forwarding
```bash
# ping -c 10 -I 192.168.2.2 192.168.3.1
[PENDING - TO BE CAPTURED]
```

**Forwarding RTT**: ___ / ___ / ___ / ___ ms (min/avg/max/mdev)

## Performance Analysis

### Latency Overhead (vs Private Network Baseline)
- **IPIP Overhead**: 0.004 ms (+0.5%) - EXCELLENT!
- **GRE Overhead**: N/A (connection issues)
- **Wireguard Overhead**: N/A (key configuration issues)
- **Forwarding Overhead**: N/A (pending GRE/WG fixes)

### Throughput Overhead (vs Private Network Baseline)
- **IPIP Efficiency**: 28.3% of baseline (238/841 MBytes/sec)
- **GRE Efficiency**: N/A (connection issues)
- **Wireguard Efficiency**: N/A (key configuration issues)

### Protocol Comparison
- **Lowest Latency**: [PENDING]
- **Highest Throughput**: [PENDING]
- **Most Efficient**: [PENDING]

## System Resource Usage

### CPU Usage During Tests
```bash
# top -p $(pgrep iperf3)
[PENDING - TO BE CAPTURED]
```

### Network Interface Statistics
```bash
# ip -s link show ipip0
[PENDING - TO BE CAPTURED]

# ip -s link show gre0
[PENDING - TO BE CAPTURED]

# ip -s link show wg0
[PENDING - TO BE CAPTURED]
```

## Conclusions

[TO BE FILLED AFTER ANALYSIS]

### Key Findings
- 
- 
- 

### Recommendations
- 
- 
- 

---
*Test results captured automatically via performance testing script*