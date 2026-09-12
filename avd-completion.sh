if [ -n "${ZSH_VERSION:-}" ]; then
  _avd() { compadd -- -v -a -h --help --version; }
  compdef _avd avd
elif [ -n "${BASH_VERSION:-}" ]; then
  complete -W "-v -a -h --help --version" avd
fi
