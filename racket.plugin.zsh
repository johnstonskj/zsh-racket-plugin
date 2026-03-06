# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name racket
# @brief Plugin to configure environment variables for Racket programming language.
#
# ### Public Variables
#
# * `RACKET_VERSION`; the version of Racket installed .
# * `RACKET_HOME`; the Racket installation directory.
# * `RACKET_USER`; the Racket user directory.
#

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

racket_plugin_init() {
    builtin emulate -L zsh

    if [[ $OSTYPE = [Dd]arwin* ]] ; then
        @zplugins_envvar_save racket RACKET_VERSION
        export RACKET_VERSION=$(ls -d /Applications/Racket* |cut -d "v" -f 2 |sort -n |tail -1)

        @zplugins_envvar_save racket RACKET_HOME
        export RACKET_HOME="/Applications/Racket\ v${RACKET_VERSION}"
        @zplugins_add_to_path racket "${RACKET_HOME}/bin"
        
        @zplugins_envvar_save racket RACKET_USER
        export RACKET_USER="${HOME}/Library/Racket/${RACKET_VERSION}"        
        @zplugins_add_to_path racket "${RACKET_USER}/bin"
    fi
}

# @internal
racket_plugin_unload() {
    builtin emulate -L zsh

    if [[ $OSTYPE = [Dd]arwin* ]] ; then
        @zplugins_envvar_restore racket RACKET_VERSION
        @zplugins_envvar_restore racket RACKET_HOME
        @zplugins_envvar_restore racket RACKET_USER
    fi
}
