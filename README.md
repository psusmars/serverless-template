# Template for serverless Lambda Functions

This repository contains templates for your own lambda function repository.

You'll want to read up a little bit on [serverless](https://serverless.com) as it's the utility that's used to deploy.

By cloning this repository and utilizing it you have confirmed that you read the entirety of this README as it pertains to your environment.

There are important steps in here that are mentioned and should not be ignored.

## How to use this Repository

### Initialization

First clone this repository and `/bin/rm -rf .git/` to make it yours and push as needed.

Select a template from the [serverless templates page](https://serverless.com/framework/docs/providers/aws/cli-reference/create/#available-templates) or install `serverless` via npm and run `serverless create --help` to see a list.

Decide what template of aws lambda you want to use, you can call `serverless create --help` or visit [create help](https://serverless.com/framework/docs/providers/aws/cli-reference/create/).

Assuming you've selected what template you want, you should then just be able to execute `setup.sh`.

**IT IS HIGHLY ADVISED YOU ADJUST THE serverless.yml AND BE SURE TO SELECT A PROPER REGION!!!**

It's also important that you validate the `runtime` section in the `serverless.yml` matches your `Dockerfile`.

In your `serverless.yml` only use alphanumerical characters and hyphens in the `service` name and `functions` section names.

### Setting up Triggers

You'll need to do an initial deploy, ideally from jenkins, and then update the triggers in the AWS interface as the `serverless.yml` doesn't have full support for all triggers.

### Setting up AWS for local testing

You don't necessarily needs AWS for local development, but if you want it in the docker container the `Makefile` uses your environment variables for it:

`AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)`

`AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)`

So you may want to make sure you have `AWS_SECRET_ACCESS_KEY` and `AWS_ACCESS_KEY_ID` in your environment variables.

## Dumping requirements

Each of the sections below tries to outline the steps for getting your lambda repository in a deployable state. If you do a new workflow, you'll want to note it here.

### Python

After you've done the getting started steps, you're going to need to make sure you have all of your packages installed. As an example, the following is installing `pyyaml`:

```bash
$ make run
(docker) $ pip install pyyaml && pip freeze > requirements.txt
(docker) $ exit
$ make correct_permissions
```

Once you have your `requirements.txt` generated, you'll want to update the proper section in the `Dockerfile`, then add the following lines to your `serverless.yml`:

```yaml
# serverless.yml

plugins:
  - serverless-python-requirements
```

This enables the dockerization of your requirements, which was pulled from [here](https://serverless.com/blog/serverless-python-packaging/). The plugin is part of the template file at the time of the writing.

## Information that can be Useful

The minimum aws credential requirements can be found [here](https://serverless.com/framework/docs/providers/aws/guide/credentials/?utm_source=cli&utm_medium=cli&utm_campaign=cli_helper_links)

You may want to even create a test lambda function in your chosen language to see what packages are pre-installed (see the **Gotchas** section).

### When Connecting an ALB

If you're connecting an [ALB event](https://serverless.com/framework/docs/providers/aws/events/alb/), be sure to use a priority that isn't already in existence.

Below is a sample `events` YAML that hits both internal ALBs. You'll notice that a function has to be created for each ALB, this is just how it is and makes sense if you start thinking about it.

```yml
function:
  FILL_ME_IN-prod:
    handler: handler.lambda_handler
    events:
      # Prod defs
      - alb: &alb_def
          method:
            - POST
          priority: SOME_RANDOM_PRIORITY_NUMBER
          listenerArn: arn:aws:elasticloadbalancing:us-west-2:237045316970:listener/app/Prod-Internal/48bf81485c0fcdb0/ee550d095e8830ce
          conditions:
            path: /lambda/run_batch_job
  FILL_ME_IN-staging:
    handler: handler.lambda_handler
    events:
      - alb:
          <<: *alb_def
          priority: SOME_RANDOM_PRIORITY_NUMBER
          listenerArn: arn:aws:elasticloadbalancing:us-west-2:237045316970:listener/app/Staging-Internal/1d7324da47e05cf5/149814a4180359ff
```

If you want to return json, you need to make sure you return responses that look like normal HTTP responses, this is an example python function that does exactly that:

```python
import json
def build_response(status_code=200, body={}):
    status_description = f"{status_code}"
    if status_code == 200:
        status_description += " OK"
    elif status_code == 400:
        status_description += " Bad Request"
    elif status_code == 422:
        status_description += " Unprocessable Entity"
    elif status_code == 500:
        status_description += " Internal Server Error"
    else:
        status_description += " Unknown"
    response = {
        "statusCode": status_code,
        "statusDescription": status_description,
        "isBase64Encoded": False,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }
    print(f"Response: {response}")
    return response

```

**WARNING**: It should be noted that the ALB will flip out if you don't return a string like object in the status description

## Gotchas

- When adding a custom role, it will overwrite the role that is automatically created for your lambda. This will put yourself in a situation where it can't write it's own logs in cloudwatch
- If you're using the docker worfklow, you may want to add the aws library as part of your setup. It's assumed that the code will be executing in aws which has the aws library installed in most situations, _but not all_. `serverless invoke local` might work to replicate the aws behavior

When porting an existing lambda:

- Note the triggers in the AWS Console then visit the [serverless events page](https://serverless.com/framework/docs/providers/aws/guide/events/#aws---events) to validate that the event can be added
- Note the roles that are already assigned to the lambda, as you'll likely have to create a custom role. You are able to use the [serverless yaml role assignment](https://serverless.com/framework/docs/providers/aws/guide/iam/#custom-iam-roles) if you so choose

## Documentation you may want to keep

Below is some documentation that should apply to all lambdas.

## Lambda Function to do XXXXX

This is the repository for the //NAME lambda function

Deployed using [serverless](https://serverless.com/framework/docs/).

All logs can be found [here](https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#logs:prefix=/aws/lambda///NAME).
