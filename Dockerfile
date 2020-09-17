# Use from as whatever your code will be executing on in lambda (match your serverless file)
FROM PICK_SOMETHING
# LABEL maintainer="paul.susmarski@gmail.com"


#### This section is likely to be used across lambdas

RUN apt-get update \
    && apt-get -y install curl gnupg docker \
    && curl -sL https://deb.nodesource.com/setup_11.x | bash - \
    && apt-get -y install nodejs \
    && rm -rf /var/lib/apt/lists/* 

RUN npm install -g serverless@1.50.0

ENV PATH=/root/.local/bin:$PATH

WORKDIR /src

#### END SECTION

### BEGIN ENVIRONMENT SPECIFIC STUFF

# Now you'll want to install any of your packages locally, below is an eample of python:
#### PYTHON requirements.txt EXAMPLE:
##### Connect to the docker instance, pip install pyyaml && pip freeze > requirements.txt 
##### Now make the pip install part of the workflow

##### COPY requirements.txt .

###### The mkdir command below is to fix a bug with the requirements plugin

##### RUN pip install -r requirements.txt && mkdir -p .serverless/requirements
 
### END SECTION

##REMOVE_COMMENT:COPY package* ./

##REMOVE_COMMENT:RUN npm install

##REMOVE_COMMENT:COPY . .