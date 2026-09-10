# macOS GlobalProtect Toggle & Network Restorer

A streamlined Zsh/Bash shell function for macOS that toggles the Palo Alto GlobalProtect VPN on and off from the terminal. 

Crucially, it fixes the common issue where GlobalProtect leaves behind stale `utun` virtual routes or ARP caches after disconnecting, which blocks access to local network devices (like a router at `192.168.0.1` or a local NAS).

## Features
* **Full Service Shutdown:** Kills both the GUI agent (`PanGPA`) and the root system daemon (`PanGPS`) to completely free the network interface.
* **Local LAN Restoration:** Automatically cycles the Wi-Fi interface to discard stale routes and request a clean DHCP lease.
* **DNS Flush:** Clears the macOS DNS cache and restarts `mDNSResponder` to drop stale corporate intranet hostnames.
* **Single Sudo Prompt:** Groups all root-level commands into a single `sudo sh -c` execution to bypass strict corporate MDM password-caching policies.

## Installation

1. Open your terminal shell configuration file (usually `~/.zshrc` on modern macOS):
   ```bash
   nano ~/.zshrc
   ```
2. Copy the contents of `gp-toggle.sh` and paste it at the bottom of the file.
3. Save the file and exit.
4. Reload your terminal profile to apply the changes:
   ```bash
   source ~/.zshrc
   ```

## Usage

Run the following commands directly in your terminal:

* `gp` — Toggles the state (stops it if running, starts it if stopped).
* `gp off` — Completely disables GlobalProtect, cycles Wi-Fi, and flushes DNS. (Requires your Mac password).
* `gp on` — Enables GlobalProtect daemons. (Requires your Mac password).
* `gp status` — Checks if the GlobalProtect processes are currently active.

## Troubleshooting

If cycling the Wi-Fi interface (`en0`) does not work, ensure your primary network adapter is actually `en0`. You can list your network interfaces by running:
```bash
networksetup -listallhardwareports
```
If your Wi-Fi or Ethernet adapter uses a different identifier (e.g., `en1`), update the `networksetup` commands in the script accordingly.
