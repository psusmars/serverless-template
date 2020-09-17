#!/bin/bash
# grab user and group
# sudo docker
# sudo chown back all the files to the user
set -e
grep //NAME Makefile > /dev/null
if [ "$?" -ne 1 ]
then
  read -p "What would you like to name your lamda function? Alpha-numeric characters and dashes only" lambda_name
  sed -i "s=//NAME=$lambda_name=" Makefile
  sed -i "s=//NAME=$lambda_name=" README.md
fi

grep //TEMPLATE Makefile > /dev/null
if [ "$?" -ne 1 ]
then
  read -p "What template will you be using? You may find this page helpful: https://serverless.com/framework/docs/providers/aws/cli-reference/create/" template_name
  sed -i "s=//TEMPLATE=$template_name=" Makefile
fi

grep PICK_SOMETHING Dockerfile > /dev/null
if [ "$?" -ne 1 ]
then
  echo "What docker image will you use as your base?"
  echo "Remember to pick something that is close to your template."
  read docker_image
  sed -i "s=PICK_SOMETHING=$docker_image=" Dockerfile
fi

echo "Saving gitignore if one exists"
touch .gitignore
mv .gitignore .gitignore.bak

echo "Beginning setup"

make setup

echo "Finished setup, restoring your existing .gitignore"

cat .gitignore.bak >> .gitignore
rm -f .gitignore.bak

echo "Setup is done. Next Step: Installing known useful plugins"
read -p "Waiting for you to confirm the serverless.yml file. You may want to add region: 'us-west-2' under the provider section (hit enter when ready to continue setup)" foo

make install_plugins

echo "Updating gitignore"
printf "\nnode_modules/" >> .gitignore

echo "Enabling directory copy now that you have installed plugins"
echo "You'll no longer want to mount your directory inside unless you need to install plugins"
echo "There is a make target."

sed -i "s=##REMOVE_COMMENT:==" Dockerfile

echo "git adding files that are known to have been touched"

git add package.json package-lock.json serverless.yml Dockerfile Makefile .gitignore

make echo_local

echo "You may still need to update the Dockerfile section for how to manage your requirements"
echo "Now we'll update your Jenkinsfile, first be sure to push or add a remote"
echo "For Jenkins to automagically work, YOU MUST HAVE A GIT REPO BY THIS POINT"
read -p 'Hit enter when ready' foo

echo "Updating Jenkinsfile"

sed -i "s=//DOCKER_IMAGE_NAME=`make docker_image_name`=" Jenkinsfile
sed -i "s=//GIT_ORIGIN=`git config --get remote.origin.url`=" Jenkinsfile
