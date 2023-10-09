#!/bin/bash

# Lists to hold virtual machines
RUNNING_VMS=()
PAUSED_VMS=()
POWERED_OFF_VMS=()
ABORTED_VMS=()
UNKNOWN_VMS=()

# Flags to keep track of headers
DISPLAYED_ACTIVE_VM_HEADER=0
DISPLAYED_INNACTIVE_VM_HEADER=0

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
    elif [[ $STATE = "aborted" ]]; then
        ABORTED_VMS+=($VIRTUAL_MACHINE)
    else
        UNKNOWN_VMS+=($VIRTUAL_MACHINE)
    fi

done
IFS=$OLDIFS

echo "|iconName=computer-symbolic"
echo "---"

function create_sub_menu {

    HEADER=$1
    STATE=$2
    COLOR=$3
    shift 3
    VIRTUAL_MACHINES=("$@")

    if [ ${#VIRTUAL_MACHINES[@]} -eq 0 ]; then
        return
    fi

    echo -e "<span> </span><span color='$COLOR'>\033[1m$HEADER\033[0m</span>"
    echo "---"

    for VIRTUAL_MACHINE in "${VIRTUAL_MACHINES[@]}"; do

        NAME=$(echo $VIRTUAL_MACHINE | grep -Po '(?<=").*?(?=" {)')
        UUID=$(echo $VIRTUAL_MACHINE | grep -Po '(?<=" {).*?(?=})')

        case $STATE in
            "running")
                echo "<span> </span>$NAME"
                echo "--Power down safely | bash='vboxmanage controlvm $UUID acpipowerbutton' terminal=false"
                echo "--Force power off | bash='vboxmanage controlvm $UUID poweroff' terminal=false"
                echo "--Restart | bash='vboxmanage controlvm $UUID reset' terminal=false"
                echo "--Save state | bash='vboxmanage controlvm $UUID savestate' terminal=false"
                echo "--Pause | bash='vboxmanage controlvm $UUID pause' terminal=false"
                ;;
            "paused")
                echo "<span> </span>$NAME"
                echo "--Resume | bash='vboxmanage controlvm $UUID resume' terminal=false"
                echo "--Force power off | bash='vboxmanage controlvm $UUID poweroff' terminal=false"
                echo "--Save state | bash='vboxmanage controlvm $UUID savestate' terminal=false"
                ;;
            "off" | "aborted")
                echo "<span> </span>$NAME"
                echo "--Start in windowed mode | bash='vboxmanage startvm $UUID' terminal=false"
                echo "--Start in headless mode | bash='vboxmanage startvm $UUID --type headless' terminal=false"
                ;;
            "unknown")
                echo "<span> </span><span color='gray'>$NAME</span>"
                ;;
        esac

    done

    echo "---"

}

create_sub_menu "Running"   "running"   "gray"      "${RUNNING_VMS[@]}"
create_sub_menu "Paused"    "paused"    "gray"      "${PAUSED_VMS[@]}"
create_sub_menu "Off"       "off"       "gray"      "${POWERED_OFF_VMS[@]}"
create_sub_menu "Aborted"   "aborted"   "orange"    "${ABORTED_VMS[@]}"
create_sub_menu "Unknown"   "unknown"   "#94504b"   "${UNKNOWN_VMS[@]}"

echo "VirtualBox | bash=virtualbox terminal=false"
