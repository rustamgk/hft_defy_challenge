# Performance Testing Instructions

Manual performance testing commands to run directly on the deployed NixOS servers.

## Server Setup

- **Server1** (91.98.144.4): Forwarding node with tunnel endpoints
- **Server2** (91.98.144.5): Testing client node

## Prerequisites

1. **Deploy NixOS configurations** using `./deploy-direct.sh`
2. **Verify deployment** using `./validate-direct.sh`
3. **Confirm tunnel connectivity**:
   ```bash
   ssh -i ~/.ssh/hft_defy root@91.98.144.5
   ping -c 3 192.168.1.1  # IPIP
   ping -c 3 192.168.2.1  # GRE  
   ping -c 3 192.168.3.1  # Wireguard
   ```

## Performance Tests

### 1. Throughput Testing

**On Server1** (start iperf3 server):
```bash
ssh -i ~/.ssh/hft_defy root@91.98.144.4
iperf3 -s
```

**On Server2** (run throughput tests):
```bash
ssh -i ~/.ssh/hft_defy root@91.98.144.5

# Test IPIP tunnel throughput
iperf3 -c 192.168.1.1 -t 10 -f M

# Test GRE tunnel throughput  
iperf3 -c 192.168.2.1 -t 10 -f M

# Test Wireguard tunnel throughput
iperf3 -c 192.168.3.1 -t 10 -f M
```

### 2. Latency Testing

**On Server2** (run latency tests):
```bash
ssh -i ~/.ssh/hft_defy root@91.98.144.5

# Test IPIP tunnel latency
ping -c 10 192.168.1.1

# Test GRE tunnel latency
ping -c 10 192.168.2.1

# Test Wireguard tunnel latency  
ping -c 10 192.168.3.1
```

### 3. Forwarding Path Testing

**On Server2** (test GRE → Wireguard forwarding):
```bash
ssh -i ~/.ssh/hft_defy root@91.98.144.5

# Test forwarding overhead: GRE interface to Wireguard endpoint
ping -c 10 -I 192.168.2.2 192.168.3.1
```

This tests the forwarding path where packets from Server2's GRE interface (192.168.2.2) are forwarded through Server1 to reach the Wireguard endpoint (192.168.3.1).

## Baseline Testing

For comparison, test direct connectivity:
```bash
ssh -i ~/.ssh/hft_defy root@91.98.144.5

# Direct server-to-server latency (baseline)
ping -c 10 91.98.144.4

# Direct server-to-server throughput (baseline)
iperf3 -c 91.98.144.4 -t 10 -f M
```

## Key Metrics to Record

### Throughput Results
Record the final "sender" and "receiver" values from iperf3 output:
- **IPIP Throughput**: ___ Mbits/sec (sender), ___ Mbits/sec (receiver)
- **GRE Throughput**: ___ Mbits/sec (sender), ___ Mbits/sec (receiver)  
- **Wireguard Throughput**: ___ Mbits/sec (sender), ___ Mbits/sec (receiver)
- **Direct Baseline**: ___ Mbits/sec (sender), ___ Mbits/sec (receiver)

### Latency Results  
Record the "min/avg/max/mdev" values from ping output:
- **IPIP RTT**: ___ / ___ / ___ / ___ ms
- **GRE RTT**: ___ / ___ / ___ / ___ ms
- **Wireguard RTT**: ___ / ___ / ___ / ___ ms  
- **Forwarding RTT**: ___ / ___ / ___ / ___ ms
- **Direct Baseline**: ___ / ___ / ___ / ___ ms

### Analysis Points
- **Throughput overhead**: Compare tunnel vs baseline throughput
- **Latency overhead**: Compare tunnel vs baseline RTT
- **Forwarding cost**: Compare direct tunnel vs forwarding path RTT
- **Protocol efficiency**: Compare IPIP vs GRE vs Wireguard performance

## Troubleshooting

If tests fail:
1. **Check tunnel status**: `systemctl status systemd-networkd`
2. **Restart networking**: `systemctl restart systemd-networkd`  
3. **Verify interfaces**: `ip addr show`
4. **Check routing**: `ip route show`
5. **Test basic connectivity**: `ping 91.98.144.4`

## Advanced Testing

For more detailed analysis:
```bash
# CPU usage during throughput test
top -p $(pgrep iperf3)

# Network interface statistics
watch -n 1 'cat /proc/net/dev'

# Tunnel-specific interface stats
ip -s link show ipip0
ip -s link show gre0  
ip -s link show wg0
```