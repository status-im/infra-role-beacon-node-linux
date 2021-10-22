# Description

This role provisions a [Nimbus](https://nimbus.status.im/) installation that can act as an ETH2 network bootstrap node.

# Introduction

The role will checkout a branch from the
[nimbus-eth2](https://github.com/status-im/nimbus-eth2) repo, build and run it.

Each host can run multiple beacon nodes. Each node can be built from a different
branch (stable, unstable, testing, etc.) and will be run with systemd.

A timer is installed that will periodically pull changes from git and rebuild
the binaries.

# Ports

The service exposes three ports by default:

* `9000` - LibP2P peering port. Must __ALWAYS__ be public.
* `9200` - JSON RPC port. Must __NEVER__ be public.
* `9900` - Prometheus metrics port. Should not be public.

# Installation

Add to your `requirements.yml` file:
```yaml
- name: infra-role-beacon-node-linux
  src: git+git@github.com:status-im/infra-role-beacon-node-linux.git
  scm: git
```

# Configuration

The crucial settings are:
```yaml
# branch which should be built
beacon_node_repo_branch: 'stable'
# ethereum network to connect to
beacon_node_network: 'mainnet'
# optional setting for debug mode
beacon_node_log_level: 'DEBUG'
# Infura WebSocket URLs
beacon_node_web3_urls: ['wss://mainnet.infura.io/ws/v3/123qwe123qwe123qwe']
```
The order of WebSocket URLs matters. First is the default, the rest are fallbacks.

# Usage

Assuming the `stable` branch was built you can manage the service with:
```sh
systemctl start beacon-node-mainnet-stable
systemctl status beacon-node-mainnet-stable
systemctl stop beacon-node-mainnet-stable
```
You can view logs under:
```sh
tail -f /data/beacon-node-mainnet-stable/logs/service.log
```
The service will store all data in the `/data/beacon-node-mainnet-stable` directory.

# Building

A timer will be installed to build the image:
```sh
systemctl list-timers build-beacon-node-mainnet-stable
```
To rebuild the image:
```sh
systemctl start build-beacon-node-mainnet-stable.service
```
To check build logs use:
```sh
journalctl -u build-beacon-node-mainnet-stable.service
```

# Requirements

Due to being part of Status infra this role assumes availability of certain things:

* The `iptables-persistent` module
