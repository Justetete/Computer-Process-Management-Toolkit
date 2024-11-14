#! /bin/bash

# Define global variables to hold the sending process log and the location of log
process_log=()
log_file_path=""


menu() {
    # Display the menu screen and prompt user to enter an option
    echo "Welcome to Process Management Toolkit";
    echo "1. Press '1' to show local process.";
    echo "2. Press '2' to show all user's processes.";
    echo "3. Press '3' to search a process.";
    echo "4. Press '4' to send signals to specific processes.";
    echo "5. Press '5' to see the log of all process were sent a signal.";
    echo "Q. Press 'q' to quit our toolkit.";

}

show_local_process(){
    # check the information about the processes running by current user

    # get current user's user ID
    user_id=$(id -u "$(whoami)")

    ps -u "$user_id" -o user,pid,cputime,comm
}


show_all_processes() {
    # check the information about all users' processes
    ps -eo user,pid,cputime,comm
}

search_process_by_name() {
    # prompt user to enter a name or binary name to search for specific processes

    read -r -p "Please enter a name (username or binary): " name;

    if [[ -z "$name" ]]; then # If user enter a empty argument
        error_report "Please enter a valid name or binary to search for."
        return
    fi

    ps -eo user,pid,comm,cputime | grep -i "$name"

    exit_status=$? # capture the exit status after executing grep
    if [[ $exit_status = 1 ]]; then
        echo "No processes found for '$name'." # print a message if no processes was found.
    elif [[ $exit_status > 1 ]]; then # execute error_report function if there is a error
        error_report "An error occurred while performing the requested operation."
        return
    fi
}

send_signal() {
    # prompt user to send a signal to a specific process
    
    read -r -p "Enter the PID of the process to signal: " pid
    # check if pid format is valid
    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        error_report "Invalid PID format. Please enter a valid number."
        return
    fi
    read -r -p "Enter the signal (name or number) to send: " signal
    read -r -p "Are you sure? (y/n): " confirm

    if [[ "$confirm" == "y" ]]; then
        # check if process exists
        if ! ps -p "$pid" > /dev/null; then
            error_report "Process with PID $pid does not exist."
        fi
        log_signal() {
            # function of documenting all processes that were sent a signal
            process=$(ps -p "$pid" -o comm=)
            process_log+=("Process $process (PID: $pid) received signal $signal")
        }

        # check if signal is numeric or a valid signal name
        if [[ $signal =~ ^[0-9]+$ ]]; then
            kill -"$signal" "$pid"
            exit_status=$?
            # check if signal is sent successfully or not
            if [[ $exit_status -eq 0 ]]; then
                log_signal
                echo "Signal sent successfully to PID $pid."
            elif [[ $exit_status -eq 1 ]]; then
                echo "Failed to send signal to PID $pid." 
            else
                error_report "An error occurred while performing the requested operation."
                return
            fi

        elif kill -l | grep -q "$signal"; then
            kill -s "$signal" "$pid" 
            exit_status=$?
            if [[ $exit_status -eq 0 ]]; then
                log_signal
                echo "Signal sent successfully to PID $pid."
            elif [[ $exit_status -eq 1 ]]; then
                echo "Failed to send signal to PID $pid." 
            else
                error_report "An error occurred while performing the requested operation."
                return
            fi
        else
            echo "Invalid signal: '$signal'. Please enter a valid signal name or number."
        fi
    else
        echo "The signal is not sent."
    fi
}

see_log_file() {
    # allow user to check the documented log

    if [[ ${#process_log[@]} -eq 0 ]]; then
        # check if log is empty or not
        error_report "You haven't sent a signal to a proces. Please use option 4 to send signals first."
        return
    fi

    read -r -p "Enter log file location: " log_file_path # prompt user give a location

    if [[ -f "$log_file_path" ]]; then
        # If the file exists, ask the user if they want to append or overwrite
        read -r -p "Log file exists. If append to it? (y/n): " answer
        if [[ "$answer" == "y" ]]; then
            printf "%s\n" "${process_log[@]}" >> "$log_file_path"
            echo "Log appended to '$log_file_path'."
        else
            printf "%s\n" "${process_log[@]}" > "$log_file_path"
            echo "Log written (overwritten) to '$log_file_path'."
        fi
    else
        # If file doesn't exist, create a new location of file
        printf "%s\n" "${process_log[@]}" > "$log_file_path"
        echo "New log file created and log written to '$log_file_path'."
    fi

}

error_report(){
    # When any error happens, call this funtion
    local error_message=$1
    echo "Error: $error_message";
    return
} 

while true; do
    # infinite loop untill user presses 'q/Q'
    menu
    read -r -p "Choose an option: " option
    
    case $option in
        1) show_local_process ;;

        2) show_all_processes ;;

        3) search_process_by_name ;;

        4) send_signal ;;

        5) see_log_file ;;

        # If user press 'q' or 'Q', program exits
        q|Q) echo "Exiting!";
            if [[ ${#process_log[@]} -gt 0 && -z "$log_file_path" ]]; then
            read -r -p "Do you want to save the log before exiting? (y/n): " save_log
            if [[ "$save_log" == "y" ]]; then
                read -r -p "Please enter a location to store the log: " log_file_path
                printf "%s\n" "${process_log[@]}" > "$log_file_path"
                echo "Log saved to: $log_file_path"
            fi
        fi
            exit 0 ;; 

        # If user input wrong command, output error message.
        *) error_report "Invalid option, please try again." ;;
    esac
done

