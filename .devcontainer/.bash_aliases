# Convenience function for echoing with color
# Usage: echoColor <color> <message>
# Colors: black, red, green, yellow, blue, magenta, cyan, white
function echoColor() {
    local color=$1
    local message=$2
    local colorCode
    case $color in
        black)
            colorCode=0
            ;;
        red)
            colorCode=1
            ;;
        green)
            colorCode=2
            ;;
        yellow)
            colorCode=3
            ;;
        blue)
            colorCode=4
            ;;
        magenta)
            colorCode=5
            ;;
        cyan)
            colorCode=6
            ;;
        white)
            colorCode=7
            ;;
        *)
            echo "Invalid color: $color"
            return 1
            ;;
    esac
    echo -e "\033[3${colorCode}m${message}\033[0m"
}

# Convenience function for piping to echoColor
# Usage: <command> | echoColorPipe <color>
function echoColorPipe() {
    local color=$1
    local message
    while read message; do
        echoColor $color "$message"
    done
}

# Convenience function for adding style to text
# Usage: echoStyle <style> <message>
# Styles: bold, italic, underline, blink, inverse, hidden, strikethrough
function echoStyle() {
    local style=$1
    local message=$2
    local styleCode
    case $style in
        bold)
            styleCode=1
            ;;
        italic)
            styleCode=3
            ;;
        underline)
            styleCode=4
            ;;
        blink)
            styleCode=5
            ;;
        inverse)
            styleCode=7
            ;;
        hidden)
            styleCode=8
            ;;
        strikethrough)
            styleCode=9
            ;;
        *)
            echo "Invalid style: $style"
            return 1
            ;;
    esac
    echo -e "\033[${styleCode}m${message}\033[0m"
}

# Convenience function for piping to echoStyle
# Usage: <command> | echoStylePipe <style>
function echoStylePipe() {
    local style=$1
    local message
    while read message; do
        echoStyle $style "$message"
    done
}

# Function to emulate Dockerfile RUN command, and if it returns a code of 0, append it to the end of $REPOSITORY/.devcontainer/Dockerfile
# Otherwise, ask the user if they want to add to the Dockerfile

function RUN() {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echoColor "red" "error with $1" >&2 # echo error to stderr
        echoColor "red" "The command failed with exit code $status." >&2
        echoColor "red" "Do you want to add this command to the Dockerfile? (y/n)" >&2
        read -n 1 -r
        echo >&2
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "RUN $@" >> $REPOSITORY/.devcontainer/Dockerfile
        fi
    else
        echo "RUN $@" >> $REPOSITORY/.devcontainer/Dockerfile
    fi
    return $status
}

# Function to generate uninstallation commands for common install commands
# Usage: SUGGEST_UNINSTALL <command>
function SUGGEST_UNINSTALL() {
    local command="$@"
    local uninstall_command
    if [[ $command == sudo\ apt\ install* ]]; then
        uninstall_command=$(echo "$command" | sed 's/install/purge/')
    elif [[ $command == sudo\ apt-get\ install* ]]; then
        uninstall_command=$(echo "$command" | sed 's/install/purge/')
    elif [[ $command == sudo\ yum\ install* ]]; then
        uninstall_command=$(echo "$command" | sed 's/install/remove/')
    elif [[ $command == sudo\ dnf\ install* ]]; then
        uninstall_command=$(echo "$command" | sed 's/install/remove/')
    elif [[ $command == sudo\ zypper\ install* ]]; then
        uninstall_command=$(echo "$command" | sed 's/install/remove/')
    elif [[ $command == sudo\ apk\ add* ]]; then
        uninstall_command=$(echo "$command" | sed 's/add/del/')
    elif [[ $command == pip\ install* ]]; then
        uninstall_command=$(echo "$command" | sed 's/install/uninstall/')
    elif [[ $command == pip3\ install* ]]; then
        uninstall_command=$(echo "$command" | sed 's/install/uninstall/')
    elif [[ $command == sudo\ npm\ install\ -g* ]]; then
        uninstall_command=$(echo "$command" | sed 's/install/uninstall/')
    elif [[ $command == sudo\ gem\ install* ]]; then
        uninstall_command=$(echo "$command" | sed 's/install/uninstall/')
    elif [[ $command == sudo\ cargo\ install* ]]; then
        uninstall_command=$(echo "$command" | sed 's/install/uninstall/')
    fi
    echo "$uninstall_command"
}

# Modified UNRUN function to use SUGGEST_UNINSTALL
function UNRUN() {
    local command="RUN $@"
    local line_num
    line_num=$(grep -n -F -- "$command" $REPOSITORY/.devcontainer/Dockerfile | cut -d: -f1)
    if [ -n "$line_num" ]; then
        sed -i "${line_num}d" $REPOSITORY/.devcontainer/Dockerfile
        echoColor "green" "Command removed from Dockerfile."

        local uninstall_command=$(SUGGEST_UNINSTALL "$@")
        if [[ -n $uninstall_command ]]; then
            echoColor "yellow" "A corresponding uninstall command was found: $uninstall_command"
            echoColor "yellow" "Do you want to run this command to uninstall the software? (y/n)"
            read -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echoColor "yellow" "Running uninstall command..."
                RUN "$uninstall_command"
            fi
        else
            echoColor "green" "Please manually remove any files created by this command, or run 'docker-compose build --no-cache' to rebuild the image."
        fi
    else
        echoColor "red" "Command not found in Dockerfile."
    fi
}

# Function for tab completion of UNRUN
function _UNRUN() {
    local curr_arg;
    COMPREPLY=()
    curr_arg=${COMP_WORDS[COMP_CWORD]}
    local dockerfile_contents=$(grep "^RUN " $REPOSITORY/.devcontainer/Dockerfile | sed 's/^RUN //')
    COMPREPLY=( $(compgen -W "${dockerfile_contents}" -- $curr_arg ) )
}

complete -F _UNRUN UNRUN