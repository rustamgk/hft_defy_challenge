# HFT DeFy Challenge 

* Поднять две машины с NixOS на Hetzner в одной сети (нужна почта для инвайта в проект, где можно будет работать);
* Поднять три типа тоннелей между ними по локальной сети - IPIP, GRE, Wireguard (через никсос-конфиг с networking.useNetworkd = true;);
* Померять throughput и latency TCP по всем каналам — посчитать:
  * Среднюю скорость передачи, + по интервалам 1сек— медиану и 90ую персентиль;
  * RTT пингом: среднюю, медиану и 90ую персентиль.
* Настроить форвардинг между всеми тоннелями на одном из серверов, на втором померять средний RTT из GRE в Wireguard через этот форвардинг.

Simple manual network performance testing setup using NixOS on Hetzner Cloud with multiple tunnel types.

## Task Implementation

This project implements the complete task requirements with a manual approach:

### **Infrastructure Setup**
- **Two NixOS machines** on Hetzner Cloud
- **Manual deployment** - create servers through Hetzner Cloud console
- **Provisioning** - use the module from nixos-anywhere

### **Tunnel Configuration**  
Three tunnel types configured using `networking.useNetworkd = true`:
- **IPIP tunnel**: 192.168.1.0/24 network
- **GRE tunnel**: 192.168.2.0/24 network  
- **Wireguard tunnel**: 192.168.3.0/24 network

### **Performance Measurements**
**TCP Throughput Testing**:
- Simple iperf3 tests for each tunnel (maybe other tools we'll see)
- Manual result collection from console output 

**RTT Latency Testing**:
- Basic ping tests with 10-20 samples per tunnel
- Manual recording of avg RTT values

### **Network Topology**

Hetzner Private Network (10.0.0.0/24)
├── Server1 (10.0.0.10) - Forwarding Node
│   ├── IPIP: 192.168.1.1/24
│   ├── GRE: 192.168.2.1/24
│   └── Wireguard: 192.168.3.1/24
└── Server2 (10.0.0.20) - Testing Node  
    ├── IPIP: 192.168.1.2/24
    ├── GRE: 192.168.2.2/24
    └── Wireguard: 192.168.3.2/24
```

#### Forwarding Path
```
Server2 [GRE:192.168.2.2] 
    ↓
Server1 [GRE:192.168.2.1] → [Forwarding] → [WG:192.168.3.1]
    ↓
Server2 [WG:192.168.3.2]

