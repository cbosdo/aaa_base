#
# (c) System csh.cshrc for tcsh, Werner Fink '93
#                         and  J"org Stadler '94
#
# This file sources /etc/profile.d/complete.tcsh and
# /etc/profile.d/bindkey.tcsh used especially by tcsh.
#
# PLEASE DO NOT CHANGE /etc/csh.cshrc. There are chances that your changes
# will be lost during system upgrades. Instead use /etc/csh.cshrc.local for
# your local settings, favourite global aliases, VISUAL and EDITOR
# variables, etc ...
# USERS may write their own $HOME/.csh.expert to skip sourcing of
# /etc/profile.d/complete.tcsh and most parts oft this file.
#
onintr -
#
# Default echo style
#
set echo_style=both
#
#
setenv HOSTNAME "`hostname -f`"
setenv HOST     "`hostname -s`"
setenv MACHTYPE "`uname -m`"
#
# Do only once the initial setup
#
if (! ${?CSHRCREAD} ) then
    setenv MANPATH  "`(unsetenv MANPATH; manpath -q)`"
    setenv MINICOM  "-c on"
    setenv INFODIR  /usr/local/info:/usr/share/info:/usr/info
    setenv INFOPATH $INFODIR
    setenv LESS "-M -I"
    setenv LESSOPEN "lessopen.sh %s"
    setenv LESSCLOSE "lessclose.sh %s %s"
    if ( -s /etc/lesskey.bin ) then
	setenv LESSKEY /etc/lesskey.bin
    endif
    setenv PAGER '/usr/bin/less'
    setenv MORE -sl
    setenv GZIP -9
    setenv CSHEDIT emacs
    setenv COLORTERM 1
endif
#
#
if ( -s /etc/nntpserver ) then
   setenv NNTPSERVER `cat /etc/nntpserver`
else
   setenv NNTPSERVER news
endif
if ( -s /etc/organization ) then
   setenv ORGANIZATION "`cat /etc/organization`"
endif
#
# For all readline library based applications
#
if ( -r /etc/inputrc && ! ${?INPUTRC} ) setenv INPUTRC /etc/inputrc
#
# SuSEconfig stuff
#
# But do not source this if CSHRCREAD is already set to avoid
# overriding locale variables already present in the environment
#
if (! ${?CSHRCREAD} ) then
    if ( -r /etc/profile.d/csh.ssh )    source /etc/profile.d/csh.ssh
    if ( -r /etc/SuSEconfig/csh.cshrc ) source /etc/SuSEconfig/csh.cshrc
    if (! ${?SSH_SENDS_LOCALE} ) then
	if ( -r /etc/sysconfig/language && -r /etc/profile.d/csh.utf8 ) then
	    set _tmp=`sh -c '. /etc/sysconfig/language; echo $AUTO_DETECT_UTF8'`
	    if ( ${_tmp} == "yes" ) source /etc/profile.d/csh.utf8
	    unset _tmp
	endif
    endif
endif

