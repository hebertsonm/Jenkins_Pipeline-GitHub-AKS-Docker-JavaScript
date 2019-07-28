# Jenkins CI/CD pipeline between GitHub and AKS

This document describes how to configure a continuous delivery pipeline by using Jenkins.

The mentioned pipeline delivers a docker JavaScript application hosted by Github into AKS (Azure Kubernetes).

## Install AKS

Make sure the infrastructure is up and running (AKS and Jenkins)

https://github.com/hebertsonm/Azure-Kubernetes-Jenkins

## Configure Credentials

Go to Jenkins -> Credentials -> System -> Global Credentials

Add credentials:

Slave Node (id ubuntu18)

DockerHub (id dockerhub)

Azure Principal (id azure-credential)

## Configure Jenkins pipeline

Click the *New Item* menu within Jenkins

Provide a name for your new item (e.g. JS appname) and select *Pipeline*

### Configure GitHub trigger

In the General section of the job configuration check the Github project tick box and enter the URL to the repository

In the Build Triggers section, check the box *GitHub hook trigger for GITScm polling*

### Configure pipeline

In the Pipeline section, select *Pipeline script from SCM*, then select Git

Inform Repository address, credential (if needed), and branch. On *script path*, keep Jenkinsfile

Click the Save button and watch your first Pipeline run

## Backup/Restore Jenkins configuration

Jenkins configuration files are locate at $JENKINS_HOME folder.

Restore a previous backup by replacing all or specific files. Copy files from host into a container in Kubernetes with the command `kubectl cp <file-spec-src> <file-spec-dest>`

## Best Practices Reference

### Use the real Jenkins Pipeline

The Pipeline plugin is a step change improvement in the underlying job itself. Unlike freestyle jobs, Pipeline is resilient to Jenkins master restarts and also has built-in features that supersede many older plugins previously used to build multi-step, complex delivery pipelines.

### Develop your pipeline as code

Use the feature to store your Jenkinsfile in SCM then version and test it like you do other software.

Treating your pipeline as code enforces good discipline and also opens up a new world of features and capabilities like multi-branch, pull request detection and organization scanning for GitHub and BitBucket.

### All work within a stage

Any non-setup work within your pipeline should occur within a stage block.

Stages are the logical segmentation of a pipeline. Separating work into stages allows separating your pipeline into distinct segments of work.

And better still: the Pipeline Stage View plugin visualizes stages as unique segments of the pipeline.

### All material work within a node

Any material work within a pipeline should occur within a node block.

By default, the Jenkinsfile script itself runs on the Jenkins master, using a lightweight executor expected to use very few resources. Any material work, like cloning code from a Git server or compiling a Java application, should leverage Jenkins distributed builds capability and run an agent node.

### Work you can within a parallel step

Branching work in parallel will allow your pipeline to run faster, shifting your pipeline steps to the left, and getting feedback to developers and the rest of your team faster.

### Don’t use input within a node block

The input element pauses pipeline execution to wait for an approval - either automated or manual. Naturally these approvals could take some time. The node element, on the other hand, acquires and holds a lock on a workspace and heavy weight Jenkins executor - an expensive resource to hold onto while pausing for input.

Pipeline has an easy mechanism for timing out any given step of your pipeline. As a best practice, you should always plan for timeouts around your inputs.

For healthy cleanup of the pipeline, that’s why. Wrapping your inputs in a timeout will allow them to be cleaned-up (i.e., aborted) if approvals don’t occur within a given window.

```
timeout(time:5, unit:'DAYS') {
    input message:'Approve deployment?', submitter: 'it-ops'
}
```

### Don’t set environment variables with env global variable

While you can edit some settings in the env global variable, you should use the withEnv syntax instead.

Because the env variable is global, changing it directly is discouraged as it changes the environment globally, so the withEnv syntax is recommended.

```
withEnv(["PATH+MAVEN=${tool 'm3'}/bin"]) {
    sh "mvn clean verify"
}
```
