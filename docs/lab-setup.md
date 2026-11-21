# Lab Setup Guide

## Phase 1 - Isolated Network and VMs

### Requirements

| VM | RAM | vCPU | Disk |
|---|---|---|---|
| wazuh-server | 4 GB or more | 2 | 50 GB |
| linux-endpoint | 2 GB | 1 | 25 GB |

On an 8 GB host, keep other heavy applications closed while both VMs run. If a VM freezes (soft lockup), use **Machine > Reset**; the disk is not affected.

### Downloads

- VirtualBox 7.1 or newer
- Ubuntu Server ISO (LTS)

### Host-only network

1. VirtualBox > File > Tools > Network Manager > Host-only Networks.
2. Use or create an adapter with IPv4 `192.168.56.1/24`.
3. Disable its DHCP server.

### Per-VM network

| Adapter | Type | When |
|---|---|---|
| Adapter 1 | Host-only | Always |
| Adapter 2 | NAT | Installation only, then uncheck **Cable Connected** |

### Static IPs

`/etc/netplan/50-lab.yaml` on wazuh-server (use `.30` on linux-endpoint):

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      addresses: [192.168.56.10/24]
    enp0s8:
      dhcp4: true
```

```bash
sudo chmod 600 /etc/netplan/50-lab.yaml
sudo netplan apply
```

## Phase 2 - Wazuh Server

```bash
git clone <your-repo-url> mini-soc-lab && cd mini-soc-lab
sudo bash scripts/server/install-wazuh.sh
```

Open `https://192.168.56.10` from the host and log in as `admin` with the printed password.

## Phase 3 - Deploy Detections and Agent Group

Run before installing the agent so the `linux` group exists:

```bash
sudo bash scripts/server/deploy-detections.sh
```

## Phase 4 - Linux Endpoint

```bash
sudo bash scripts/linux/install-agent.sh 192.168.56.10
```

Verify on the server:

```bash
sudo /var/ossec/bin/agent_control -l
```

The agent must show `Active`.

## Phase 5 - Honeypot

```bash
sudo bash scripts/linux/install-cowrie.sh
```

Start Cowrie as the `cowrie` user and confirm it listens on port 2222:

```bash
sudo -u cowrie -H bash -c "cd /home/cowrie/cowrie && cowrie-env/bin/cowrie start"
ss -tlnp | grep 2222
```

Cowrie must be started again after every reboot of the endpoint. To collect its log, add this block to `/var/ossec/etc/ossec.conf` on the endpoint (the shared group configuration in `wazuh/shared/linux/agent.conf` carries the same setting) and restart the agent:

```xml
<localfile>
  <location>/home/cowrie/cowrie/var/log/cowrie/cowrie.json</location>
  <log_format>json</log_format>
</localfile>
```

## Phase 6 - Isolate

Disconnect the NAT adapter on every VM, then confirm from each VM:

```bash
ping -c 2 8.8.8.8
ping -c 2 192.168.56.10
```

The first must fail and the second must succeed.

## Phase 7 - Validate and Attack

1. Run the offline checks in [tests/logtest-samples.md](../tests/logtest-samples.md).
2. Run the live simulations in [attack-simulations.md](attack-simulations.md).
3. Capture screenshots as described in [dashboard.md](dashboard.md).
