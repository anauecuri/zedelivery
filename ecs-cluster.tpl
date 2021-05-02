#!/bin/bash
touch /etc/ecs/ecs.config
cat <<EOT > /etc/ecs/ecs.config
ECS_ENABLE_TASK_IAM_ROLE=true
ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true
ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]
ECS_LOGLEVEL=debug
ECS_CLUSTER=zedelivery-ecs-cluster
EOT
yum install -y awslogs
mv /etc/awslogs/awslogs.conf /etc/awslogs/awslogs.conf.bak
touch /etc/awslogs/awslogs.conf
cat <<EOT > /etc/awslogs/awslogs.conf
[general]
state_file = /var/lib/awslogs/agent-state
[/var/log/dmesg]
file = /var/log/dmesg
log_group_name = zedelivery-Infra-ECS-OS-dmesg
log_stream_name = {instance_id}
[/var/log/messages]
file = /var/log/messages
log_group_name = zedelivery-Infra-ECS-OS-messages
log_stream_name = {instance_id}
datetime_format = %b %d %H:%M:%S
[/var/log/ecs/ecs-init.log]
file = /var/log/ecs/ecs-init.log
log_group_name = zedelivery-Infra-ECS-OS-ecs-init.log
log_stream_name = {instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ
[/var/log/ecs/ecs-agent.log]
file = /var/log/ecs/ecs-agent.log
log_group_name = zedelivery-Infra-ECS-OS-ecs-agent.log
log_stream_name = {instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ
EOT
#sed -i -e "s/us-east-1/sa-east-1/g" /etc/awslogs/awscli.conf
systemctl start awslogsd
systemctl enable awslogsd
/bin/easy_install --script-dir /opt/aws/bin https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
/opt/aws/bin/cfn-signal -e $? --stack zedelivery-ecs-cluster --resource ECSAutoScalingGroup --region us-east-1

echo -------------DEEPSECURITY instalation code------------
#touch /tmp/deepsecurity.sh
#cat <<EOL > /tmp/deepsecurity.sh 
#cat > /tmp/deepsecurity.sh << EOT

ACTIVATIONURL='dsm://VVCEWPDSMG01.CCORP.LOCAL:4120/'
MANAGERURL='https://VVCEWPDSMG01.CCORP.LOCAL:4119'
CURLOPTIONS='--silent --tlsv1.2'
linuxPlatform='';
isRPM='';


if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo You are not running as the root user.  Please try again with root privileges.;
    logger -t You are not running as the root user.  Please try again with root privileges.;
    exit 1;
fi;


if ! type curl >/dev/null 2>&1; then
    echo "Please install CURL before running this script."
    logger -t Please install CURL before running this script
    exit 1
fi


curl $MANAGERURL/software/deploymentscript/platform/linuxdetectscriptv1/ -o /tmp/PlatformDetection $CURLOPTIONS --insecure


if [ -s /tmp/PlatformDetection ]; then
    . /tmp/PlatformDetection
else
    echo "Failed to download the agent installation support script."
    logger -t Failed to download the Deep Security Agent installation support script
    exit 1
fi


platform_detect
if [[ -z "$${linuxPlatform}" ]] || [[ -z "$${isRPM}" ]]; then
    echo Unsupported platform is detected
    logger -t Unsupported platform is detected
    exit 1
fi


echo Downloading agent package...
if [[ $isRPM == 1 ]]; then package='agent.rpm'
    else package='agent.deb'
fi
curl $MANAGERURL/software/agent/$linuxPlatform -o /tmp/$package $CURLOPTIONS --insecure


echo Installing agent package...
rc=1
if [[ $isRPM == 1 && -s /tmp/agent.rpm ]]; then
    rpm -ihv /tmp/agent.rpm
    rc=$?
elif [[ -s /tmp/agent.deb ]]; then
    dpkg -i /tmp/agent.deb
    rc=$?
else
    echo Failed to download the agent package. Please make sure the package is imported in the Deep Security Manager
    logger -t Failed to download the agent package. Please make sure the package is imported in the Deep Security Manager
    exit 1
fi
if [[ $${rc} != 0 ]]; then
    echo Failed to install the agent package
    logger -t Failed to install the agent package
    exit 1
fi


echo Install the agent package successfully
sleep 25

/opt/ds_agent/dsa_control -r
sleep 25

/opt/ds_agent/dsa_control -a $ACTIVATIONURL "policyid:68" "groupid:2898"
# /opt/ds_agent/dsa_control -a dsm://VVCEWPDSMG01.CCORP.LOCAL:4120/ "policyid:68" "groupid:2898""
# EOT
# /bin/sh /tmp/deepsecurity.sh