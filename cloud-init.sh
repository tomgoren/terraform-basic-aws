#!/usr/bin/env bash
# Run once on instance deploy, get nginx config and reload web server
sudo wget -O /etc/nginx/nginx.conf https://s3.amazonaws.com/challenge_config/nginx.conf
sudo /etc/init.d/nginx reload
