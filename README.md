# cluster-hibernate

## Summary
This repository is designed to allow you to hibernate provisioned clusters using a Red Hat Advanced Cluster Management for Kubernetes subscription. By including time
windows with the subscriptions, one subscription can be used to hibernate clusters and another to wake them up. This is done for Hive provisioned clusters using the `powerState` field.
By creating two subscriptions, each with a time window, clusters can be moved between powerStates. This is done using the Advanced Cluster Management subscription merge capability.

## Getting setup
1. Fork this repoistory to your local user or organization (forks for this repository are public)
3. Clone the repository to your development environment (Mac or Linux if you want to use a script to add clusters.
4. Connect to your Advanced Cluster Management hub
5. Enable subscription-admin for the user who just connected to the ACM hub.
Command:
```
oc edit clusterrolebinding open-cluster-management:subscription-admin
```
6. Add the following to the bottom of the clusterRoleBinding:
```
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: kube:admin
```
  - If `subjects` already exists, just add the hash as a new element in the `subjects` array
```
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: kube:admin
```
## Adding managed clusters to hibernate
1. If you will use this repository with more then one ACM hub, create a branch in your repository using the ACM hub's name
2. Run the `./add.sh` script for each cluster name you want to hibernate.
  - If ACM shows the cluster name as my-cluster01, run the following command:
  ```
  ./add.sh my-cluster01
  ```
  - This will create a file with the cluster name `my-cluster01.yaml` in the `./Running` and `./Hibernating` directories
3. Repeat step 2 for each cluster you wish to hibernate

## Manually adding managed cluster to hibernate
1. If you want to manually create these files, here are an example of each type:
```
# File ./Hibernating/my-cluster-name.yaml
---
apiVersion: hive.openshift.io/v1
kind: ClusterDeployment
metadata:
  name: my-cluster-name
  namespace: my-cluster-name
spec:
  powerState: Hibernating
```
```
# File ./Running/my-cluster-name.yaml
---
apiVersion: hive.openshift.io/v1
kind: ClusterDeployment
metadata:
  name: my-cluster-name
  namespace: my-cluster-name
spec:
  powerState: Running
```
2. Repeat step 1 for each cluster you wish to hibernate

### Optional: Preparing the secret for a private repository
1. Create a Git Token or re-use a Git token if you make the forked repository private. The token needs enough permissions to read a private repository.
2. If you copied this repository to a private repository, create the file `subscribe/git-secret.yaml` with your base64 encoded Git username and Git token.
  - You can use the example yaml in `subscribe/git-secret.example`, making sure to encode the two values (username & token) with `echo BASE64_GIT_USERNAME_OR_TOKEN | base64`
  - Make sure to rename the file `mv subscribe/git-secret.example subscribe\git-secret.yaml`
  - Uncomment the `#- git-secret.yaml` in the `subscribe/kustomization.yaml` file
  - Uncomment the `secretRef` and `name` in the `subscribe/Channel.yaml` file
  ```
  #secretRef:
  #  name: git-authentication-0
  ```

## Subscribe your ACM hub from the CLI
1. Run `./configure.sh`(once) to populate the branch and repository URL. 

2. OPTIONAL manual steps: (Instead of running `./configure.sh`)
- Edit `subscribe/Channel.yaml` and change `GIT_USERNAME` to your Git username or Organization
  ```
  spec:
    type: Git
    pathname: https://github.com/GIT_USERNAME/hive-hibernate.git

- Change the branch in the `subscribe/Running.yaml` and `subscribe/Hibernating.yaml` subscriptions. The default is `main`
```
apps.open-cluster-management.io/git-branch: my-branch-name
```
  ```

### OPTIONAL: Changing the time window
3. Edit the time windows in `subscribe/Hibernating.yaml` and `subscribe/Running.yaml`
```
spec:
  channel: >-
    cluster-hibernation-resource-ns-0/cluster-hibernation-resource-0
  placement:
    local: true
  timewindow:
    hours:
      - end: '07:10PM'
        start: '07:00PM'
    location: America/Toronto
    weekdays:
      - Monday
      - Tuesday
      - Wednesday
      - Thursday
      - Friday
    windowtype: active
```
  - The time window is configured to be active for 10 minutes from Monday - Friday at 7:00PM. This means the clusters will be hibernating in the evenings and weekends.
  - 10 minutes is enough time for the subscription to apply the update to all the clusters defined in the `./Hibernating` or `./Running` directories, even if the action takes longer to complete.  `location` is the timezone the time window will respect.

### Activate subscription
4. Apply the two subscriptions
```
make subscribe
```
5. The subscriptions will go into affect when the next time window is reached


## Subscribe your ACM hub using the console
1. Navigate to the Create Application console
2. Enter a `Name` and a `Namespace` (can be an exisitng namespace or a new namespace depending on the user's role)
3. Choose `Repository types` of `Git`
4. Enter the `URL`: `https://github.com/GIT_USERNAME/hive-hibernate.git` where GIT_USERNAME is your username or organization. (You can get this URL from the Git repository homepage, under `use https`). If the repository has been used previously you can select it from the drop down.
  a. If using a private Git repository, enter your Git username
  b. If using a private Git repository, enter your Git token
5. Enter the branch, `master` is the default
6. Enter the `Path`, use `Hibernating` this will instruct which clusters to hibernate
7. Check the `Merge updates` box
8. Select the `Deploy on local cluster`  radio button
9. Select `Active within specified interval`, and fill in your time window for hibernating your clusters
10. Choose `Add another repository`
11. Enter the `URL` you used in step (4)
12. Enter the branch you used in step (5)
13. Enter the `Path`, use `Running` this will instruct which clusters to resume
14. Check the `Merge updates` box
15. Select the `Deploy on local cluster` radio button
16. Select `Active within specified interval`, and fill in your time window for resuming your clusters
17. Click `Save` to complete

The system will then wait until the Hibernate or Running time windows are reached and the apply the new state to the clusters you defined in the directories. You can see the application in the Red Hat Advanced Cluster Management Application console

## List of make commands
```
make subscribe
make unsubscribe
make edit-hibernate-time
make edit-running-time
```