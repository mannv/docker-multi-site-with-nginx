#!/bin/bash
echo "
web4:
	build: ./web4
	volumes:
		- E:/docker/multisite/www/web4/:/var/www/web4
	links:
		- php-fpm" >> docker-compose.yml