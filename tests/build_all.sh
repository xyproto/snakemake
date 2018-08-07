#!/usr/bin/env bash
set -e

# GOAL: Be able to run all tests for all directories, except the ones given on
# the commandline
skip=( "$@" )

# TODO: Rewrite in a proper programming language

cur_dir="$(pwd)"
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
examples_dir="$root_dir/../examples"
figlet=$(which figlet 2>/dev/null || echo)
cmds="clean build"

sm version

#if [ "$1" == run ]; then
#  # Also run if "run" was given
#  cmds="$cmds run"
#  shift
#  args="$@"
#elif [ "$1" == rebuild ]; then
#  # Only rebuild if "rebuild" was given
#  cmds="rebuild"
#  shift
#  args="$@"
#elif [ "$1" == fastbuild ] || [ "$1" == fast ]; then
#  cmds="fastclean build"
#  shift
#  args="$@"
#elif [ "$1" != build ] && [ "$1" != "" ]; then
#  cmds="$@"
#fi
#
#args="$@"

# contains checks if a bash array contains a given value
# returns "y" and error code 0 if yes; "n" and 1 of not
# thanks https://stackoverflow.com/q/3685970/131264
function contains() {
  local n=$#
  local value=${!n}
  for ((i=1;i < $#;i++)) {
    if [ "${!i}" == "${value}" ]; then
      echo "y"
      return 0
    fi
  }
  echo "n"
  return 1
}

#
# Skip what should be skipped, collect the other arguments
#

cmds="fastclean build"

# Perform all commands
for cmd in $cmds; do
  msg="Building all examples"
  if [ "$cmd" == clean ]; then
    msg="Cleaning all examples"
  elif [ "$cmd" == run ]; then
    msg="Running all examples"
  elif [ "$cmd" == rebuild ]; then
    msg="Rebuilding all examples"
  fi
  if [ ! $figlet == "" ]; then
    figlet -f small "$msg"
    echo
  else
    echo -e '|\n|'
    echo "|  $msg..."
    echo -e '|\n|'
  fi
  for example_dir in "$examples_dir"/*; do
    rel_dir="$(realpath --relative-to="$cur_dir" "$example_dir" 2>/dev/null || echo $example_dir)"
    name="$(basename "$rel_dir")"
    if [ $(contains "${skip[@]}" "$name") == "y" ]; then
      echo "Skipping (1) $rel_dir"
      continue
    fi
    if [ $(contains "$@" "$name") == "y" ]; then
      echo "Skipping (2) $rel_dir"
      continue
    fi
    echo "------- $rel_dir -------"
    if [ "$(basename "$rel_dir")" == "sfml" ] && [ "$(uname -s)" == "Darwin" ]; then
      # Should use clang for this combination
      extraflag="clang=1"
    else
      extraflag=
    fi
    echo sm -C "$rel_dir" $cmd
    sm -C "$rel_dir" $cmd
    echo
  done
done

echo 'Done.'
