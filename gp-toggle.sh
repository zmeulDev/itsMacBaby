# GlobalProtect toggle function with automatic Wi-Fi reset and DNS flush
gp() {
  local agent_path="/Library/LaunchAgents/com.paloaltonetworks.gp.pangpa.plist"
  local uid=$(id -u)
  local service="gui/${uid}/com.paloaltonetworks.gp.pangpa"

  case "$1" in
    off|stop|disable)
      # 1. Attempt graceful CLI disconnect (runs as user)
      if command -v globalprotect &>/dev/null; then
        globalprotect disconnect 2>/dev/null
        sleep 1
      fi

      # 2. Stop the GUI agent (runs as user)
      launchctl bootout "$service" 2>/dev/null

      # 3. Group ALL root commands into ONE sudo call to minimize password prompts
      sudo sh -c '
        launchctl bootout system/com.paloaltonetworks.gp.pangps 2>/dev/null
        killall -9 PanGPS 2>/dev/null
        killall -HUP mDNSResponder 2>/dev/null
      '

      # 4. Cycle Wi-Fi and flush DNS (runs as user)
      # Note: Change 'en0' if your primary Wi-Fi interface is different
      networksetup -setairportpower en0 off
      networksetup -setairportpower en0 on
      dscacheutil -flushcache

      echo "GlobalProtect stopped. Wi-Fi reset and local routing restored."
      ;;

    on|start|enable)
      # 5. Start root daemon (prompts once) then user GUI agent
      sudo launchctl bootstrap system /Library/LaunchDaemons/com.paloaltonetworks.gp.pangps.plist 2>/dev/null
      launchctl bootstrap "gui/${uid}" "$agent_path" 2>/dev/null
      echo "GlobalProtect enabled."
      ;;

    status)
      if pgrep -il pan &>/dev/null; then
        echo "GlobalProtect is running."
      else
        echo "GlobalProtect is stopped."
      fi
      ;;

    *)
      if pgrep -il pan &>/dev/null; then
        gp off
      else
        gp on
      fi
      ;;
  esac
}
