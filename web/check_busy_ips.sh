#!/bin/bash

cat /var/log/apache2/access.log | awk {'print $1'} | sort | uniq -c | awk '$1 > 100' | sort -nr
