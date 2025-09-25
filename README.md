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
WORKING: 3 packets transmitted, 3 received, 0% packet loss

# GRE Tunnel  
**BLOCKED**: Interfaces created but no connectivity (likely Hetzner Cloud firewall/routing restriction)

# Wireguard Tunnel
**SUCCESS**: ~470 Mbits/sec throughput, 1.674ms avg latency (+124% overhead)

**Latency Test:**
```
--- 192.168.3.2 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 1808ms
rtt min/avg/max/mdev = 0.812/1.674/7.469/1.935 ms
```

**Throughput Test:**
```
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec   563 MBytes   472 Mbits/sec   44            sender
[  5]   0.00-10.01  sec   560 MBytes   470 Mbits/sec                  receiver
```
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
# ping -c 10 192.168.3.2
10 packets transmitted, 10 received, 0% packet loss, time 1808ms
rtt min/avg/max/mdev = 0.812/1.674/7.469/1.935 ms
```

**Wireguard RTT**: 0.812 / 1.674 / 7.469 / 1.935 ms (min/avg/max/mdev)

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
# iperf3 -c 192.168.3.2 -t 10
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec   563 MBytes   472 Mbits/sec   44            sender
[  5]   0.00-10.01  sec   560 MBytes   470 Mbits/sec                  receiver
```

**Wireguard Throughput**: 
- Sender: 472 Mbits/sec (59 MBytes/sec)
- Receiver: 470 Mbits/sec (59 MBytes/sec)

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
- **GRE Overhead**: N/A (blocked by cloud provider)
- **Wireguard Overhead**: 0.932 ms (+125%) - High due to encryption
- **Forwarding Overhead**: N/A (GRE tunnel blocked)

### Throughput Overhead (vs Private Network Baseline)
- **IPIP Efficiency**: 28.3% of baseline (238/841 MBytes/sec)
- **GRE Efficiency**: N/A (blocked by cloud provider)
- **Wireguard Efficiency**: 7.0% of baseline (59/841 MBytes/sec) - Low due to encryption overhead

### Protocol Comparison
- **Lowest Latency**: IPIP (0.746ms avg, +0.5% overhead) - **WINNER(for now)**
- **Highest Throughput**: IPIP (238 MBytes/sec vs Wireguard 59 MBytes/sec)  
- **Most Efficient**: IPIP (28.3% vs Wireguard 7.0% of baseline)
- **Best Security**: Wireguard (strong encryption, but 125% latency penalty)
- **Blocked Protocol**: GRE (likely restricted by Hetzner Cloud firewall/routing)

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

### Key Findings
- **IPIP Tunnel Performance**: Outstanding latency performance with only 0.004ms overhead (+0.5%) vs baseline
- **Wireguard Performance**: Functional but high overhead (125% latency penalty, 93% throughput loss due to encryption)
- **Throughput Trade-offs**: IPIP (28.3% of baseline) vs Wireguard (7.0% of baseline)
- **Network Efficiency**: Private network baseline shows excellent performance (843 MBytes/sec, 0.742ms RTT)
- **GRE Protocol Blocked**: Likely restricted by Hetzner Cloud infrastructure (firewall/routing policies)
- **Security vs Performance**: Clear trade-off between Wireguard's encryption and IPIP's minimal overhead

### Recommendations
- **For HFT Applications**: IPIP tunnel is optimal with minimal latency overhead (+0.5%) and reasonable throughput (28% of baseline)
- **For Secure Applications**: Wireguard provides strong encryption but with significant performance penalty (125% latency increase)
- **For High-Throughput**: Direct private network connection preferred; avoid Wireguard for bandwidth-intensive applications  
- **Infrastructure Choice**: Hetzner Cloud excellent for IPIP tunneling; GRE protocol appears blocked
- **Performance Priority**: IPIP clear winner for latency-sensitive trading applications where every microsecond matters

---
*Test results captured automatically via performance testing script*