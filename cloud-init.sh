#!/usr/bin/env bash
sudo wget -O /etc/nginx/nginx.conf https://s3.amazonaws.com/challenge_config/nginx.conf
sudo /etc/init.d/nginx reload
