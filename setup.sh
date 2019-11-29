#!/bin/bash

while getopts ":a:r:b:p:h" o; do case "${o}" in
	h) printf "Optional arguments for custom use:\\n  -r: Dotfiles repository (local file or url)\\n  -p: Dependencies and programs csv (local file or url)\\n  -a: AUR helper (must have pacman-like syntax)\\n  -h: Show this message\\n" && exit ;;
	r) dotfilesrepo=${OPTARG} && git ls-remote "$dotfilesrepo" || exit ;;
	b) repobranch=${OPTARG} ;;
	p) progsfile=${OPTARG} ;;
	a) aurhelper=${OPTARG} ;;
	*) printf "Invalid option: -%s\\n" "$OPTARG" && exit ;;
esac done

[ -z "$dotfilesrepo" ] && dotfilesrepo="https://github.com/lukesmithxyz/voidrice.git"
[ -z "$progsfile" ] && progsfile="https://raw.githubusercontent.com/gmatutecr/ebar/master/progs.csv"
[ -z "$aurhelper" ] && aurhelper="yay"
[ -z "$repobranch" ] && repobranch="master"



error() { clear; printf "ERROR:\\n%s\\n" "$1"; exit;}

welcomemsg(){\
        dialog --title "Welcome!" --msgbox "Welcome to Tute's  dev env bootstraping 🐻" 10 60    
}

preinstallmsg() { \
	dialog --title "Let's get this party started!" --yes-label "Let's go!" --no-label "No, nevermind!" --yesno "The rest of the installation will now be totally automated, so you can sit back and relax.\\n\\nIt will take some time, but when done, you can relax even more with your complete system.\\n\\nNow just press <Let's go!> and the system will begin installation!" 13 60 || { clear; exit; }
	}

installationloop() { \
	([ -f "$progsfile" ] && cp "$progsfile" /tmp/progs.csv) || curl -Ls "$progsfile" | sed '/^#/d' > /tmp/progs.csv
	total=$(wc -l < /tmp/progs.csv)
	while IFS=, read -r tag program comment; do
		n=$((n+1))
		echo "$comment" | grep "^\".*\"$" >/dev/null 2>&1 && comment="$(echo "$comment" | sed "s/\(^\"\|\"$\)//g")"
		case "$tag" in
			"") maininstall "$program" "$comment" ;;
			"G") gitmakeinstall "$program" "$comment" ;;
			"P") pipinstall "$program" "$comment" ;;
            "A") echo "$program" "$comment" ;;
		esac
	done < /tmp/progs.csv ;}

clear
echo "Preparing to launch..."

updateubuntupackages(){\
    echo "Updating Ubuntu packages"
    apt-get update -y "$1" >/dev/null 2>&1
}

installpkg(){\
  apt-get install -y "$1" >/dev/null 2>&1 ;
}

installscriptdeps(){\
    echo "Installing script dependencies"
    apt-get install -y fonts-emojione "$1" >/dev/null 2>&1
    apt-get install -y dialog "$1" >/dev/null 2>&1
}

maininstall() { # Installs all needed programs from main repo.
	dialog --title "Ebar Installation" --infobox "Installing \`$1\` ($n of $total). $1 $2" 5 70
	installpkg "$1"
	}

updateubuntupackages
installscriptdeps
welcomemsg || error "Something went wrong."
preinstallmsg || error "Something went wrong."
installationloop
