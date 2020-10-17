# Author: jnpacker

gitInfo=(`cat .git/FETCH_HEAD | sed 's/  */\n/g' | sed 's/ /\n/g'`)
branch=${gitInfo[2]//\'/}
echo "Applying branch ${gitInfo[2]//\'/} to subscribe/Running.yaml and subscribe/Hibernating.yaml"
sed -i "s/BRANCH_NAME/${branch}/" subscribe/Running.yaml
sed -i "s/BRANCH_NAME/${branch}/" subscribe/Hibernating.yaml

channel=${gitInfo[4]//github.com:/}
channel=${channel/\/cluster-hibernate/}
echo "Applying channel $channel to subscribe/Channel.yaml"
sed -i "s/GIT_USERNAME/${channel}/" subscribe/Channel.yaml