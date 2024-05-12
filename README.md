# Description

This role provisions a [Nimbus](https://nimbus.status.im/) installation that can act as an ETH2 network bootstrap node.

# Introduction

The role will:

* Checkout a branch from the [nimbus-eth2](https://github.com/status-im/nimbus-eth2) repo
* Build it using the [`build.sh`](./templates/scripts/build.sh.j2) Bash script
* Schedule regular builds using [Systemd timers](https://www.freedesktop.org/software/systemd/man/systemd.timer.html)
* Start a node by defining a [Systemd service](https://www.freedesktop.org/software/systemd/man/systemd.service.html)

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
# WebSocket or HTTP URLs for execution layet Engine API
beacon_node_exec_layer_urls:
  - 'wss://erigon.internal.example.org:8551'
  - 'http://geth.internal.example.org:8552'
```
The order of WebSocket URLs matters. First is the default, the rest are fallbacks.

There's also a [container monitor service](./MONITOR.md).
```yaml
nim_waku_monitor_enabled: true
```
Most non-sensitive configuration resides in `conf/config.toml` file in service directory.

# Management

## Service

Assuming the `stable` branch was built you can manage the service with:
```sh
sudo systemctl start beacon-node-mainnet-stable
sudo systemctl status beacon-node-mainnet-stable
sudo systemctl stop beacon-node-mainnet-stable
```
You can view logs under:
```sh
tail -f /data/beacon-node-mainnet-stable/logs/service.log
```
All node data is located in `/data/beacon-node-mainnet-stable/data`.

## Builds

A timer will be installed to build the image:
```sh
 > sudo systemctl list-units --type=service '*beacon-node-*'
  UNIT                                LOAD   ACTIVE SUB     DESCRIPTION
  beacon-node-prater-stable.service   loaded active running Nimbus Beacon Node on prater network (stable)
  beacon-node-prater-testing.service  loaded active running Nimbus Beacon Node on prater network (testing)
  beacon-node-prater-unstable.service loaded active running Nimbus Beacon Node on prater network (unstable)
```
To rebuild the image:
```sh
 > sudo systemctl start build-beacon-node-prater-stable
 > sudo systemctl status build-beacon-node-prater-stable
 ● beacon-node-prater-stable-build.service - Build beacon-node-prater-stable
     Loaded: loaded (/etc/systemd/system/beacon-node-prater-stable-build.service; enabled; vendor preset: enabled)
     Active: inactive (dead) since Wed 2021-09-29 12:00:12 UTC; 2h 15min ago
TriggeredBy: ● beacon-node-prater-stable-build.timer
       Docs: https://github.com/status-im/infra-role-systemd-timer
    Process: 1212987 ExecStart=/data/beacon-node-prater-stable/build.sh (code=exited, status=0/SUCCESS)
   Main PID: 1212987 (code=exited, status=0/SUCCESS)

Sep 29 12:00:12 build.sh[1213054]: HEAD is now at 0b21ebfe readme: update toc
Sep 29 12:00:12 build.sh[1212987]:  >>> Binary already built
Sep 29 12:00:12 systemd[1]: beacon-node-prater-stable-build.service: Succeeded.
Sep 29 12:00:12 systemd[1]: Finished Build beacon-node-prater-stable.
```
To check full build logs use:
```sh
journalctl -u build-beacon-node-mainnet-stable.service
```

# Requirements

Due to being part of Status infra this role assumes availability of certain things:

* The `iptables-persistent` module
