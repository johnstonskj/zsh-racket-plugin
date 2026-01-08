# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Plugin Name: racket
# Repository: https://github.com/johnstonskj/zsh-racket-plugin
#
# Description:
#
#   Plugin to configure environment variables for Racket programming language.
#
# Public variables:
#
# * `RACKET`; plugin-defined global associative array with the following keys:
#   * \`_ALIASES\`; a list of all aliases defined by the plugin.
#   * \`_FUNCTIONS\`; a list of all functions defined by the plugin.
#   * \`_PLUGIN_DIR\`; the directory the plugin is sourced from.
# * `RACKET_VERSION`; the version of Racket installed .
# * `RACKET_HOME`; the Racket installation directory.
# * `RACKET_USER`; the Racket user directory.
#

############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA RACKET
RACKET[_PLUGIN_DIR]="${0:h}"
RACKET[_ALIASES]=""
RACKET[_FUNCTIONS]=""

############################################################################
# Internal Support Functions
############################################################################

#
# This function will add to the `RACKET[_FUNCTIONS]` list which is
# used at unload time to `unfunction` plugin-defined functions.
#
# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
# See https://wiki.zshell.dev/community/zsh_plugin_standard#the-proposed-function-name-prefixes
#
.racket_remember_fn() {
    builtin emulate -L zsh

    local fn_name="${1}"
    if [[ -z "${RACKET[_FUNCTIONS]}" ]]; then
        RACKET[_FUNCTIONS]="${fn_name}"
    elif [[ ",${RACKET[_FUNCTIONS]}," != *",${fn_name},"* ]]; then
        RACKET[_FUNCTIONS]="${RACKET[_FUNCTIONS]},${fn_name}"
    fi
}
.racket_remember_fn .racket_remember_fn

.racket_define_alias() {
    local alias_name="${1}"
    local alias_value="${2}"

    alias ${alias_name}=${alias_value}

    if [[ -z "${RACKET[_ALIASES]}" ]]; then
        RACKET[_ALIASES]="${alias_name}"
    elif [[ ",${RACKET[_ALIASES]}," != *",${alias_name},"* ]]; then
        RACKET[_ALIASES]="${RACKET[_ALIASES]},${alias_name}"
    fi
}
.racket_remember_fn .racket_remember_alias

#
# This function does the initialization of variables in the global variable
# `RACKET`. It also adds to `path` and `fpath` as necessary.
#
racket_plugin_init() {
    builtin emulate -L zsh
    builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

    if [[ $OSTYPE = [Dd]arwin* ]] ; then
        export RACKET_VERSION=$(ls -d /Applications/Racket* |cut -d "v" -f 2 |sort -n |tail -1)
        export RACKET_HOME="/Applications/Racket\ v${RACKET_VERSION}"
        export RACKET_USER="${HOME}/Library/Racket/${RACKET_VERSION}"
        
        path_append_if_exists "${RACKET_HOME}/bin"
        path_append_if_exists "${RACKET_USER}/bin"
    fi
}
.racket_remember_fn racket_plugin_init

############################################################################
# Plugin Unload Function
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
racket_plugin_unload() {
    builtin emulate -L zsh

    # Remove all remembered functions.
    local plugin_fns
    IFS=',' read -r -A plugin_fns <<< "${RACKET[_FUNCTIONS]}"
    local fn
    for fn in ${plugin_fns[@]}; do
        whence -w "${fn}" &> /dev/null && unfunction "${fn}"
    done
    
    # Remove all remembered aliases.
    local aliases
    IFS=',' read -r -A aliases <<< "${RACKET[_ALIASES]}"
    local alias
    for alias in ${aliases[@]}; do
        unalias "${alias}"
    done

    # Reset global environment variables.
    unset RACKET_VERSION
    unset RACKET_HOME
    unset RACKET_USER
    
    # Remove the global data variable.
    unset RACKET

    # Remove this function.
    unfunction racket_plugin_unload
}

############################################################################
# Initialize Plugin
############################################################################

racket_plugin_init

true
