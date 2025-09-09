#! /bin/bash

# Define color codes
# Color Codes reference: 
#     1. https://ioflood.com/blog/bash-color/
#     2. https://dev.to/ifenna__/adding-colors-to-bash-scripts-48g4

RED='\033[0;31m' # Error information
GREEN='\033[0;32m' # Option and prompt
YELLOW='\033[1;33m' # Division and prompt information
BLUE='\033[0;34m' # Title
PURPLE='\033[0;35m' # Result for searching
CYAN='\033[0;36m' # Subtitle
GRAY='\033[0;37m' # Ohter states 
NC='\033[0m' # No Color
BOLD='\033[1m'

# Define global variables
process_log=()
log_file_path=""

# Function to determine process state color
get_state_color() {
    local state=$1
    case $state in
        "R"|"RUNNING")     echo -e "${GREEN}" ;;    # Running process
        "S"|"SLEEPING")    echo -e "${BLUE}" ;;     # Sleeping process
        "D"|"DISK_SLEEP")  echo -e "${PURPLE}" ;;   # Disk sleep
        "Z"|"ZOMBIE")      echo -e "${RED}" ;;      # Zombie process
        "T"|"STOPPED")     echo -e "${YELLOW}" ;;   # Stopped process
        *)                 echo -e "${GRAY}" ;;     # Other states
    esac
}

# Function to print process status legend
print_status_legend() {
    echo -e "\n${BOLD}Process State Legend:${NC}"
    echo -e "${GREEN}■${NC} Running     ${BLUE}■${NC} Sleeping    ${PURPLE}■${NC} Disk Sleep"
    echo -e "${RED}■${NC} Zombie      ${YELLOW}■${NC} Stopped     ${GRAY}■${NC} Other"
    echo -e "${YELLOW}══════════════════════════════════════════════${NC}"
}

# Function to show header anytime
show_header() {
    echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         Process Management Toolkit        ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
    echo ""
}

menu() {
    # Display the menu screen and prompt user to enter an option
    show_header

    echo -e "${CYAN}Available Options:${NC}"
    echo -e "${GREEN}1.${NC} Show local processes"
    echo -e "${GREEN}2.${NC} Show all users' processes"
    echo -e "${GREEN}3.${NC} Search for a process"
    echo -e "${GREEN}4.${NC} Send signals to processes"
    echo -e "${GREEN}5.${NC} View signal log"
    echo -e "${RED}Q.${NC} Quit toolkit"
    echo ""
    echo -e "${YELLOW}══════════════════════════════════════════════${NC}"
}

show_local_process(){ # check the information about the processes running by current user
    show_header
    echo -e "${CYAN}Local Processes for Current User:${NC}\n"
    
    # get current user's user ID by command whoami
    user_id=$(id -u "$(whoami)")
    
    # Print caption
    echo -e "${BOLD}USER       PID     %CPU    %MEM    VSZ     RSS    STAT   START   TTY     TIME     CMD${NC}"
    echo -e "${YELLOW}─────────────────────────────────────────────────────────────────────────────────${NC}"
    
    # Get process information and color code based on state
    ps -u "$user_id" -o user=,pid=,pcpu=,pmem=,vsz=,rss=,stat=,start=,tty=,time=,comm= | while read -r user pid cpu mem vsz rss stat start tty time comm; do
        state_color=$(get_state_color "$stat") # Get the display color for the process state by Function ge_state_color
        printf "%-10s %-8s %-8.1f %-8.1f %-8s %-8s ${state_color}%-6s${NC} %-8s %-8s %-10s %s\n" "$user" "$pid" "$cpu" "$mem" "$vsz" "$rss" "$stat" "$start" "$tty" "$time" "$comm" # Format and print process information using printf
        # Reference from: https://linuxize.com/post/bash-printf-command/
    done
    
    print_status_legend
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
}

show_all_processes() { 
    # Check the information about all users' processes
    show_header
    echo -e "${CYAN}All System Processes:${NC}\n"
    
    # Print caption
    echo -e "${BOLD}USER       PID     %CPU    %MEM    VSZ     RSS    STAT   START   TTY     TIME     CMD${NC}"
    echo -e "${YELLOW}─────────────────────────────────────────────────────────────────────────────────${NC}"
    
    # Get process information and color code based on state
    ps -eo user=,pid=,pcpu=,pmem=,vsz=,rss=,stat=,start=,tty=,time=,comm= | while read -r user pid cpu mem vsz rss stat start tty time comm; do
        state_color=$(get_state_color "$stat")
        printf "%-10s %-8s %-8.1f %-8.1f %-8s %-8s ${state_color}%-6s${NC} %-8s %-8s %-10s %s\n" "$user" "$pid" "$cpu" "$mem" "$vsz" "$rss" "$stat" "$start" "$tty" "$time" "$comm"
    done
    
    print_status_legend

    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
}

