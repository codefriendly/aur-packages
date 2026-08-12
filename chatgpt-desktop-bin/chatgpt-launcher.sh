#!/bin/sh

flags_file="${XDG_CONFIG_HOME:-${HOME}/.config}/chatgpt/flags.conf"
carriage_return="$(printf '\r')"

if [ -r "${flags_file}" ]; then
  original_argc=$#

  while IFS= read -r flag || [ -n "${flag}" ]; do
    flag=${flag%"${carriage_return}"}
    leading_space=${flag%%[![:space:]]*}
    flag=${flag#"${leading_space}"}
    trailing_space=${flag##*[![:space:]]}
    flag=${flag%"${trailing_space}"}

    case ${flag} in
      ''|'#'*) continue ;;
    esac

    set -- "$@" "${flag}"
  done < "${flags_file}"

  # Keep explicit command-line arguments after configured flags so they win.
  while [ "${original_argc}" -gt 0 ]; do
    original_arg=$1
    shift
    set -- "$@" "${original_arg}"
    original_argc=$((original_argc - 1))
  done
fi

launcher_dir="$(dirname "$(readlink -f "$0")")"
exec "${launcher_dir}/ChatGPT" "$@"
