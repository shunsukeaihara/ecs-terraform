#!/bin/bash
yum install -y jq aws-cli
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
sysctl -w net.core.somaxconn=65535

# install ssm agent
yum install -y https://amazon-ssm-$region.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm
# ECS config
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_UPDATES_ENABLED=true >> /etc/ecs/ecs.config
echo ECS_CONTAINER_STOP_TIMEOUT=5m >> /etc/ecs/ecs.config
echo ECS_AVAILABLE_LOGGING_DRIVERS=[\"json-file\",\"syslog\",\"fluentd\",\"awslogs\"] >> /etc/ecs/ecs.config
