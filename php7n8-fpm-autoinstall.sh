	#!/bin/bash

	# run script as root user
	if [[ "$EUID" -ne 0 ]]; then
		echo
		echo -e "Sorry, you need to run this as root"
		echo
		exit 1
	fi
	# Clean screen
	clear
	# Select Linux distribution
	echo
	echo "   1) Debian 10 (+derivatives e.g Raspbian)"
	echo "   2) Ubuntu 16+ and flavors"
	while [[ $DISTRO !=  "1" && $DISTRO != "2" ]]; do
		echo
		read -p "Select an option and press ENTER [1-2]: " DISTRO
	done
	# Select php version
	echo ""
	echo "What would you like to do?"
	echo "   1) Install PHP 7.4"
	echo "   2) Install PHP 8.0"
	echo "   3) Exit"
	echo
	while [[ $PHP_VER !=  "1" && $PHP_VER != "2" && $PHP_VER != "3" ]]; do
		read -p "Select an option [1-3]: " PHP_VER
	done

	case $PHP_VER in
	1) # php7.4-fpm
		PHP_VER=7.4
	;;
	2) # php8.0-fpm
		PHP_VER=8.0
	;;
	3) # Goto previous menu
		echo ""
		echo "Bye!"
		echo ""
		exit
	;;
	esac
	# Find and remove all previously installed PHP versions
	  while [[ $PHPREM !=  "y" && $PHPREM != "n" ]]; do
	    echo
	    read -p "Would you like to remove all previously installed PHP versions [y/n]?: " -e PHPREM
	    echo
	  done
		while [[ $INSTPHP !=  "y" && $INSTPHP != "n" ]]; do
	    read -p "Would you like to install PHP-FPM too? [y/n]?: " -e INSTPHP
	  done

	case $DISTRO in
	# Debian 10 and derivatives
	1)
	if [[ ! -e /bin/lsb_release  ]]; then
	  apt install lsb-release -y >> /dev/null 2>&1;
	fi
	echo
	echo "Please wait ..."
	echo
	if [[ $(lsb_release -si) != "Debian" ]] || [[ $(lsb_release -si) != "Raspbian" ]]
	then
		echo "You've selected wrong Linux distribution!"
		echo "Please try again ..."
		echo ""
		exit 1
	else
		echo "Please wait, installing dependencies, adding repository..."
		echo
		apt update >> /dev/null 2>&1;
		apt install apt-transport-https ca-certificates wget -y
		wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
		apt update
		if [[ ! -e /etc/apt/sources.list.d/php.list ]]; then
			echo
			echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
		else
	  	echo "Repozitory exists ..."
		fi
	fi
		;;
	2)
	# Ubuntu flavors
	# Install dependencies
			echo
			echo "Please wait, installing dependencies, adding repository..."
			echo
			apt update; apt install -f; apt install software-properties-common wget -y
			echo
	# adding repository
			LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
			apt update; apt install -f;
			echo
	;;
esac
	# Remove all previously installed PHP versions and modules
	  if [[ "$PHPREM" = 'y' ]]; then
			echo
			apt autoremove --purge 'php*'
			rm -r /etc/php >> /dev/null 2>&1
			echo
	  fi
	# Update repositories
			echo
	 		echo "The following packages will be installed:"
			echo
			echo -e "php$PHP_VER-fpm\nphp$PHP_VER-common\nphp$PHP_VER-mbstring\nphp$PHP_VER-xmlrpc\nphp$PHP_VER-gd\nphp$PHP_VER-xml\nphp$PHP_VER-mysql\nphp$PHP_VER-cli\nphp$PHP_VER-zip\nphp$PHP_VER-curl\nphp-imagick"
			echo
			echo "Press any key to continue or ctrl+c to cancel..."
			read -n1 -r -p ""
			echo "Please wait, installing software ..."
			apt install php$PHP_VER-fpm php$PHP_VER-common php$PHP_VER-mbstring php$PHP_VER-xmlrpc php$PHP_VER-gd php$PHP_VER-xml php$PHP_VER-mysql php$PHP_VER-cli php$PHP_VER-zip php$PHP_VER-curl php-imagick -y
	# Install selected PHP version
	  if [[ "$INSTPHP" = 'y' ]]; then
	    echo
	    apt install php$PHP_VER -y
	  fi
	# Set as system default
	    echo
	  while [[ $DEFAULT !=  "y" && $DEFAULT != "n" ]]; do
			read -p "Would you like to set php$PHP_VER as a default system version [y/n]?: " -e DEFAULT
	  done
	  if [[ "$DEFAULT" = 'y' ]]; then
	    update-alternatives --set php /usr/bin/php$PHP_VER
	  fi
	  	echo
	# Enable at system boot
	  systemctl enable php$PHP_VER-fpm
	# Start php-fpm
	  echo
	  /etc/init.d/php$PHP_VER-fpm start
		echo
		echo "Installation complete."
		echo
	exit
