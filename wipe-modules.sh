#!/usr/bin/env sh

# variables
code_dir=$1
last_modified=$2
modules_removed=0
is_dir=0
is_number=0
run=0

# usage info
usage() {
  cat <<EOF

  Usage: wipe-modules [path] [days]

  Path:
    The full path of your code directory

  Days:
    The days you want to set to mark projects as inactive

  Example: wipe-modules ~/code 30

  That will remove the node_modules of your ~/code projects
  whose been inactive for 30 days or more.

EOF
}

# instructs agent gir to start ripping off those pesky node_modules
go_gir() {
  # move to code directory
  cd $code_dir

  # find the code directories whose last modify time (mtime) is older than $last_modified days
  # and loop through each resulting dir
  for d in `find . -maxdepth 1 -type d -mtime +$last_modified`; do
    # move to code dir subdirectory
    cd $d
    if [ `find . -maxdepth 1 -type d -name 'node_modules'` ]
    then
      # wipe the node_modules folder!
      rm -rf node_modules
      modules_removed=`expr $modules_removed + 1`
    fi
    # go one directory up to continue iterating
    cd ..
  done

  # display nice little information message when done
  if [ $modules_removed -gt 0 ]; then
    echo "\033[90m $modules_removed node_modules successfully removed! \033[39m"
  else
    echo "\033[90m Our agent couldn't find any inactive project. \033[39m"
  fi
}

# if $1 parameter is --help or -h then show usage info
if [ "$1" == "--help" -o "$1" == "-h" ]
then
  usage
  exit 0
else
  # check if $1 parameter is a valid directory
  if [ -d "$code_dir" ]; then
    is_dir=1
  fi
fi

# check if $2 parameter is a valid number (regex)
regx='^[0-9]+$'
if [[ $last_modified =~ $regx ]]; then
  is_number=1
fi

# if valid parameters are being passed then prepare for action
if [ $is_dir -eq 1 -a $is_number -eq 1 ]; then
  run=1
fi

# if everything ok... press the green button!
if [ $run -eq 1 ]; then
  echo ""
  echo "\033[90m Our agent is examining your files... Hold on a sec. \033[39m"
  sleep 2
  echo ""
  go_gir
  exit 0
else
  if [ $is_dir -eq 0 ]; then
    echo ""
    echo "Error: Invalid directory, please provide a valid one." >&2; exit 1
  fi
  if [ $is_number -eq 0 ]; then
    echo ""
    echo "Error: Please provide a valid number." >&2; exit 1
  fi
fi
