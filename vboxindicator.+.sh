#!/usr/bin/bash

# Lists to hold virtual machines
RUNNING_VMS=()
PAUSED_VMS=()
POWERED_OFF_VMS=()
UNKNOWN_VMS=()

# Flags to keep track of headers
DISPLAYED_ACTIVE_VM_HEADER=0
DISPLAYED_INNACTIVE_VM_HEADER=0

echo "|iconName=computer"
echo "---"

# Go through virtual machines and split into lists based on their current
# status
OLDIFS=$IFS
IFS=$'\n'
for VIRTUAL_MACHINE in $(vboxmanage list vms); do

    UUID=$(echo $VIRTUAL_MACHINE | grep -Po '(?<=" {).*?(?=})')
    STATE=$(vboxmanage showvminfo $UUID | grep State | grep -Po '(?<=\s).*?(?=\()' | sed 's/\s*//g')

    if [[ $STATE = "running" ]]; then
        RUNNING_VMS+=($VIRTUAL_MACHINE)
    elif [[ $STATE = "paused" ]]; then
        PAUSED_VMS+=($VIRTUAL_MACHINE)
    elif [[ $STATE = "saved" ]]; then
        POWERED_OFF_VMS+=($VIRTUAL_MACHINE)
    elif [[ $STATE = "poweredoff" ]]; then
        POWERED_OFF_VMS+=($VIRTUAL_MACHINE)
    fi

done
IFS=$OLDIFS

# Powered on virtual machines
for VIRTUAL_MACHINE in "${RUNNING_VMS[@]}"; do
    if [ $DISPLAYED_ACTIVE_VM_HEADER -eq 0 ]; then
        echo "Active virtual machines | color=gray"
        DISPLAYED_ACTIVE_VM_HEADER=1
    fi

    NAME=$(echo $VIRTUAL_MACHINE | grep -Po '(?<=").*?(?=" {)')
    UUID=$(echo $VIRTUAL_MACHINE | grep -Po '(?<=" {).*?(?=})')

    echo "$NAME | iconName=media-playback-start"
    echo "--Power down safely | bash='vboxmanage controlvm $UUID acpipowerbutton' terminal=false iconName=system-shutdown"
    echo "--Force power off | bash='vboxmanage controlvm $UUID poweroff' terminal=false iconName=media-playback-stop"
    echo "--Restart | bash='vboxmanage controlvm $UUID reset' terminal=false iconName=media-playlist-repeat"
    echo "--Save state | bash='vboxmanage controlvm $UUID savestate' terminal=false iconName=media-floppy"
    echo "--Pause | bash='vboxmanage controlvm $UUID pause' terminal=false iconName=media-playback-pause"
done

# Paused virtual machines
for VIRTUAL_MACHINE in "${PAUSED_VMS[@]}"; do
    if [ $DISPLAYED_ACTIVE_VM_HEADER -eq 0 ]; then
        echo "Active virtual machines | color=gray"
        DISPLAYED_ACTIVE_VM_HEADER=1
    fi

    NAME=$(echo $VIRTUAL_MACHINE | grep -Po '(?<=").*?(?=" {)')
    UUID=$(echo $VIRTUAL_MACHINE | grep -Po '(?<=" {).*?(?=})')

    echo "$NAME | iconName=media-playback-pause"
    echo "--Resume | bash='vboxmanage controlvm $UUID resume' terminal=false iconName=media-playback-start"
    echo "--Force power off | bash='vboxmanage controlvm $UUID poweroff' terminal=false iconName=media-playback-stop"
    echo "--Save state | bash='vboxmanage controlvm $UUID savestate' terminal=false iconName=media-floppy"
done

# Powered off virtual machines
for VIRTUAL_MACHINE in "${POWERED_OFF_VMS[@]}"; do
    if [ $DISPLAYED_INNACTIVE_VM_HEADER -eq 0 ]; then
        echo "Innactive virtual machines | color=gray"
        DISPLAYED_INNACTIVE_VM_HEADER=1
    fi

    NAME=$(echo $VIRTUAL_MACHINE | grep -Po '(?<=").*?(?=" {)')
    UUID=$(echo $VIRTUAL_MACHINE | grep -Po '(?<=" {).*?(?=})')

    echo "$NAME | iconName=media-playback-stop"
    echo "--Start in windowed mode | bash='vboxmanage startvm $UUID' terminal=false iconName=video-display"
    echo "--Start in headless mode | bash='vboxmanage startvm $UUID --type headless' terminal=false iconName=media-playback-start"
done

echo "---"
echo "VirtualBox | bash=virtualbox terminal=false iconName=computer"
