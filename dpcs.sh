#!/usr/bin/env sh

VERBOSE=0

usage()
{
    echo "Usage: $0 [command] [value]"
    echo "Arguments:"
    echo "  -h                This message"
    echo "  -v                Verbose, enable log"
    echo -e "\nCommands:"
    echo "  rm                Remove cashed file (ex. $0 rm)"
    echo "  edit              Edit dependecies (ex. $0 edit)"
    echo "  add  [dependency] Add dependency (ex. $0 add \"wayland-server\")"
}

err()
{
  echo "ERROR: $1"
  exit
}

log()
{
  [ $VERBOSE == 1 ] && echo "$1"
}

# Starts Here
for arg in "$@"
do
    case "$arg" in
        # Cases for specific values
        -h|--help)
          usage
          exit
            ;;
        -v|--verbose)
          VERBOSE=1
            ;;
        "rm")
            action=0
            ;;
        "edit")
            action=1
            ;;
        "add")
            action=2
            ;;
        *)
          usage
          exit
            ;;
    esac
done

CACHE_DIR="$HOME/.cache/dpcs"
PROJECT_PATH="$CACHE_DIR/$PROJECT_HASH"

# Check if the current directory is a Git repository
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  # Get initial commit hash as project identifier
  PROJECT_HASH=$(git rev-list --max-parents=0 HEAD)
  PROJECT_PATH="$CACHE_DIR/$PROJECT_HASH"
else
  # If its not git repo ask to create hash from path
  read -p "This is not a Git repository. Do you want to create dependecies cache for current directory? (y/n): " answer
  [ "$answer" == "y" ] && echo -n $(pwd) | sha256sum | cut -d ' ' -f 1 
fi

log "HASH: $PROJECT_HASH"
log "PROJECT_PATH: $PROJECT_PATH"

# Check if dpcs directory exists, if not then create it
[ -d "$CACHE_DIR" ] || mkdir "$CACHE_DIR" 2> /dev/null || err "Failed to create dpcs cache directory"

# Check if git repo in current directory has stored dependecies, if not create file from hash of initial commit and add dependecies in $DEPS variable
[ -f "$PROJECT_PATH" ] ||
{ 
  echo -e "# Write your dependecies here: (don't delete this comment, it can break script functionality)\nDEPS=\"\"" >> $PROJECT_PATH || err "Cannot write $PROJECT_PATH"

  file_size=$(wc -c $PROJECT_PATH)

  $EDITOR $PROJECT_PATH
  
  [ "$file_size" == "$(wc -c $PROJECT_PATH)" ] &&
  { 
    rm $PROJECT_PATH
    err "No dependecies provided"
  }
} 

# Source file to get access to content of $DEPS variable
source "$PROJECT_PATH" || err "Error while sourcing: $PROJECT_PATH"

pkgPaths=""

while IFS= read -r line; do
  line_path=$(pkg-config $line 2>/dev/null) && pkgPaths="$line_path " || log "Cannot find $line"
done <<< $(printf "%s\n" ${DEPS// /$'\n'})


log "DEPENDECIES: $DEPS"
log "PATHS: $pkgPaths"

pathAndLine=$(rg "" $pkgPaths --line-number | fzf --ansi --color 'hl:-1:underline,hl+:-1:underline:reverse' --delimiter ':' --preview "bat --color=always {1} --highlight-line {2} | tail -n +{2}" --preview-window='70%' --height='100%' --with-nth 1,3.. --exact)

[ $? != 0 ] && exit

path_to_file=$(echo $pathAndLine | cut -d":" -f 2)
line_of_file=$(echo $pathAndLine | cut -d":" -f 1)

nvim -c $path_to_file $line_of_file
