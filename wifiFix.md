# Wi-Fi & Home Network Diagnosis

Diagnose my Wi-Fi and home network, find the real bottlenecks behind slow speeds or instability, and guide me through fixing them. Work on whatever OS this device runs (macOS / Linux / Windows — use the native equivalent of each command).

## Ground rules
- Run every check **sequentially**. Never run latency tests in parallel with throughput tests.
- Network tests may be blocked by a tool sandbox — if pings or connections fail suspiciously, retry outside the sandbox before blaming the network.
- Before **each** test round, confirm which access point / band / channel the device is actually joined to. Clients can silently stick to a weak AP (same or different SSID); if so, fix that first — results on the wrong AP are meaningless.
- Don't log into my router for me and don't change Wi-Fi settings mid-test (it would cut your own connection). Give me click-by-click steps; I'll send screenshots.
- Keep long log queries bounded (time window + timeout).
- Save the baseline numbers to a file so the after-run can be compared exactly.

## 1. Context — ask me first (one short question round)
- Router model (or I'll send a screenshot; also identify it from the admin login page if possible).
- Topology: extenders / mesh / access points, wired or wireless backhaul, which floor/room each is in vs. where I work.
- Which devices are wired vs. Wi-Fi, and any 2.4 GHz-only devices (cameras, appliances, IoT).
- My ISP plan's download/upload speed (and ISP type: fiber / cable / DSL / 5G).

## 2. Wi-Fi link & RF congestion
- Active PHY mode (802.11n/ac/ax/be), band (2.4/5/6 GHz), channel, width (20/40/80/160 MHz), signal/noise (SNR), transmit rate / MCS, interface errors.
- Scan nearby networks; count competing APs per channel and width (note 40/80 MHz neighbours overlap several channels). Find the cleanest 5 GHz block and the cleanest 2.4 GHz channel (1/6/11 only). Note that the OS may hide my own SSID's other APs from the scan.
- Flag mismatches (e.g. device reports Wi-Fi 6 but the router is Wi-Fi 5 → another AP is serving it).

## 3. Idle latency & stability
- Gateway and 1.1.1.1: 30 samples each (plus IPv6 if active). If ICMP echo is blocked, fall back to TCP-connect timing (gateway:80, 1.1.1.1:443) and report min/avg/median/max/jitter.
- 5-hop traceroute to separate LAN/Wi-Fi latency from ISP latency (note CGNAT 10.x/100.64.x hops).
- Active bandwidth hogs, VPNs, proxies, overlay networks.
- Wi-Fi disconnect/roam events over 24h: deduplicate repeated log lines, list timestamps, and look for patterns (fixed times → scheduled reboot or auto-channel rescan).

## 4. DNS
- Current DNS servers; compare **uncached** lookup latency (random subdomains, 8 queries each) for current, 1.1.1.1, 8.8.8.8, 9.9.9.9 and the router.

## 5. Throughput & bufferbloat
- macOS: `networkQuality -v` (parallel) **and** `networkQuality -s` (sequential) — run the sequential one twice. On Wi-Fi the parallel test can starve upload; trust the sequential numbers for capacity. Linux/Windows: equivalent (e.g. Waveform/Cloudflare speed test + loaded latency).
- Report downlink, uplink, idle latency, loaded latency/RPM per direction, ECN/L4S.
- Cross-check against my ISP's own speed test if results look off. Expect ±15% run-to-run noise; don't call small differences wins.

## 6. Deliverables
- Baseline table with exact measurements.
- Bottlenecks ranked by real impact (skip placebo OS tweaks like TCP buffer/ECN toggles without router-side AQM).
- Split fixes into **local** (on this device) vs. **router/AP** vs. **physical** (placement, cabling), each click-by-click for my exact models:
  - Fixed channels (cleanest found), 80/160 MHz on 5/6 GHz where clean, 20 MHz on 2.4 GHz, Wi-Fi 6/OFDMA/WMM on, transmit power high.
  - Smart Connect / band steering off if it hurts; with multiple APs, same SSID + password on all, different non-overlapping channels (mesh/EasyMesh as an optional next step).
  - Unused guest/IoT SSIDs off; scheduled reboots and auto-channel off.
  - Bufferbloat: real SQM if available. Warn that consumer "QoS" often disables hardware NAT acceleration and may not actually rate-limit — A/B test it (QoS on vs. off + NAT acceleration on) and keep whichever measures better. QoS bandwidth must be set below the *measured* capacity, never to placeholder values.
  - Per-device rules (QoS priority, DHCP reservations) break if the device uses a rotating private MAC — check and fix.
  - Modem health (power, SNR, uncorrectable errors) for cable/DSL.
  - DFS channel caveat (radar → brief outage).
- Remind me to rotate any passwords that appeared in screenshots or chat.

## 7. After I apply changes
Re-verify which AP I'm on, then re-run the exact same sequential benchmark and output a **Before vs. After** table (one column per round if there were several). Name what improved, what didn't, and what can only be fixed with hardware. Offer an overnight check of disconnect logs for time-based issues.
