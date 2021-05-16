#!/bin/bash
# -----------------------------
# -----------------------------
# Set External IP Resource, if you want to change this you'll need to make sure it returns
# the same formatted value as the current "curl --no-progress-meter $IP_RESOURCE 2>&1"
IP_RESOURCE="https://ifconfig.io"
# Set IP Variable
IP_MSG="$(curl --no-progress-meter $IP_RESOURCE 2>&1)"
# Set Status  $? uses 1 or 0 for the equivalent of an exit code
# it's checking the status returned of the last executed command :-)
STATUS=$?
# Set the scripts directory as a variable for reference later
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Set file handle value for the last_known.ip file using the already set ^ SCRIPT_DIR
F_HANDLE="$SCRIPT_DIR/last_known.ip"
# If the file $F_HANDLE exists then set LAST_KNOWN variable as the parsed output of the last_known.ip file
if [[ -f "$F_HANDLE" ]]; then
    LAST_KNOWN=$(<$F_HANDLE)
# Else if the file does not exist then do the following:
else
  # If there is an exit code other than 0 with $STATUS variable it means there's a
  # problem connecting to https://ifconfig.io, no internet most likely reason
	if [ $STATUS =  1 ]; then
	  # zenity is built into the GTK3+ Suite of Tools it will output user dialog messages to the GUI
		zenity --notification --window-icon="process-stop" --color=$blue --text "Not connected to internet"
		# Else If the $STATUS is 0 then continue onwards
	else
		touch $F_HANDLE
		echo "$IP_MSG" > $F_HANDLE
		LAST_KNOWN=$(<$F_HANDLE)
		zenity --notification --window-icon="process-stop" --text "Set new file and contents to $SCRIPT_DIR/last_known.ip"
	fi
fi

# Internet test for if you're able to ping resource for ip
if [ $STATUS = 1 ]; then
    # Send message to UI with zenity that shit is broken
    zenity --notification --window-icon="process-stop" --color=$blue --text "Error Occurred While Attempting to Connect to ifconfig.io for IP Verification"
# If everything is all clear and no errors continue onwards
else
  # If the last_known.ip equals current_ip, give all clear messages
	if [[ "$LAST_KNOWN" = "$IP_MSG" ]]; then
		MESSAGE="IP UNCHANGED LAST 300 SECONDS"
		zenity --notification --window-icon="process-working" --color=$green --text "$MESSAGE"
	        sleep 1s
		MESSAGE="Previous IP: $LAST_KNOWN"
		zenity --notification --window-icon="process-working" --color=$green --text "$MESSAGE"
		sleep 1s
		MESSAGE="Current IP: $IP_MSG"
		zenity --notification --window-icon="process-working" --color=$green --text "$MESSAGE"
	# If they don't match there's a problem, or you used a vpn
	else
		MESSAGE="There was a discrepency in external IP, $LAST_KNOWN, $IP_MESSAGE"
		zenity --notification --window-icon="process-stop" --color=$red --text "$MESSAGE"
	fi
fi
