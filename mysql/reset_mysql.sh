#!/bin/bash

/etc/init.d/mysql stop

/usr/bin/mysqld_safe --skip-grant-tables 

mysql -e "use mysql;update user set Password=PASSWORD('BP-Furn1tur3') where User='root';
