# Author: jnpacker

if [ "$1" == "" ]; then
    echo Enter the server you wish to manage hibernation for
    read SERVER_NAME
else
    SERVER_NAME=$1
fi

if [ ! -d ./Hibernating ]; then
  mkdir -p Hibernating
fi
if [ ! -d ./Running ]; then
  mkdir -p Running
fi

cat > /tmp/$SERVER_NAME.yaml <<EOF
---
apiVersion: hive.openshift.io/v1
kind: ClusterDeployment
metadata:
  name: ${SERVER_NAME}
  namespace: ${SERVER_NAME}
spec:
EOF

cp /tmp/$SERVER_NAME.yaml ./Hibernating
mv /tmp/$SERVER_NAME.yaml ./Running

# Add Hibernating
echo "  powerState: Hibernating" >> ./Hibernating/${SERVER_NAME}.yaml
echo "  powerState: Running" >> Running/${SERVER_NAME}.yaml