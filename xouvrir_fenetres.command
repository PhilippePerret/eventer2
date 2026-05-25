#!/bin/zsh

DOSSIER="/Users/philippeperret/Programmes/Eventer2"

open_list_window () {
  local TARGET="$1"
  local BOUNDS="$2"
  local TYPEVIEW="$3"

  osascript <<EOF
tell application "Finder"
  activate
  open POSIX file "$TARGET"
  
  tell front Finder window
    if TYPEVIEW is "list" then 
      set current view to list view
    end
    set toolbar visible to true
    set statusbar visible to true
    set bounds to $BOUNDS
  end tell
end tell
EOF
}

open_list_window "$DOSSIER/lib" "{304, 30, 1250, 541}" "list"
open_list_window "$DOSSIER/public" "{1265, 30, 2218, 538}" "list"
open_list_window "$DOSSIER/tests/e2e" "{2228, 30, 3172, 546}" "list"
open_list_window "$DOSSIER" "{813, 665, 2646, 1197}" "none"