search_process_by_name() { # Search for specific processes by entering a name or binary name
    show_header
    echo -e "${CYAN}Search for Processes${NC}\n"
    
    # Prompt user to enter a name or binary name(pid)
    read -r -p $'\033[0;32mEnter process name or binary(PID): \033[0m' name

    if [[ -z "$name" ]]; then # If user enter a empty argument
        error_report "Please enter a valid name or binary to search for."
        return
    fi

    echo -e "\n${BOLD}Search Results for: ${PURPLE}$name${NC}\n"
    echo -e "${BOLD}USER       PID     %CPU    %MEM    VSZ     RSS    STAT   START   TTY     TIME     CMD${NC}"
    echo -e "${YELLOW}─────────────────────────────────────────────────────────────────────────────────${NC}"
    
    # Get process information and color code based on state
    result=$(ps -eo user=,pid=,pcpu=,pmem=,vsz=,rss=,stat=,start=,tty=,time=,comm= | grep -i "$name")
    exit_status=$? # capture the exit status after executing grep
    
    if [[ $exit_status = 0 ]]; then
        echo "$result" | while read -r user pid cpu mem vsz rss stat start tty time comm; do
            state_color=$(get_state_color "$stat")
            printf "%-10s %-8s %-8.1f %-8.1f %-8s %-8s ${state_color}%-6s${NC} %-8s %-8s %-10s %s\n" "$user" "$pid" "$cpu" "$mem" "$vsz" "$rss" "$stat" "$start" "$tty" "$time" "$comm"
        done
        print_status_legend
    elif [[ $exit_status = 1 ]]; then # print a message if no processes was found.
        echo -e "${RED}No processes found for '$name'.${NC}"
    else # execute error_report function if there is a error
        error_report "An error occurred while searching."
        return
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
}

send_signal() {
    show_header
    echo -e "${CYAN}Send Signal to Process${NC}\n"
    
    read -r -p $'\033[0;32mEnter PID: \033[0m' pid # Prompt user to enter a PID
    
    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then # Check if entered PID is valid
        error_report "Invalid PID format. Please enter a valid number."
        return
    fi
    
    if ! ps -p "$pid" > /dev/null; then # Check if entered PID exists
        error_report "Process with PID $pid does not exist."
        return
    fi

    
    read -r -p $'\033[0;32mEnter signal (Signal name or number): \033[0m' signal # Prompt user to enter a signal

    echo -e "${RED}"
    read -r -p "Are you sure you want to send this signal? (y/n): " confirm # Prompt user to comfirm if sending this signal
    echo -e "${NC}"

    if [[ "$confirm" == "y" ]]; then
        if [[ $signal =~ ^[0-9]+$ ]] || kill -l | grep -q "$signal"; then # Check if enterd signal is valid
            kill -s "$signal" "$pid" 2>/dev/null
            if [[ $? -eq 0 ]]; then
                process=$(ps -p "$pid" -o comm=)
                process_log+=("Process $process (PID: $pid) received signal $signal") # Log the signal sent by user into process_log variable
                echo -e "\n${GREEN}Signal sent successfully to PID $pid.${NC}"
            else
                echo -e "\n${RED}Failed to send signal to PID $pid.${NC}"
            fi
        else
            echo -e "\n${RED}Invalid signal: '$signal'. Please enter a valid signal name or number.${NC}"
        fi
    elif [[ "$confirm" == "n" ]]; then
        echo -e "\n${YELLOW}Signal sending cancelled.${NC}"
    else
        error_report "Invaild confirmation and Signal sendinig cancelled."
        return 
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
}

see_log_file() {
    show_header
    echo -e "${CYAN}Signal Log Viewer${NC}\n"
    
    if [[ ${#process_log[@]} -eq 0 ]]; then # Show error information when user did not send a signal to any process.
        error_report "No signals have been sent yet. Use option 4 to send signals first."
        return
    fi
    
    echo -e "${BOLD}Current Session Log:${NC}"
    echo -e "${YELLOW}──────────────────────────────────────${NC}"
    printf "%s\n" "${process_log[@]}" # Print contents of log.
    echo -e "${YELLOW}──────────────────────────────────────${NC}\n"
    
    read -r -p $'\033[0;32mEnter log file location to save: \033[0m' log_file_path # Prompt user to give a file location to save

    if [[ -f "$log_file_path" ]]; then # Check if the file location exists
        echo -e "${YELLOW}"
        read -r -p "File exists. Append to it? (y/n): " answer
        echo -e "${NC}"
        if [[ "$answer" == "y" ]]; then
            printf "%s\n" "${process_log[@]}" >> "$log_file_path"
            echo -e "\n${GREEN}Log appended to '$log_file_path'.${NC}"
        else
            printf "%s\n" "${process_log[@]}" > "$log_file_path"
            echo -e "\n${GREEN}Log overwritten to '$log_file_path'.${NC}"
        fi
    else
        printf "%s\n" "${process_log[@]}" > "$log_file_path"
        echo -e "\n${GREEN}New log file created at '$log_file_path'.${NC}"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
}

error_report(){ # Function to report Error
    echo -e "${RED}Error: $1${NC}"

    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
}

while true; do
    menu
    read -r -p $'\033[0;32mChoose an option: \033[0m' option
    
    case $option in
        1) show_local_process ;;
        2) show_all_processes ;;
        3) search_process_by_name ;;
        4) send_signal ;;
        5) see_log_file ;;
        q|Q) 
            show_header
            if [[ ${#process_log[@]} -gt 0 && -z "$log_file_path" ]]; then
                echo -e "${YELLOW}"
                read -r -p "Save log before exiting? (y/n): " save_log
                echo -e "${NC}"
                if [[ "$save_log" == "y" ]]; then
                    read -r -p $'\033[0;32mEnter log file location: \033[0m' log_file_path
                    printf "%s\n" "${process_log[@]}" > "$log_file_path"
                    echo -e "\n${GREEN}Log saved to: $log_file_path${NC}"
                fi
            fi
            echo -e "\n${BLUE}Thank you for using Process Management Toolkit!${NC}"
            echo -e "${BLUE}Goodbye!${NC}"
            exit 0 # When user chooses 'quit' option, the script exits.
            ;;
        *) error_report "Invalid option. Please try again." ;;
    esac
done