#
# source extensions for special packages
#
if ( -d /etc/profile.d && ! ${?CSHRCREAD} ) then
  set _tmp=${?nonomatch}
  set nonomatch
  foreach _s ( /etc/profile.d/*.csh )
    if ( -r $_s ) then
      source $_s
    endif
  end
  if ( ! ${_tmp} ) unset nonomatch
  unset _tmp _s
endif

#
# Avoid overwriting user settings if called twice
#
if (! ${?CSHRCREAD} ) then
    setenv CSHRCREAD true
    set -r CSHRCREAD=$CSHRCREAD
endif
#
#
if (! ${?prompt}) goto end
#
# This is an interactive session
#
# Now read in the key bindings of the tcsh
#
if ($?tcsh && -r /etc/profile.d/bindkey.tcsh) source /etc/profile.d/bindkey.tcsh

#
# Expert mode: if we find $HOME/.csh.expert we skip our settings
# used for interactive sessions and read in the expert file.
#
if (-r $HOME/.csh.expert) then
    source $HOME/.csh.expert
    goto end
endif

#
# Some useful settings
#
set autocorrect=1
set listmaxrows=23
# set cdpath = ( /var/spool )
# set complete=enhance
# set correct=all
set correct=cmd
set fignore=(.o \~)
# set histdup=prev
set histdup=erase
set history=100
set listjobs=long
set notify=1
set nostat=( /afs )
set rmstar=1
set savehist=( $history merge )
set showdots=1
set symlinks=ignore
#
unset autologout
unset ignoreeof
#
set noglob
if ( -x /usr/bin/dircolors ) then
    if ( -r $HOME/.dir_colors ) then
	eval `dircolors -c $HOME/.dir_colors`
    else if ( -r /etc/DIR_COLORS ) then
	eval `dircolors -c /etc/DIR_COLORS`
    endif
endif
setenv LS_OPTIONS '--color=tty'
if ( ${?LS_COLORS} ) then
    if ( "${LS_COLORS}" == "" ) setenv LS_OPTIONS '--color=none'
endif
unalias ls
if ( "$uid" == "0" ) then
    setenv LS_OPTIONS "-a -N $LS_OPTIONS -T 0"
else
    setenv LS_OPTIONS "-N $LS_OPTIONS -T 0"
endif
alias ls 'ls $LS_OPTIONS'
alias la 'ls -AF --color=none'
alias ll 'ls -l  --color=none'
alias l  'll'
alias dir  'ls --format=vertical'
alias vdir 'ls --format=long'
alias d dir;
alias v vdir;
# Handle emacs
if ($?EMACS) then
  setenv LS_OPTIONS '-N --color=none -T 0';
  tset -I -Q
  stty cooked pass8 dec nl -echo
# if ($?tcsh) unset edit
endif
unset noglob

#
# Prompting and Xterm title
#
set prompt="%B%m%b %C2%# "
if ( -o /dev/$tty ) then
  alias cwdcmd '(echo "Directory: $cwd" > /dev/$tty)'
  if ( -x /usr/bin/biff ) /usr/bin/biff y
  # If we're running under X11
  if ( ${?DISPLAY} ) then
    if ( ${?TERM} && ${?EMACS} == 0 ) then
      if ( ${TERM} == "xterm" ) then
        alias cwdcmd '(echo -n "\033]2;$USER on ${HOST}: $cwd\007\033]1;$HOST\007" > /dev/$tty)'
        cd .
      endif
    endif
    if ( -x /usr/bin/biff ) /usr/bin/biff n
    set prompt="%C2%# "
  endif
endif
#
# tcsh help system does search for uncompressed helps file
# within the cat directory system of a old manual page system.
# Therefore we use whatis as alias for this helpcommand
#
alias helpcommand whatis

#
# Source the completion extension of the tcsh
#
if ($?tcsh) then
    set _rev=${tcsh:r}
    set _rel=${_rev:e}
    set _rev=${_rev:r}
    if (($_rev > 6 || ($_rev == 6 && $_rel > 1)) && -r /etc/profile.d/complete.tcsh) then
	source /etc/profile.d/complete.tcsh
    endif
    #
    # Enable editing in multibyte encodings for the locales
    # where this make sense, but not for the new tcsh 6.14.
    #
    if ($_rev < 6 || ($_rev == 6 && $_rel < 14)) then
	switch ( `locale charmap` )
	case UTF-8:
	    set dspmbyte=utf8
            breaksw
	case BIG5:
	    set dspmbyte=big5
            breaksw
	case EUC-JP:
	    set dspmbyte=euc
            breaksw
	case EUC-KR:
	    set dspmbyte=euc
            breaksw
	case GB2312:
	    set dspmbyte=euc
	    breaksw
	case SHIFT_JIS:
	    set dspmbyte=sjis
            breaksw
	default:
            breaksw
	endsw
    endif
    #
    unset _rev _rel
endif
end:
    onintr
    unset noglob

#
# Local configuration
#
if ( -r /etc/csh.cshrc.local ) source /etc/csh.cshrc.local

#
# csh.cshrc end here
#
