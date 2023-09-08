#!/bin/bash

# Script version
SCRIPT_VERSION="1.0.0"

# Error and verbose log files
ERROR_LOG="fdd-error.log"
VERBOSE_LOG="fdd-verbose.log"

# Function to log version information
log_version() {
    echo "[$(date)] - Script Version: $SCRIPT_VERSION" >> $1
}

# Initialize logs with version information
log_version $ERROR_LOG
log_version $VERBOSE_LOG

# Function to display help
display_help() {
    echo "Usage: $0 [option...] " >&2
    echo
    echo "   -c,  Run in CLI mode, bypassing interactive prompts"
    echo "   -d,  Specify the input device (e.g., /dev/sda)"
    echo "   -o,  Specify the output directory for DD"
    echo "   -b,  Specify the block size for DD (default is 4096)"
    echo "   -h,  Display this help message"
    echo
    exit 1
}

# Function to log errors
log_error() {
    echo "[$(date)] - $1" >> $ERROR_LOG
}

# Function to log verbose messages
log_verbose() {
    echo "[$(date)] - $1" >> $VERBOSE_LOG
}

# Function to display a Star Wars-themed DD joke in cowsay style
cowsay_joke() {
    echo ""
    echo "  _______________________________ "
    echo " < Use DD wisely, or join the Dark Side! >"
    echo "  ------------------------------- "
    echo "         \\   ^__^"
    echo "          \\  (oo)\\_______"
    echo "             (__)\\       )\\/\\"
    echo "                 ||----w |"
    echo "                 ||     ||"
    echo ""
    echo "If you DD the wrong disk, not even Yoda can bring it back from the Dark Side!"
    echo ""
    echo "LazyDD - https://github.com/w0rm3r/lazydd by w0rm3r"
    echo ""
}

# Initialize command-line arguments
CLI_MODE=false
CLI_DEVICE=""
CLI_DESTINATION=""
CLI_BLOCK_SIZE=""

# Parse command-line arguments
while getopts "chd:o:b:" opt; do
  case $opt in
    c) CLI_MODE=true ;;
    h) display_help ;;
    d) CLI_DEVICE="$OPTARG" ;;
    o) CLI_DESTINATION="$OPTARG" ;;
    b) CLI_BLOCK_SIZE="$OPTARG" ;;
    \?)
      log_error "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      log_error "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

# Function to clear the terminal
clear_terminal() {
    clear
}

# Function to list available starships (storage devices)
list_starships() {
    log_verbose "Listing available storage devices."
    echo "Greetings, young Padawan! Here are the starships docked at our station (your storage devices):"
    lsblk -d -o NAME,SIZE,MODEL
}

# Function to summon the Force (run DD)
use_the_force() {
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    IMG_FILENAME="$(hostname)_${TIMESTAMP}.img"
    MD5_FILENAME="$(hostname)_${TIMESTAMP}.md5"
    SHA1_FILENAME="$(hostname)_${TIMESTAMP}.sha1"

    cowsay_joke
    
    echo "Harnessing the Force to copy data... 🌌"
    
    sudo dd if="$1" bs="$3" conv=sync,noerror status=progress of="$2/${IMG_FILENAME}" || log_error "Failed DD operation"
    md5sum "$2/${IMG_FILENAME}" > "$2/${MD5_FILENAME}" || log_error "Failed to calculate MD5 hash"
    sha1sum "$2/${IMG_FILENAME}" > "$2/${SHA1_FILENAME}" || log_error "Failed to calculate SHA1 hash"
    
    log_verbose "DD operation completed."
    echo "The Force has done its work. May the Force be with you, always."
}


if [ "$CLI_MODE" = true ]; then
    log_verbose "Running in CLI mode."
    if [ -z "$CLI_DEVICE" ] || [ -z "$CLI_DESTINATION" ]; then
        log_error "In CLI mode, both device and destination must be specified."
        exit 1
    fi

    if [ -z "$CLI_BLOCK_SIZE" ]; then
        CLI_BLOCK_SIZE=4096
    fi

    use_the_force "$CLI_DEVICE" "$CLI_DESTINATION" "$CLI_BLOCK_SIZE"
else
    while true; do
        cowsay_joke
        clear_terminal
        list_starships
        read -p "Choose your starship, Jedi (e.g., sda): " DEVICE
        if [ -z "$DEVICE" ]; then
            log_verbose "No device selected."
            echo "The starship cannot be empty! A Jedi needs their starship!"
            continue
        fi
        DEVICE="/dev/$DEVICE"
        log_verbose "User selected device: $DEVICE."

        clear_terminal
        read -p "To which galaxy shall we deliver the plans (DD output directory)? " DESTINATION
        if [ -z "$DESTINATION" ]; then
            log_verbose "No destination selected."
            echo "You must specify a galaxy (destination) to continue, young Jedi."
            continue
        elif [ ! -d "$DESTINATION" ]; then
            log_verbose "Destination directory does not exist."
            read -p "This galaxy does not exist in our star charts! Create it, we must? (y/n): " CREATE_GALAXY
            if [ "$CREATE_GALAXY" == "y" ]; then
                log_verbose "Creating directory: $DESTINATION."
                mkdir -p "$DESTINATION" || log_error "Failed to create directory: $DESTINATION"
            else
                continue
            fi
        fi
        log_verbose "User selected destination: $DESTINATION."

        read -p "What size of kyber crystal shall we use (block size)? Default is 4096, it is: " BLOCK_SIZE
        if [ -z "$BLOCK_SIZE" ]; then
            BLOCK_SIZE=4096
        fi
        log_verbose "User selected block size: $BLOCK_SIZE."

        clear_terminal
        echo "Pause, you must. Confirm these details before we jump to lightspeed:"
        echo "Starship (Input Device): $DEVICE"
        echo "Galaxy (Output Location): $DESTINATION"
        echo "Kyber Crystal Size (Block Size): $BLOCK_SIZE"
        read -p "Proceed, shall we? (y/n): " CONFIRM

        if [ "$CONFIRM" == "y" ]; then
            log_verbose "User confirmed. Proceeding with DD."
            use_the_force "$DEVICE" "$DESTINATION" "$BLOCK_SIZE"
            break
        else
            log_verbose "User did not confirm. Restarting."
        fi
    done
fi
