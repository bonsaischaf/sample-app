#!/bin/bash
echo "install openjdk"
apt-get update
apt-get install -y openjdk-8-jre

echo "create user java"
useradd -M spring-boot
