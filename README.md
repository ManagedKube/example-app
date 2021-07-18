# example-app

This an example app to show how an application can:
* Build and test on PRs
* Create a Docker image and push it to a repository
* Deploy the app out to an EKS cluster


## Build workflow
1. A PR is opened
1. The app is linted, built, and tests runs
1. Docker builds a container and pushes it to a Docker registry

## Deployment workflow

After the build workflow is successful on merge, this change can be deployed out to the `dev` environment.

On merge to `main` the Github Action will:
* Update the `dev` app's Docker tags to the one that was merged and commit these changes into `main`
* This commit will trigger a deployment for the `dev` app
* A Kubernetes check to make sure the new version of the app is in a health state
* The e2e tests will run

* On success of the e2e tests, an update to the `staging`'s app's Docker tags which will trigger a deploy to `staging`
* A Kubernetes check to make sure the new version of the app is in a health state
* The e2e tests will run

* On success of the e2e tests, an update to the `prod`'s app's Docker tags which will trigger a deploy to `prod`
* A Kubernetes check to make sure the new version of the app is in a health state
* The e2e tests will run
