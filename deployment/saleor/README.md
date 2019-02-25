# Saleor helm chart

## Table of Contents 

-   [Introduction](#introduction)

    -   [What is Saleor ?](#what-is-saleor-)

-   [Prerequisites](#prerequisites)

-   [Quickstart](#quickstart)

-   [Saleor components](#saleor-components)

    -   [Cluster components](#cluster-components)
    -   [External components](#external-components)

-   [Chart Architecture](#chart-architecture)

-   [Chart Configuration](#chart-configuration)

    -   [Values Configuration](#values-configuration)
    -   [Secrets Configuration](#secrets-configuration)

-   [Chart Repository](#chart-repository)

-   [Installation](#installation)

    -   [Default Installation](#default-installation)
    -   [Installation with custom secret](#installation-with-custom-secret)

-   [Upgrades](#upgrades)

-   [Maintenance](#maintenance)

    -   [Backup](#backup)
    -   [Restore](#restore)

-   [Uninstallation](#uninstallation)

-   [Changelog](../../CHANGELOG.md)

## Introduction

### What is Saleor ?
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

Saleor is a high-performance e-commerce solution created with Python and Django.
 
The traditional saleor MVC technology stack includes:
 
-   Django
-   NodeJs
-   PostgreSQL
-   Redis
-   ElasticSearch
-   Sentry
-   Docker
  
The SPA saleor storefront technology stack includes:

-   GraphQL
-   ReactJS
-   Typescript
  
Features are describe in more depth on the [saleor README](https://github.com/mirumee/saleor#features)

## Prerequisites
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

-   A kubernetes cluster with helm installed
-   Persistent volumes available with a storageclass
-   Enough cpu and memory resources for postgresql, redis, elasticsearch and saleor

*Note:*

-   An elasticsearch cluster requires a large allocation of memory resources

```yaml
elasticsearch:
  enabled: false
```

-   The elasticsearch deployment can delay the total startup time,
it may be necessary to increase the helm timeout if elasticsearch is enabled. 

```shell
helm install --timeout 900 ... 
```

## Quickstart
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

### Step 1 (Quickstart)

Create a custom secret file, example below:

```text
apiVersion: v1
kind: Secret
metadata:
  name: saleor-custom
  namespace: default
  labels:
    app: saleor
    release: saleor
type: Opaque
data:
  email-password:
  open-exchanges-api-key:
  recaptcha-private-key:
  saleor-secret-key:
  vat-layer-access-key:
  redis-password:
  postgresql-password:
  braintree-private-key:
  razorpay-secret-key:
  stripe-secret-key:
```

### Step 2 (Quickstart)

The chart must be downloaded as a chart archive has still not been created:

```shell
git clone https://github.com/stephenmoloney/saleor-helm.git --branch=master && cd saleor-helm;
```

### Step 3 (Quickstart)

Install the helm chart
 
-   The `values.yaml` file can be configured as required. See [Values configuration](#values-configuration)
-   For example, if using an existing secret, create a `values-prod.yaml`
```yaml
saleor:
existingSecret: saleor-custom
redis:
enabled: true
existingSecret: saleor-custom
postgresql:
enabled: true
existingSecret: saleor-custom
```

```shell
helm dependency build ./deployment/saleor && \
helm install --name saleor -f values-prod.yaml ./deployment/saleor;
```

## Saleor components
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

Saleor components could be divided into 2 groups:

-   *Cluster components* are those components which can be self-hosted and
part of the kubernetes cloud infrastructure

-   *External components* are those components which are essentially
software as a service (SAAS) components and are external to the
kubernetes cloud infrastructure. They cannot be optionally self-hosted.

### Cluster components
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

| Chart Component   | Optional                | 
|------------------ |------------------------ |
| Saleor            | :x:                     |
| Redis             | :x:                     |
| Postgresql        | :x:                     |
| Elasticsearch     | :heavy_check_mark:      |

The app requires redis and postgresql to function properly. Elasticsearch is optional.

The helm installation can deploy redis, postgresql and elasticsearch or one can use
externally provided deployments of any of these services once the appropriate credentials for the
service are added to the appropriate kubernetes secrets file.

### External Components
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

Saleor uses number of external services to externalize development efforts
for some parts of the application. If integration with these components
is necessary, read further documentation. Changes to `secrets.yaml`
and/or `values.yaml` with the details of your external provider account may be required.

| Service            | Description                                                                                                                                                                                         | Essential                       |
|------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |-------------------------------- |
| Email Provider     | External email providers, eg mailgun, mailjet, sendgrid, amazon ses, etc, see [docs](https://github.com/mirumee/saleor/blob/master/docs/guides/email_integration.rst)                               | :heavy_check_mark:              |
| Google Recaptcha   | Spam mitigation, see [docs](https://github.com/mirumee/saleor/blob/master/docs/guides/recaptcha.rst)                                                                                                | :x:                             |
| Vat Layer API      | Maintaining correct EU vat rates See [docs](https://github.com/mirumee/saleor/blob/master/docs/guides/taxes.rst)                                                                                    | :heavy_check_mark:              |
| Open Exchanges API | Maintainance of up-to-date currency exchange rates See open exchanges api [website](https://openexchangerates.org)                                                                                  | :heavy_check_mark:              |
| Transifex          | A localization helper service, see [docs](https://github.com/mirumee/saleor/blob/master/docs/architecture/i18n.rst)                                                                                 | :x:                             |
| Sentry             | An externalized error monitoring tool, see [docs](https://github.com/mirumee/saleor/blob/master/docs/integrations/sentry.rst)                                                                       | :x:                             |
| Google for retail  | Tools for generating product feed which can be used with Google Merchant Center, see [docs](https://github.com/mirumee/saleor/blob/master/docs/integrations/googleforretail.rst)                    | :x:                             |
| Google Analytics   | Google analytics integration, see [docs](https://github.com/mirumee/saleor/blob/master/docs/integrations/googleanalytics.rst)                                                                       | :x:                             |
| Schema.org Markup  | Schema.org markup for emails, see [docs](https://github.com/mirumee/saleor/blob/master/docs/integrations/emailmarkup.rst) and read [more here](https://developers.google.com/gmail/markup/overview) | :x:                             |
| SMO                | Saleor uses opengraph for optimizing social media engagement, see [docs](https://github.com/mirumee/saleor/blob/master/docs/integrations/smo.rst)                                                   | :heavy_check_mark:              |
| SEO                | Saleor handles aspects of search engine optimization, see [docs](https://github.com/mirumee/saleor/blob/master/docs/integrations/seo.rst)                                                           | :heavy_check_mark:              |

## Chart Architecture
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

Parent Chart (saleor):

```text
./deployment/saleor/templates/
├── celery-deployment.yaml
├── celery-hpa.yaml
├── custom-settings.yaml
├── custom-uwsgi.yaml
├── django-deployment.yaml
├── django-hpa.yaml
├── django-service.yaml
├── env.yaml
├── _helpers.tpl
├── hooks
│   ├── cronjobs
│   │   ├── currency-update-cronjob.yaml
│   │   └── vat-update-cronjob.yaml
│   └── jobs
│       ├── 01_db-migrate-job.yaml
│       ├── 02_db-populate-demo-job.yaml
│       ├── 03_db-create-users-job.yaml
│       ├── 04_currency-update-job.yaml
│       ├── 05_vat-update-job.yaml
│       └── 06_nginx-job.yaml
├── ingress.yaml
├── nginx-deployment.yaml
├── nginx-hpa.yaml
├── nginx-service.yaml
├── nginx-template.yaml
├── NOTES.txt
├── pvc.yaml
└── secrets.yaml
```

| Template                        | Description                                                                                             |
| ------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `celery-deployment.yaml`        | Deploys pod(s) for the celery worker(s). Handles task queues for emails, image thumbnails, etc          |
| `celery-hpa.yaml`               | Horizontal pod autoscaling for the celery worker pods                                                   |
| `custom-settings.yaml`          | Some custom additions/amendments to the `settings.py` file                                              |
| `custom-uwsgi.yaml`             | Some custom additions/amendments to the `custom-uwsgi.yaml` file                                        |
| `django-deployment.yaml`        | Deploys pod(s) for the core saleor (django) application.                                                |
| `django-hpa.yaml`               | Horizontal pod autoscaling for the saleor (django) pods                                                 |
| `django-service.yaml`           | A service resource for the django application                                                           |
| `env.yaml`                      | A configmap data file with non-sensitive environment variables                                          |
| `_helpers.tpl`                  | Helper templates designed to reduce code replication (DRY)                                              |
| `currency-update-cronjob.yaml`  | A cronjob for updating the currency rates periodically                                                  |
| `vat-update-cronjob.yaml`       | A cronjob for updating the vat rates periodically                                                       |
| `01_db-migrate-job.yaml`        | Executes saleor database migrations                                                                     |
| `02_db-populate-demo-job.yaml`  | Executes saleor database population and media file creation for the demo storefront                     |
| `03_db-create-users-job.yaml`   | Executes saleor database population with predefined users                                               |
| `04_currency-update-job.yaml`   | Inserts the currency rates                                                                              |
| `05_vat-update-job.yaml`        | Inserts the vat rates                                                                                   |
| `06_nginx-job.yaml`             | Prepares nginx pod if nginx as a server is enabled                                                      |
| `ingress.yaml`                  | Defines how to handle incoming traffic to the service                                                   |
| `nginx-deployment.yaml`         | Deploys pod(s) for the nginx server. Handles serving static and media assets                            |
| `nginx-hpa.yaml`                | Horizontal pod autoscaling for the nginx pods                                                           |
| `nginx-service.yaml`            | A service resource for the nginx server                                                                 |
| `nginx-template.yaml`           | A configmap with the default `nginx.conf` file specific for a saleor deployment                         |
| `NOTES.txt`                     | Notes about the deployment presented to the user on successful deployment                               |
| `pvc.yaml`                      | A persistent volume claim resource for storing /app/media content, ie. images, etc                      |
| `secrets.yaml`                  | A kubernetes secret file with sensitive environment variables                                           |

Secondary charts (subcharts):

```text
./charts/
├── charts
│   ├── elasticsearch-1.11.1.tgz
│   ├── postgresql-1.0.0.tgz
│   ├── redis-4.2.1.tgz
├── requirements.lock
├── requirements.yaml
```

## Chart configuration
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

The chart configuration can be divided into two parts

-   setting the parameters in `values.yaml`
-   setting the parameters for secrets with sensitive variables

### Values configuration
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

Configuration for the parent chart parameters under the namespace `.Values.saleor.` 

| Parameter                                                                 | Description                                                                                                                                                                 | Default                                       |
| ------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| <sub>`saleor.image.repository`</sub>                                      | <sub>Docker image repository</sub>                                                                                                                                          | <sub>`mirumee/saleor`</sub>                   |
| <sub>`saleor.image.tag`</sub>                                             | <sub>The version of the docker image</sub>                                                                                                                                  | <sub>`master-b46f30`</sub>                    |
| <sub>`saleor.image.pullPolicy`</sub>                                      | <sub>Conditions for pulling the docker image</sub>                                                                                                                          | <sub>`IfNotPresent`</sub>                     |
| <sub>`saleor.image.pullPolicy`</sub>                                      | <sub>The version of the docker image</sub>                                                                                                                                  | <sub>`IfNotPresent`</sub>                     |
| <sub>`saleor.image.pullSecret`</sub>                                      | <sub>The pull secret required to authenticate with a private docker registry</sub>                                                                                          | <sub>`None`</sub>                             |
| <sub>`saleor.existingSecret`</sub>                                        | <sub>If set, the chart will disregard the default secret and use this secret instead</sub>                                                                                  | <sub>`None`</sub>                             |
| <sub>`saleor.gloal.service.type`</sub>                                    | <sub>The type of service to be used, can be `ClusterIP`, `NodePort` or `Loadbalancer`</sub>                                                                                 | <sub>`LoadBalancer`</sub>                     |
| <sub>`saleor.gloal.service.port`</sub>                                    | <sub>The port on which to expose the saleor service</sub>                                                                                                                   | <sub>`80`</sub>                               |
| <sub>`saleor.ingress.enabled`</sub>                                       | <sub>Whether to handle incoming traffic through and ingress controller</sub>                                                                                                | <sub>`false`</sub>                            |
| <sub>`saleor.ingress.annotations`</sub>                                   | <sub>Annotations to be set on the ingress resource</sub>                                                                                                                    | <sub>`{}`</sub>                               |
| <sub>`saleor.ingress.path`</sub>                                          | <sub>The path being handled by the ingress resource, traffic will be forwarded to the service</sub>                                                                         | <sub>`/`</sub>                                |
| <sub>`saleor.ingress.hosts`</sub>                                         | <sub>A list of hosts to be handled by the ingress resource</sub>                                                                                                            | <sub>`saleor.local`</sub>                     |
| <sub>`saleor.ingress.tls`</sub>                                           | <sub>A list of tls related resources</sub>                                                                                                                                  | <sub>`[]`</sub>                               |
| <sub>`saleor.persistence.enabled`</sub>                                   | <sub>Whether to enable disk persistence for saleor media content</sub>                                                                                                      | <sub>`false`</sub>                            |
| <sub>`saleor.persistence.accessMode`</sub>                                | <sub>Disk access mode</sub>                                                                                                                                                 | <sub>`ReadWriteOnce`</sub>                    |
| <sub>`saleor.persistence.size`</sub>                                      | <sub>Size of the disk to be allocated</sub>                                                                                                                                 | <sub>`10Gi`</sub>                             |
| <sub>`saleor.persistence.volume`</sub>                                    | <sub>Type of volume for the persistent disk</sub>                                                                                                                           | <sub>`Filesystem`</sub>                       |
| <sub>`saleor.persistence.persistentVolumeReclaimPolicy`</sub>             | <sub>Reclaim policy for the PVC</sub>                                                                                                                                       | <sub>`Delete`</sub>                           |
| <sub>`saleor.persistence.storageClass`</sub>                              | <sub>Set to the storage class to be used, usually depends on the cluster infrastructure</sub>                                                                               | <sub>`None`</sub>                             |
| <sub>`saleor.persistence.existingPvc`</sub>                               | <sub>Whether to use an existing PVC with a different name</sub>                                                                                                             | <sub>`None`</sub>                             |
| <sub>`saleor.jobs.init.migrations.enabled`</sub>                          | <sub>Whether to run saleor default migrations</sub>                                                                                                                         | <sub>`true`</sub>                             |
| <sub>`saleor.jobs.init.migrations.activeDeadlineSeconds`</sub>            | <sub>How many seconds for the job to be active before automatic shutdown</sub>                                                                                              | <sub>`300`</sub>                              |
| <sub>`saleor.jobs.init.migrations.backOffLimit`</sub>                     | <sub>How many times to attempt the migrations if a failure occurs</sub>                                                                                                     | <sub>`5`</sub>                                |
| <sub>`saleor.jobs.init.migrations.ttlSecondsAfterFinished`</sub>          | <sub>How long in seconds before the job is cleaned up after successful job completion</sub>                                                                                 | <sub>`240`</sub>                              |
| <sub>`saleor.jobs.init.migrations.weight`</sub>                           | <sub>The level of priority for the migration job (lower numbers have higher precedence)</sub>                                                                               | <sub>`1`</sub>                                |
| <sub>`saleor.jobs.init.prePopulateDemo.enabled`</sub>                     | <sub>Whether to run saleor populateDB demos scripts. Will persist sample data and media</sub>                                                                               | <sub>`true`</sub>                             |
| <sub>`saleor.jobs.init.prePopulateDemo.activeDeadlineSeconds`</sub>       | <sub>How many seconds for the job to be active before automatic shutdown</sub>                                                                                              | <sub>`300`</sub>                              |
| <sub>`saleor.jobs.init.prePopulateDemo.backOffLimit`</sub>                | <sub>How many times to attempt the data population if a failure occurs</sub>                                                                                                | <sub>`5`</sub>                                |
| <sub>`saleor.jobs.init.prePopulateDemo.ttlSecondsAfterFinished`</sub>     | <sub>How long in seconds before the job is cleaned up after successful job completion</sub>                                                                                 | <sub>`240`</sub>                              |
| <sub>`saleor.jobs.init.prePopulateDemo.weight`</sub>                      | <sub>The level of priority for the pre-populate demo job (lower numbers have higher precedence)</sub>                                                                       | <sub>`2`</sub>                                |
| <sub>`saleor.jobs.init.createUsers.enabled`</sub>                         | <sub>Whether to create pre-defined users for this installation</sub>                                                                                                        | <sub>`true`</sub>                             |
| <sub>`saleor.jobs.init.createUsers.activeDeadlineSeconds`</sub>           | <sub>How many seconds for the job to be active before automatic shutdown</sub>                                                                                              | <sub>`300`</sub>                              |
| <sub>`saleor.jobs.init.createUsers.backOffLimit`</sub>                    | <sub>How many times to attempt the create users if a failure occurs</sub>                                                                                                   | <sub>`5`</sub>                                |
| <sub>`saleor.jobs.init.createUsers.ttlSecondsAfterFinished`</sub>         | <sub>How long in seconds before the job is cleaned up after successful job completion</sub>                                                                                 | <sub>`240`</sub>                              |
| <sub>`saleor.jobs.init.createUsers.weight`</sub>                          | <sub>The level of priority for the create users job (lower numbers have higher precedence)</sub>                                                                            | <sub>`3`</sub>                                |
| <sub>`saleor.jobs.init.createUsers.users`</sub>                           | <sub>A list of users identified by email address to be added to the saleor installation</sub>                                                                               | <sub>See `values.yaml`</sub>                  |
| <sub>`saleor.jobs.init.currencyUpdates.enabled`</sub>                     | <sub>Whether to run currency updates job</sub>                                                                                                                              | <sub>`true`</sub>                             |
| <sub>`saleor.jobs.init.currencyUpdates.activeDeadlineSeconds`</sub>       | <sub>How many seconds for the job to be active before automatic shutdown</sub>                                                                                              | <sub>`300`</sub>                              |
| <sub>`saleor.jobs.init.currencyUpdates.backOffLimit`</sub>                | <sub>How many times to attempt the currency updates if a failure occurs</sub>                                                                                               | <sub>`5`</sub>                                |
| <sub>`saleor.jobs.init.currencyUpdates.ttlSecondsAfterFinished`</sub>     | <sub>How long in seconds before the job is cleaned up after successful job completion</sub>                                                                                 | <sub>`240`</sub>                              |
| <sub>`saleor.jobs.init.currencyUpdates.weight`</sub>                      | <sub>The level of priority for the currency updates job (lower numbers have higher precedence)</sub>                                                                        | <sub>`4`</sub>                                |
| <sub>`saleor.jobs.init.vatUpdates.enabled`</sub>                          | <sub>Whether to run vat updates</sub>                                                                                                                                       | <sub>`true`</sub>                             |
| <sub>`saleor.jobs.init.vatUpdates.activeDeadlineSeconds`</sub>            | <sub>How many seconds for the job to be active before automatic shutdown</sub>                                                                                              | <sub>`300`</sub>                              |
| <sub>`saleor.jobs.init.vatUpdates.backOffLimit`</sub>                     | <sub>How many times to attempt the vat updates if a failure occurs</sub>                                                                                                    | <sub>`5`</sub>                                |
| <sub>`saleor.jobs.init.vatUpdates.ttlSecondsAfterFinished`</sub>          | <sub>How long in seconds before the job is cleaned up after successful job completion</sub>                                                                                 | <sub>`240`</sub>                              |
| <sub>`saleor.jobs.init.vatUpdates.weight`</sub>                           | <sub>The level of priority for the vat updates job (lower numbers have higher precedence)</sub>                                                                             | <sub>`5`</sub>                                |
| <sub>`saleor.jobs.init.nginx.activeDeadlineSeconds`</sub>                 | <sub>How many seconds for the nginx job to be active before automatic shutdown</sub>                                                                                        | <sub>`300`</sub>                              |
| <sub>`saleor.jobs.init.nginx.backOffLimit`</sub>                          | <sub>How many times to attempt the nginx job if a failure occurs</sub>                                                                                                      | <sub>`5`</sub>                                |
| <sub>`saleor.jobs.init.nginx.ttlSecondsAfterFinished`</sub>               | <sub>How long in seconds before the job is cleaned up after successful job completion</sub>                                                                                 | <sub>`240`</sub>                              |
| <sub>`saleor.jobs.init.nginx.weight`</sub>                                | <sub>The level of priority for the nginx job (lower numbers have higher precedence)</sub>                                                                                   | <sub>`6`</sub>                                |
| <sub>`saleor.jobs.cron.currencyUpdates.enabled`</sub>                     | <sub>Whether to run currency updates as a cronjob</sub>                                                                                                                     | <sub>`true`</sub>                             |
| <sub>`saleor.jobs.cron.currencyUpdates.cron`</sub>                        | <sub>The cron tab defining frequency to run the job, defaults to daily</sub>                                                                                                | <sub>`"0 6 * * *"`</sub>                      |
| <sub>`saleor.jobs.cron.vatUpdates.enabled`</sub>                          | <sub>Whether to run vat updates as a cronjob</sub>                                                                                                                          | <sub>`true`</sub>                             |
| <sub>`saleor.jobs.cron.vatUpdates.cron`</sub>                             | <sub>The cron tab defining frequency to run the job, defaults to daily</sub>                                                                                                | <sub>`"0 7 * * *"`</sub>                      |
| <sub>`saleor.django.alternativeSettingsConfigMap`</sub>                   | <sub>The name of a configmap to override the default configmap with the custom settings.py file</sub>                                                                       | <sub>`None`</sub>                             |
| <sub>`saleor.django.alternativeUwsgiConfigMap`</sub>                      | <sub>The name of a configmap to override the default uwsgi with the custom uwsgi.ini settings</sub>                                                                         | <sub>`None`</sub>                             |
| <sub>`saleor.django.debugMode`</sub>                                      | <sub>Whether to set `DEBUG = False`, a development only configuration option</sub>                                                                                          | <sub>`false`</sub>                            |
| <sub>`saleor.django.settingsModule`</sub>                                 | <sub>The name of the custom settings files</sub>                                                                                                                            | <sub>`saleor.custom-settings`</sub>           |
| <sub>`saleor.django.uwsgi.processes`</sub>                                | <sub>The number of processes running uwsgi</sub>                                                                                                                            | <sub>`2`</sub>                                |
| <sub>`saleor.django.uwsgi.disableLogging`</sub>                           | <sub>Whether to disable uwsgi logging, logging can make a difference to performance</sub>                                                                                   | <sub>`false`</sub>                            |
| <sub>`saleor.django.uwsgi.enableThreads`</sub>                            | <sub>Allow multiple threads in uwsgi</sub>                                                                                                                                  | <sub>`false`</sub>                            |
| <sub>`saleor.django.uwsgi.harakiri`</sub>                                 | <sub>Refer to uswsgi documentation, disabled by default</sub>                                                                                                               | <sub>`0`</sub>                                |
| <sub>`saleor.django.uwsgi.port`</sub>                                     | <sub>Port on which to serve requests</sub>                                                                                                                                  | <sub>`8000`</sub>                             |
| <sub>`saleor.django.uwsgi.logFormat`</sub>                                | <sub>Log format for requests</sub>                                                                                                                                          | <sub>See `values.yaml`</sub>                  |
| <sub>`saleor.django.uwsgi.logXForwardedFor`</sub>                         | <sub>Whether to log the forwarded address instead, useful if using a proxy server or ingress controller</sub>                                                               | <sub>`true`</sub>                             |
| <sub>`saleor.django.uwsgi.logMaxSize`</sub>                               | <sub>Maximum size of the log file</sub>                                                                                                                                     | <sub>`1024`</sub>                             |
| <sub>`saleor.django.uwsgi.muteHealthCheckLogs`</sub>                      | <sub>Stop kubernetes liveness probes from cluttering the logs</sub>                                                                                                         | <sub>`true`</sub>                             |
| <sub>`saleor.django.uwsgi.maxRequests`</sub>                              | <sub>Refer to uwsgi documentation</sub>                                                                                                                                     | <sub>`100`</sub>                              |
| <sub>`saleor.django.uwsgi.numberOfThreads`</sub>                          | <sub>Number of threads, only has effect if `enableThreads` is true</sub>                                                                                                    | <sub>`100`</sub>                              |
| <sub>`saleor.django.uwsgi.maxWorkerLifeTime`</sub>                        | <sub>Refer to uwsgi documentation</sub>                                                                                                                                     | <sub>`None`</sub>                             |
| <sub>`saleor.django.uwsgi.vacuum`</sub>                                   | <sub>Refer to uwsgi documentation</sub>                                                                                                                                     | <sub>`None`</sub>                             |
| <sub>`saleor.django.replicaCount`</sub>                                   | <sub>Number of pods for the saleor application to run when autoscaling is disabled</sub>                                                                                    | <sub>`1`</sub>                                |
| <sub>`saleor.django.autoscaling.enabled`</sub>                            | <sub>Whether to enable autoscaling for the saleor application</sub>                                                                                                         | <sub>`true`</sub>                             |
| <sub>`saleor.django.autoscaling.minReplicaCount`</sub>                    | <sub>The minimum of saleor application replicas to deploy</sub>                                                                                                             | <sub>`1`</sub>                                |
| <sub>`saleor.django.autoscaling.maxReplicaCount`</sub>                    | <sub>The minimum of saleor application replicas to deploy</sub>                                                                                                             | <sub>`8`</sub>                                |
| <sub>`saleor.django.autoscaling.targetCPUUtilizationPercentage`</sub>     | <sub>The amount of CPU utilization before triggering spawning of a new replica</sub>                                                                                        | <sub>`80`</sub>                               |
| <sub>`saleor.django.internalIps`</sub>                                    | <sub>Refer to saleor or django documentation</sub>                                                                                                                          | <sub>`- 127.0.0.1`</sub>                      |
| <sub>`saleor.django.timezone`</sub>                                       | <sub>Refer to saleor or django documentation</sub>                                                                                                                          | <sub>`Etc/UTC`</sub>                          |
| <sub>`saleor.django.languageCode`</sub>                                   | <sub>Refer to saleor or django documentation</sub>                                                                                                                          | <sub>`en`</sub>                               |
| <sub>`saleor.django.internationalization`</sub>                           | <sub>Refer to saleor or django documentation</sub>                                                                                                                          | <sub>`true`</sub>                             |
| <sub>`saleor.django.localization`</sub>                                   | <sub>Refer to saleor or django documentation</sub>                                                                                                                          | <sub>`true`</sub>                             |
| <sub>`saleor.django.ssl.enabled`</sub>                                    | <sub>Whether to enable ssl</sub>                                                                                                                                            | <sub>`false`</sub>                            |
| <sub>`saleor.django.staticUrl`</sub>                                      | <sub>The static assets url</sub>                                                                                                                                            | <sub>`/static/`</sub>                         |
| <sub>`saleor.django.mediaUrl`</sub>                                       | <sub>The media assets url</sub>                                                                                                                                             | <sub>`/media/`</sub>                          |
| <sub>`saleor.django.enableSilk`</sub>                                     | <sub>Refer to saleor or django documentation</sub>                                                                                                                          | <sub>`false`</sub>                            |
| <sub>`saleor.django.defaultCountry`</sub>                                 | <sub>Refer to saleor or django documentation</sub>                                                                                                                          | <sub>`IE`</sub>                               |
| <sub>`saleor.django.defaultCurrency`</sub>                                | <sub>Refer to saleor or django documentation</sub>                                                                                                                          | <sub>`USD`</sub>                              |
| <sub>`saleor.django.availableCurrencies`</sub>                            | <sub>Refer to saleor or django documentation</sub>                                                                                                                          | <sub>See `values.yaml`</sub>                  |
| <sub>`saleor.django.loginRedirectUrl`</sub>                               | <sub>Refer to saleor or django documentation</sub>                                                                                                                          | <sub>`home`</sub>                             |
| <sub>`saleor.django.googleAnalyticsTrackingId`</sub>                      | <sub>Google analytics tracking id, refer to saleor documentation</sub>                                                                                                      | <sub>`None`</sub>                             |
| <sub>`saleor.django.lowStockThreshold`</sub>                              | <sub>The threshold at which a warning about low stock will appear</sub>                                                                                                     | <sub>`10`</sub>                               |
| <sub>`saleor.django.maxCartLineQuantity`</sub>                            | <sub>The maximum of a product that can be added to the cart</sub>                                                                                                           | <sub>`50`</sub>                               |
| <sub>`saleor.django.paginateBy`</sub>                                     | <sub>The number of products per page by default in shopfront</sub>                                                                                                          | <sub>`16`</sub>                               |
| <sub>`saleor.django.dashboardPaginateBy`</sub>                            | <sub>The number of products per page by default in admin dashboard</sub>                                                                                                    | <sub>`30`</sub>                               |
| <sub>`saleor.django.dashboardSearchLimit`</sub>                           | <sub>The search limit for products in the admin dashboard</sub>                                                                                                             | <sub>`5`</sub>                                |
| <sub>`saleor.django.allowedHosts.includeIngressHosts`</sub>               | <sub>Whether to include the hosts in the ingress resource automatically as allowed hosts</sub>                                                                              | <sub>`true`</sub>                             |
| <sub>`saleor.django.allowedHosts.hosts`</sub>                             | <sub>A list of allowed hosts</sub>                                                                                                                                          | <sub>`- localhost - 127.0.0.1`</sub>          |
| <sub>`saleor.django.admins`</sub>                                         | <sub>A list of django admins</sub>                                                                                                                                          | <sub>`[]`</sub>                               |
| <sub>`saleor.django.levels.saleorLogs`</sub>                              | <sub>Refer to the saleor settings.py file</sub>                                                                                                                             | <sub>`DEBUG`</sub>                            |
| <sub>`saleor.django.levels.djangoServerLogs`</sub>                        | <sub>Refer to the saleor settings.py file</sub>                                                                                                                             | <sub>`INFO`</sub>                             |
| <sub>`saleor.django.levels.djangoLogs`</sub>                              | <sub>Refer to the saleor settings.py file</sub>                                                                                                                             | <sub>`INFO`</sub>                             |
| <sub>`saleor.django.levels.rootLogs`</sub>                                | <sub>Refer to the saleor settings.py file</sub>                                                                                                                             | <sub>`DEBUG`</sub>                            |
| <sub>`saleor.django.levels.consoleHandler`</sub>                          | <sub>Refer to the saleor settings.py file</sub>                                                                                                                             | <sub>`DEBUG`</sub>                            |
| <sub>`saleor.django.levels.mailAdminsHandler`</sub>                       | <sub>Refer to the saleor settings.py file</sub>                                                                                                                             | <sub>`ERROR`</sub>                            |
| <sub>`saleor.django.images.placeholders.size_60`</sub>                    | <sub>The file path for the 60x60 placeholder image</sub>                                                                                                                    | <sub>`images/placeholder60x60.png`</sub>      |
| <sub>`saleor.django.images.placeholders.size_120`</sub>                   | <sub>The file path for the 120x120 placeholder image</sub>                                                                                                                  | <sub>`images/placeholder120x120.png`</sub>    |
| <sub>`saleor.django.images.placeholders.size_255`</sub>                   | <sub>The file path for the 255x255 placeholder image</sub>                                                                                                                  | <sub>`images/placeholder255x255.png`</sub>    |
| <sub>`saleor.django.images.placeholders.size_540`</sub>                   | <sub>The file path for the 540x540 placeholder image</sub>                                                                                                                  | <sub>`images/placeholder540x540.png`</sub>    |
| <sub>`saleor.django.images.placeholders.size_1080`</sub>                  | <sub>The file path for the 1080x1080 placeholder image</sub>                                                                                                                | <sub>`images/placeholder1080x1080.png`</sub>  |
| <sub>`saleor.django.images.createOnDemand`</sub>                          | <sub>Generate images on demand. Will not work if `.Values.saleor.nginx.serveMedia: true`</sub>                                                                              | <sub>`false`</sub>                            |
| <sub>`saleor.django.logoutOnPasswordChange`</sub>                         | <sub>Logout automatically is user password is changed</sub>                                                                                                                 | <sub>`false`</sub>                            |
| <sub>`saleor.django.recaptcha`</sub>                                      | <sub>Public key for [google recaptcha](https://developers.google.com/recaptcha/docs/versions)</sub>                                                                         | <sub>`None`</sub>                             |
| <sub>`saleor.django.aws.static.enabled`</sub>                             | <sub>Whether to enable AWS for static assets (TODO)</sub>                                                                                                                   | <sub>`false`</sub>                            |
| <sub>`saleor.django.aws.static.bucketName`</sub>                          | <sub>AWS bucket name for static assets, refer to [aws docs](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html#create-bucket-intro) (TODO)</sub>              | <sub>`None`</sub>                             |
| <sub>`saleor.django.aws.static.customDomain`</sub>                        | <sub>AWS custom domain for static assets, refer to [aws docs](https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html) (TODO)</sub>  | <sub>`None`</sub>                             |
| <sub>`saleor.django.aws.static.location`</sub>                            | <sub>AWS region, refer to [aws docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) (TODO)</sub>                                | <sub>`eu-west-1`</sub>                        |
| <sub>`saleor.django.aws.static.queryStringAuth`</sub>                     | <sub>Refer to [aws docs](https://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html) (TODO)</sub>                                                  | <sub>`false`</sub>                            |
| <sub>`saleor.django.aws.media.enabled`</sub>                              | <sub>Whether to enable AWS for media files (TODO)</sub>                                                                                                                     | <sub>`false`</sub>                            |
| <sub>`saleor.django.aws.media.bucketName`</sub>                           | <sub>AWS bucket name for media files, refer to [aws docs](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html#create-bucket-intro) (TODO)</sub>                | <sub>`None`</sub>                             |
| <sub>`saleor.django.aws.media.customDomain`</sub>                         | <sub>AWS custom domain for media files, refer to [aws docs](https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html) (TODO)</sub>    | <sub>`None`</sub>                             |
| <sub>`saleor.django.aws.media.location`</sub>                             | <sub>AWS region, refer to [aws docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) (TODO)</sub>                                | <sub>`eu-west-1`</sub>                        |
| <sub>`saleor.django.aws.media.queryStringAuth`</sub>                      | <sub>Refer to [aws docs](https://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html) (TODO)</sub>                                                  | <sub>`false`</sub>                            |
| <sub>`saleor.django.email.defaultFromEmail`</sub>                         | <sub>Default sender email address</sub>                                                                                                                                     | <sub>`saleor@saleor.local`</sub>              |
| <sub>`saleor.django.email.orderFromEmail`</sub>                           | <sub>Default orders sender email address, if unset defaults to defaultFromEmail</sub>                                                                                       | <sub>`None`</sub>                             |
| <sub>`saleor.django.email.smtpSettings.generic.enabled`</sub>             | <sub>Whether to enable a generic email provider</sub>                                                                                                                       | <sub>`false`</sub>                            |
| <sub>`saleor.django.email.smtpSettings.password`</sub>                    | <sub>The password to the email provider</sub>                                                                                                                               | <sub>`None`</sub>                             |
| <sub>`saleor.django.email.smtpSettings.generic.loginName`</sub>           | <sub>The smtp login name, ref `smtp://[loginName]@[customDomainName]:[password]@[providerDomainName]:[port]/[extraArgs]`</sub>                                              | <sub>`None`</sub>                             |
| <sub>`saleor.django.email.smtpSettings.generic.customDomainName`</sub>    | <sub>The custom domain name for sending email, eg `saleor.example.com` ref `smtp://[loginName]@[customDomainName]:[password]@[providerDomainName]:[port]/[extraArgs]`</sub> | <sub>`None`</sub>                             |
| <sub>`saleor.django.email.smtpSettings.generic.providerDomainName`</sub>  | <sub>The provider domain name for sending email, eg `smtp.mailgun.org` ref `smtp://[loginName]@[customDomainName]:[password]@[providerDomainName]:[port]/[extraArgs]`</sub> | <sub>`None`</sub>                             |
| <sub>`saleor.django.email.smtpSettings.generic.port`</sub>                | <sub>The provider port for sending email, ref `smtp://[loginName]@[customDomainName]:[password]@[providerDomainName]:[port]/[extraArgs]`</sub>                              | <sub>`465`</sub>                              |
| <sub>`saleor.django.email.smtpSettings.generic.extraArgs`</sub>           | <sub>Any extra arguments on the smtp url, ref `smtp://[loginName]@[customDomainName]:[password]@[providerDomainName]:[port]/[extraArgs]`</sub>                              | <sub>`?ssl=True`</sub>                        |
| <sub>`saleor.django.email.smtpSettings.mailjet.enabled`</sub>             | <sub>Whether to enable mailjet for sending email</sub>                                                                                                                      | <sub>`false`</sub>                            |
| <sub>`saleor.django.email.smtpSettings.mailjet.username`</sub>            | <sub>Mailjet username</sub>                                                                                                                                                 | <sub>`None`</sub>                             |
| <sub>`saleor.django.email.smtpSettings.amazonSES.enabled`</sub>           | <sub>Whether to enable amazon SES for sending email</sub>                                                                                                                   | <sub>`false`</sub>                            |
| <sub>`saleor.django.email.smtpSettings.amazonSES.username`</sub>          | <sub>Amazon SES username</sub>                                                                                                                                              | <sub>`None`</sub>                             |
| <sub>`saleor.django.email.smtpSettings.amazonSES.username`</sub>          | <sub>Amazon SES username</sub>                                                                                                                                              | <sub>`None`</sub>                             |
| <sub>`saleor.django.email.smtpSettings.amazonSES.region`</sub>            | <sub>Amazon SES region</sub>                                                                                                                                                | <sub>`eu-west-1`</sub>                        |
| <sub>`saleor.django.openExchangesApiKey`</sub>                            | <sub>The API key to communicate with the open exchanges api</sub>                                                                                                           | <sub>`None`</sub>                             |
| <sub>`saleor.django.secretKey`</sub>                                      | <sub>The django encryption secret key</sub>                                                                                                                                 | <sub>`None`</sub>                             |
| <sub>`saleor.django.vatLayerApiKey`</sub>                                 | <sub>The vatlayer api key</sub>                                                                                                                                             | <sub>`None`</sub>                             |
| <sub>`saleor.django.vatLayerApiKey`</sub>                                 | <sub>The vatlayer api key</sub>                                                                                                                                             | <sub>`None`</sub>                             |
| <sub>`saleor.django.externalServices.redis.password`</sub>                | <sub>The password to an external redis database</sub>                                                                                                                       | <sub>`None`</sub>                             |
| <sub>`saleor.django.externalServices.redis.host`</sub>                    | <sub>The host to an external redis database</sub>                                                                                                                           | <sub>`None`</sub>                             |
| <sub>`saleor.django.externalServices.redis.tls`</sub>                     | <sub>Whether to use SSL to an external redis database</sub>                                                                                                                 | <sub>`true`</sub>                             |
| <sub>`saleor.django.externalServices.redis.port`</sub>                    | <sub>The port to an external redis database</sub>                                                                                                                           | <sub>`6379`</sub>                             |
| <sub>`saleor.django.externalServices.redis.dbNumber`</sub>                | <sub>The db number to an external redis database</sub>                                                                                                                      | <sub>`0`</sub>                                |
| <sub>`saleor.django.externalServices.redis.celeryBrokerDbNumber`</sub>    | <sub>The celery broken db number to an external redis database</sub>                                                                                                        | <sub>`1`</sub>                                |
| <sub>`saleor.django.externalServices.postgresql.password`</sub>           | <sub>The password to an external postgresql database</sub>                                                                                                                  | <sub>`None`</sub>                             |
| <sub>`saleor.django.externalServices.postgresql.user`</sub>               | <sub>The user for the external postgresql database</sub>                                                                                                                    | <sub>`None`</sub>                             |
| <sub>`saleor.django.externalServices.postgresql.host`</sub>               | <sub>The host for the external postgresql database</sub>                                                                                                                    | <sub>`None`</sub>                             |
| <sub>`saleor.django.externalServices.postgresql.port`</sub>               | <sub>The port for the external postgresql database</sub>                                                                                                                    | <sub>`5432`</sub>                             |
| <sub>`saleor.django.externalServices.postgresql.database`</sub>           | <sub>The database name for the external postgresql database</sub>                                                                                                           | <sub>`saleor`</sub>                           |
| <sub>`saleor.django.externalServices.postgresql.requireSSL`</sub>         | <sub>Whether to force the usage of SSL for the external postgresql database</sub>                                                                                           | <sub>`true`</sub>                             |
| <sub>`saleor.django.externalServices.elasticsearch.enabled`</sub>         | <sub>Whether to enable elasticsearch as an external service. Elasticsearch is an optional saleor component.</sub>                                                           | <sub>`false`</sub>                            |
| <sub>`saleor.django.externalServices.elasticsearch.password`</sub>        | <sub>The password to an external elasticsearch database</sub>                                                                                                               | <sub>`None`</sub>                             |
| <sub>`saleor.django.externalServices.elasticsearch.user`</sub>            | <sub>The user for the external elasticsearch database</sub>                                                                                                                 | <sub>`None`</sub>                             |
| <sub>`saleor.django.externalServices.elasticsearch.host`</sub>            | <sub>The host for the external elasticsearch database</sub>                                                                                                                 | <sub>`None`</sub>                             |
| <sub>`saleor.django.externalServices.elasticsearch.port`</sub>            | <sub>The host for the external elasticsearch database</sub>                                                                                                                 | <sub>`9200`</sub>                             |
| <sub>`saleor.django.externalServices.elasticsearch.tls`</sub>             | <sub>Whether to use https instead of http to communicate with the external elasticsearch database</sub>                                                                     | <sub>`true`</sub>                             |
| <sub>`saleor.django.externalServices.sentry.enabled`</sub>                | <sub>Whether to use an external sentry application</sub>                                                                                                                    | <sub>`false`</sub>                            |
| <sub>`saleor.django.externalServices.sentry.dsn`</sub>                    | <sub>The dsn for the external sentry application</sub>                                                                                                                      | <sub>`false`</sub>                            |
| <sub>`saleor.django.payments.braintree.enabled`</sub>                     | <sub>Enable braintree payments</sub>                                                                                                                                        | <sub>`false`</sub>                            |
| <sub>`saleor.django.payments.braintree.sandboxMode`</sub>                 | <sub>Use braintree sandbox mode</sub>                                                                                                                                       | <sub>`true`</sub>                             |
| <sub>`saleor.django.payments.braintree.merchantId`</sub>                  | <sub>Braintree merchant id</sub>                                                                                                                                            | <sub>`None`</sub>                             |
| <sub>`saleor.django.payments.braintree.publicId`</sub>                    | <sub>Braintree public id</sub>                                                                                                                                              | <sub>`None`</sub>                             |
| <sub>`saleor.django.payments.braintree.privateId`</sub>                   | <sub>Braintree private id. Warning ! Leave this empty and set with secret !</sub>                                                                                           | <sub>`None`</sub>                             |
| <sub>`saleor.django.payments.dummy.enabled`</sub>                         | <sub>Enable dummy payments method - for testing/demo purposes</sub>                                                                                                         | <sub>`true`</sub>                             |
| <sub>`saleor.django.payments.razorpay.enabled`</sub>                      | <sub>Enable razorpay payments</sub>                                                                                                                                         | <sub>`false`</sub>                            |
| <sub>`saleor.django.payments.razorpay.prefill`</sub>                      | <sub>Prefill user form data in checkout</sub>                                                                                                                               | <sub>`false`</sub>                            |
| <sub>`saleor.django.payments.razorpay.storeName`</sub>                    | <sub>Name of your store</sub>                                                                                                                                               | <sub>`None`</sub>                             |
| <sub>`saleor.django.payments.razorpay.storeLogo`</sub>                    | <sub>Url link to your store logo image</sub>                                                                                                                                | <sub>`None`</sub>                             |
| <sub>`saleor.django.payments.razorpay.publicKey`</sub>                    | <sub>Razorpay public id</sub>                                                                                                                                               | <sub>`None`</sub>                             |
| <sub>`saleor.django.payments.razorpay.secretKey`</sub>                    | <sub>Razorpay secret key. Warning ! Leave this empty and set with secret !</sub>                                                                                            | <sub>`None`</sub>                             |
| <sub>`saleor.django.payments.stripe.enabled`</sub>                        | <sub>Enable stripe payments</sub>                                                                                                                                           | <sub>`false`</sub>                            |
| <sub>`saleor.django.payments.stripe.prefill`</sub>                        | <sub>Prefill user form data in checkout</sub>                                                                                                                               | <sub>`false`</sub>                            |
| <sub>`saleor.django.payments.stripe.storeName`</sub>                      | <sub>Name of your store</sub>                                                                                                                                               | <sub>`None`</sub>                             |
| <sub>`saleor.django.payments.stripe.storeLogo`</sub>                      | <sub>Url link to your store logo image</sub>                                                                                                                                | <sub>`None`</sub>                             |
| <sub>`saleor.django.payments.stripe.rememberMe`</sub>                     | <sub>Remember users for future purchases</sub>                                                                                                                              | <sub>`true`</sub>                             |
| <sub>`saleor.django.payments.stripe.locale`</sub>                         | <sub>The language for the checkout form</sub>                                                                                                                               | <sub>`auto`</sub>                             |
| <sub>`saleor.django.payments.stripe.billingAddress`</sub>                 | <sub>Whether to ask for a billing address</sub>                                                                                                                             | <sub>`false`</sub>                            |
| <sub>`saleor.django.payments.stripe.shippingAddress`</sub>                | <sub>Whether to ask for a shipping address</sub>                                                                                                                            | <sub>`false`</sub>                            |
| <sub>`saleor.django.payments.stripe.publicKey`</sub>                      | <sub>Stripe public id</sub>                                                                                                                                                 | <sub>`None`</sub>                             |
| <sub>`saleor.django.payments.stripe.secretKey`</sub>                      | <sub>Stripe secret key. Warning ! Leave this empty and set with secret !</sub>                                                                                              | <sub>`None`</sub>                             |
| <sub>`saleor.django.tokens.jwt.expires`</sub>                             | <sub>Whether the django jwt tokens should expire</sub>                                                                                                                      | <sub>`true`</sub>                             |
| <sub>`saleor.django.livenessProbeSettings.initialDelaySeconds`</sub>      | <sub>Saleor pod liveness probe initialDelaySeconds</sub>                                                                                                                    | <sub>`60`</sub>                               |
| <sub>`saleor.django.livenessProbeSettings.periodSeconds`</sub>            | <sub>Saleor pod liveness probe periodSeconds</sub>                                                                                                                          | <sub>`15`</sub>                               |
| <sub>`saleor.django.livenessProbeSettings.failureThreshold`</sub>         | <sub>Saleor pod liveness probe failureThreshold</sub>                                                                                                                       | <sub>`5`</sub>                                |
| <sub>`saleor.django.livenessProbeSettings.successThreshold`</sub>         | <sub>Saleor pod liveness probe successThreshold</sub>                                                                                                                       | <sub>`1`</sub>                                |
| <sub>`saleor.django.livenessProbeSettings.timeoutSeconds`</sub>           | <sub>Saleor pod liveness probe timeoutSeconds</sub>                                                                                                                         | <sub>`1`</sub>                                |
| <sub>`saleor.django.readinessProbeSettings.initialDelaySeconds`</sub>     | <sub>Saleor pod liveness probe initialDelaySeconds</sub>                                                                                                                    | <sub>`30`</sub>                               |
| <sub>`saleor.django.readinessProbeSettings.periodSeconds`</sub>           | <sub>Saleor pod liveness probe periodSeconds</sub>                                                                                                                          | <sub>`5`</sub>                                |
| <sub>`saleor.django.readinessProbeSettings.failureThreshold`</sub>        | <sub>Saleor pod liveness probe failureThreshold</sub>                                                                                                                       | <sub>`5`</sub>                                |
| <sub>`saleor.django.readinessProbeSettings.successThreshold`</sub>        | <sub>Saleor pod liveness probe successThreshold</sub>                                                                                                                       | <sub>`1`</sub>                                |
| <sub>`saleor.django.readinessProbeSettings.timeoutSeconds`</sub>          | <sub>Saleor pod liveness probe timeoutSeconds</sub>                                                                                                                         | <sub>`1`</sub>                                |
| <sub>`saleor.django.resources.requests.cpu`</sub>                         | <sub>Minimum cpu resources required for a saleor pod</sub>                                                                                                                  | <sub>`500m`</sub>                             |
| <sub>`saleor.django.resources.requests.memory`</sub>                      | <sub>Minimum memory resources required for a saleor pod</sub>                                                                                                               | <sub>`512Mi`</sub>                            |
| <sub>`saleor.django.resources.limits.cpu`</sub>                           | <sub>Maximum cpu resources allowed for a saleor pod</sub>                                                                                                                   | <sub>`1000m`</sub>                            |
| <sub>`saleor.django.resources.limits.memory`</sub>                        | <sub>Maximum memory resources allowed for a saleor pod</sub>                                                                                                                | <sub>`1Gi`</sub>                              |
| <sub>`saleor.django.nodeSelector`</sub>                                   | <sub>Refer to kubernetes documentation</sub>                                                                                                                                | <sub>`{}`</sub>                               |
| <sub>`saleor.django.tolerations`</sub>                                    | <sub>Refer to kubernetes documentation</sub>                                                                                                                                | <sub>`[]`</sub>                               |
| <sub>`saleor.django.affinity`</sub>                                       | <sub>Refer to kubernetes documentation</sub>                                                                                                                                | <sub>`{}`</sub>                               |
| <sub>`saleor.celery.replicaCount`</sub>                                   | <sub>The number of celery worker pods to spawn when autoscaling is `false`</sub>                                                                                            | <sub>`1`</sub>                                |
| <sub>`saleor.celery.autoscaling.enabled`</sub>                            | <sub>Whether to use horizontal pod autoscaling by default or not</sub>                                                                                                      | <sub>`true`</sub>                             |
| <sub>`saleor.celery.autoscaling.minReplicaCount`</sub>                    | <sub>The minimum number of celery workers when using horizontal pod autoscaling</sub>                                                                                       | <sub>`1`</sub>                                |
| <sub>`saleor.celery.autoscaling.targetCPUUtilizationPercentage`</sub>     | <sub>The target percentage usage of cpu</sub>                                                                                                                               | <sub>`80`</sub>                               |
| <sub>`saleor.celery.concurrencyType`</sub>                                | <sub>This attribute specifies the type of concurrency for celery to use. Celery has builtin concurrency feature distinct from kubernetes horizontal pod autoscaling</sub>   | <sub>`auto`</sub>                             |
| <sub>`saleor.celery.fixedConcurrency`</sub>                               | <sub>Where fixed celery concurrency is used, specify the number of processes. Only has effect if `concurrencyType: fixed`</sub>                                             | <sub>`4`</sub>                                |
| <sub>`saleor.celery.maxConcurrency`</sub>                                 | <sub>Where automatic celery concurrency is used, specify the minimum number of processes. Only has effect if `concurrencyType: auto`</sub>                                  | <sub>`2`</sub>                                |
| <sub>`saleor.celery.maxConcurrency`</sub>                                 | <sub>Where automatic celery concurrency is used, specify the maximum number of processes. Only has effect if `concurrencyType: auto`</sub>                                  | <sub>`6`</sub>                                |
| <sub>`saleor.celery.heartBeatIntervalSeconds`</sub>                       | <sub>Refer to celery documentation</sub>                                                                                                                                    | <sub>`10`</sub>                               |
| <sub>`saleor.celery.softTimeLimitSeconds`</sub>                           | <sub>Refer to celery documentation</sub>                                                                                                                                    | <sub>`None`</sub>                             |
| <sub>`saleor.celery.hardTimeLimitSeconds`</sub>                           | <sub>Refer to celery documentation</sub>                                                                                                                                    | <sub>`None`</sub>                             |
| <sub>`saleor.celery.logLevel`</sub>                                       | <sub>Log level for celery</sub>                                                                                                                                             | <sub>`INFO`</sub>                             |
| <sub>`saleor.celery.taskEventsMonitoringEnabled`</sub>                    | <sub>Refer to celery documentation</sub>                                                                                                                                    | <sub>`true`</sub>                             |
| <sub>`saleor.celery.livenessProbeSettings.initialDelaySeconds`</sub>      | <sub>Celery pod liveness probe initialDelaySeconds</sub>                                                                                                                    | <sub>`60`</sub>                               |
| <sub>`saleor.celery.livenessProbeSettings.periodSeconds`</sub>            | <sub>Celery pod liveness probe periodSeconds</sub>                                                                                                                          | <sub>`30`</sub>                               |
| <sub>`saleor.celery.livenessProbeSettings.failureThreshold`</sub>         | <sub>Celery pod liveness probe failureThreshold</sub>                                                                                                                       | <sub>`3`</sub>                                |
| <sub>`saleor.celery.livenessProbeSettings.successThreshold`</sub>         | <sub>Celery pod liveness probe successThreshold</sub>                                                                                                                       | <sub>`1`</sub>                                |
| <sub>`saleor.celery.livenessProbeSettings.timeoutSeconds`</sub>           | <sub>Celery pod liveness probe timeoutSeconds</sub>                                                                                                                         | <sub>`12`</sub>                               |
| <sub>`saleor.celery.readinessProbeSettings.initialDelaySeconds`</sub>     | <sub>Celery pod liveness probe initialDelaySeconds</sub>                                                                                                                    | <sub>`60`</sub>                               |
| <sub>`saleor.celery.readinessProbeSettings.periodSeconds`</sub>           | <sub>Celery pod liveness probe periodSeconds</sub>                                                                                                                          | <sub>`15`</sub>                               |
| <sub>`saleor.celery.readinessProbeSettings.failureThreshold`</sub>        | <sub>Celery pod liveness probe failureThreshold</sub>                                                                                                                       | <sub>`3`</sub>                                |
| <sub>`saleor.celery.readinessProbeSettings.successThreshold`</sub>        | <sub>Celery pod liveness probe successThreshold</sub>                                                                                                                       | <sub>`1`</sub>                                |
| <sub>`saleor.celery.readinessProbeSettings.timeoutSeconds`</sub>          | <sub>Celery pod liveness probe timeoutSeconds</sub>                                                                                                                         | <sub>`12`</sub>                               |
| <sub>`saleor.celery.resources.requests.cpu`</sub>                         | <sub>Minimum cpu resources required for a celery pod</sub>                                                                                                                  | <sub>`500m`</sub>                             |
| <sub>`saleor.celery.resources.requests.memory`</sub>                      | <sub>Minimum memory resources required for a celery pod</sub>                                                                                                               | <sub>`256Mi`</sub>                            |
| <sub>`saleor.celery.resources.limits.cpu`</sub>                           | <sub>Maximum cpu resources allowed for a celery pod</sub>                                                                                                                   | <sub>`1000m`</sub>                            |
| <sub>`saleor.celery.resources.limits.memory`</sub>                        | <sub>Maximum memory resources allowed for a celery pod</sub>                                                                                                                | <sub>`1Gi`</sub>                              |
| <sub>`saleor.celery.nodeSelector`</sub>                                   | <sub>Refer to kubernetes documentation</sub>                                                                                                                                | <sub>`{}`</sub>                               |
| <sub>`saleor.celery.tolerations`</sub>                                    | <sub>Refer to kubernetes documentation</sub>                                                                                                                                | <sub>`[]`</sub>                               |
| <sub>`saleor.celery.affinity`</sub>                                       | <sub>Refer to kubernetes documentation</sub>                                                                                                                                | <sub>`{}`</sub>                               |
| <sub>`saleor.nginx.replicaCount`</sub>                                    | <sub>The number of nginx pods to spawn if autoscaling is set to `false`</sub>                                                                                               | <sub>`1`</sub>                                |
| <sub>`saleor.nginx.autoscaling.enabled`</sub>                             | <sub>Whether to enable autoscaling for the nginx pods. Unlikely to be needed.</sub>                                                                                         | <sub>`true`</sub>                             |
| <sub>`saleor.nginx.autoscaling.minReplicaCount`</sub>                     | <sub>The minimum number of nginx pods when autoscaling is enabled</sub>                                                                                                     | <sub>`1`</sub>                                |
| <sub>`saleor.nginx.autoscaling.maxReplicaCount`</sub>                     | <sub>The maximum number of nginx pods when autoscaling is enabled</sub>                                                                                                     | <sub>`2`</sub>                                |
| <sub>`saleor.nginx.autoscaling.targetCPUUtilizationPercentage`</sub>      | <sub>The target percentage usage of cpu</sub>                                                                                                                               | <sub>`80`</sub>                               |
| <sub>`saleor.nginx.serveMedia.enabled`</sub>                              | <sub>Whether nginx should serve media files</sub>                                                                                                                           | <sub>`true`</sub>                             |
| <sub>`saleor.nginx.image.repository`</sub>                                | <sub>The nginx image repository</sub>                                                                                                                                       | <sub>`nginxinc/nginx-unprivileged`</sub>      |
| <sub>`saleor.nginx.image.tag`</sub>                                       | <sub>The nginx image version</sub>                                                                                                                                          | <sub>`1.15.5-alpine`</sub>                    |
| <sub>`saleor.nginx.image.pullPolicy`</sub>                                | <sub>The nginx image pullPolicy</sub>                                                                                                                                       | <sub>`IfNotPresent`</sub>                     |
| <sub>`saleor.nginx.image.pullSecret`</sub>                                | <sub>The nginx image pullSecret</sub>                                                                                                                                       | <sub>`None`</sub>                             |
| <sub>`saleor.nginx.image.containerPort`</sub>                             | <sub>The nginx container port</sub>                                                                                                                                         | <sub>`8080`</sub>                             |
| <sub>`saleor.nginx.livenessProbeSettings.initialDelaySeconds`</sub>       | <sub>Nginx pod liveness probe initialDelaySeconds</sub>                                                                                                                     | <sub>`60`</sub>                               |
| <sub>`saleor.nginx.livenessProbeSettings.periodSeconds`</sub>             | <sub>Nginx pod liveness probe periodSeconds</sub>                                                                                                                           | <sub>`15`</sub>                               |
| <sub>`saleor.nginx.livenessProbeSettings.failureThreshold`</sub>          | <sub>Nginx pod liveness probe failureThreshold</sub>                                                                                                                        | <sub>`5`</sub>                                |
| <sub>`saleor.nginx.livenessProbeSettings.successThreshold`</sub>          | <sub>Nginx pod liveness probe successThreshold</sub>                                                                                                                        | <sub>`1`</sub>                                |
| <sub>`saleor.nginx.livenessProbeSettings.timeoutSeconds`</sub>            | <sub>Nginx pod liveness probe timeoutSeconds</sub>                                                                                                                          | <sub>`1`</sub>                                |
| <sub>`saleor.nginx.readinessProbeSettings.initialDelaySeconds`</sub>      | <sub>Nginx pod liveness probe initialDelaySeconds</sub>                                                                                                                     | <sub>`15`</sub>                               |
| <sub>`saleor.nginx.readinessProbeSettings.periodSeconds`</sub>            | <sub>Nginx pod liveness probe periodSeconds</sub>                                                                                                                           | <sub>`5`</sub>                                |
| <sub>`saleor.nginx.readinessProbeSettings.failureThreshold`</sub>         | <sub>Nginx pod liveness probe failureThreshold</sub>                                                                                                                        | <sub>`5`</sub>                                |
| <sub>`saleor.nginx.readinessProbeSettings.successThreshold`</sub>         | <sub>Nginx pod liveness probe successThreshold</sub>                                                                                                                        | <sub>`1`</sub>                                |
| <sub>`saleor.nginx.readinessProbeSettings.timeoutSeconds`</sub>           | <sub>Nginx pod liveness probe timeoutSeconds</sub>                                                                                                                          | <sub>`1`</sub>                                |
| <sub>`saleor.nginx.config.workerProcesses`</sub>                          | <sub>The number of nginx worker processes</sub>                                                                                                                             | <sub>`2`</sub>                                |
| <sub>`saleor.nginx.config.workerConnections`</sub>                        | <sub>The max number of nginx worker connections</sub>                                                                                                                       | <sub>`1024`</sub>                             |
| <sub>`saleor.nginx.config.accessLogs.enabled`</sub>                       | <sub>Whether to enable logging of nginx access logs</sub>                                                                                                                   | <sub>`true`</sub>                             |
| <sub>`saleor.nginx.config.accessLogs.muteHealthChecks`</sub>              | <sub>Whether to filter the kubernetes liveness and readiness probe logs out of the access logs thereby reducing logs clutter</sub>                                          | <sub>`true`</sub>                             |
| <sub>`saleor.nginx.config.errorLogs.enabled`</sub>                        | <sub>Whether to enable nginx error logs</sub>                                                                                                                               | <sub>`true`</sub>                             |
| <sub>`saleor.nginx.config.errorLogs.logFormat`</sub>                      | <sub>The level above which nginx errors logs will be logged</sub>                                                                                                           | <sub>See `values.yaml`</sub>                  |
| <sub>`saleor.nginx.resources.requests.cpu`</sub>                          | <sub>Minimum cpu resources required for a nginx pod</sub>                                                                                                                   | <sub>`500m`</sub>                             |
| <sub>`saleor.nginx.resources.requests.memory`</sub>                       | <sub>Minimum memory resources required for a nginx pod</sub>                                                                                                                | <sub>`512Mi`</sub>                            |
| <sub>`saleor.nginx.resources.limits.cpu`</sub>                            | <sub>Maximum cpu resources allowed for a nginx pod</sub>                                                                                                                    | <sub>`1000m`</sub>                            |
| <sub>`saleor.nginx.resources.limits.memory`</sub>                         | <sub>Maximum memory resources allowed for a nginx pod</sub>                                                                                                                 | <sub>`1Gi`</sub>                              |
| <sub>`saleor.nginx.nodeSelector`</sub>                                    | <sub>Refer to kubernetes documentation</sub>                                                                                                                                | <sub>`{}`</sub>                               |
| <sub>`saleor.nginx.tolerations`</sub>                                     | <sub>Refer to kubernetes documentation</sub>                                                                                                                                | <sub>`[]`</sub>                               |
| <sub>`saleor.nginx.affinity`</sub>                                        | <sub>Refer to kubernetes documentation</sub>                                                                                                                                | <sub>`{}`</sub>                               |

<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

Configuration of the subcharts:

| Parameter                 | Description                                          | Default    | Further reference                                                                           |
| ------------------------- | ---------------------------------------------------- | ---------- | ------------------------------------------------------------------------------------------- |
| `postgresql.enabled`      | Enable in-cluster deployment of postgresql           | `true`     | [helm postgresql chart](https://github.com/helm/charts/tree/master/stable/postgresql)       |
| `redis.enabled`           | Enable in-cluster deployment of redis                | `true`     | [helm redis chart](https://github.com/helm/charts/tree/master/stable/redis)                 |
| `elasticsearch.enabled`   | Enable in-cluster deployment of elasticsearch        | `true`     | [helm elasticsearch chart](https://github.com/helm/charts/tree/master/stable/elasticsearch) |

<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

### Secrets configuration

In order for the saleor deployment to function properly, the following
secrets should be set as required:

| Secret                             | Chart/secret                  | Description                                                            | Autogeneration Possible    |
| ---------------------------------- | ----------------------------- | ---------------------------------------------------------------------- | -------------------------- |
| `postgresql-replication-password`  | Postgresql/saleor-postgresql  | Replication password for the postgresql database                       | :heavy_check_mark:         |
| `redis-password`                   | Redis/saleor-redis            | Password for the redis database                                        | :heavy_check_mark:         |
| `email-password`                   | Saleor/saleor                 | Password for the sending emails through an smtp provider               | :x:                        |
| `open-exchanges-api-key`           | Saleor/saleor                 | API key to make calls to the open exchanges api                        | :x:                        |
| `saleor-secret-key`                | Saleor/saleor                 | The django secret for the saleor application                           | :heavy_check_mark:         |
| `saleor-user-1-saleor-pass`        | Saleor/saleor                 | A default user password in the user-create job                         | :heavy_check_mark:         |
| `saleor-user-2-example-pass`       | Saleor/saleor                 | A default user password in the user-create job                         | :heavy_check_mark:         |
| `saleor-superuser-1-saleor-pass`   | Saleor/saleor                 | A default superuser password in the user-create job                    | :heavy_check_mark:         |
| `aws-access-key-id`                | Saleor/saleor                 | The aws access key id, required if serving content via s3 (TODO)       | :x:                        |
| `aws-access-key-secret`            | Saleor/saleor                 | The aws access key secret, required if serving content via s3 (TODO)   | :x:                        |
| `ext-redis-pass`                   | Saleor/saleor                 | The password for an external redis database                            | :x:                        |
| `ext-postgresql-pass`              | Saleor/saleor                 | The password for an external redis database                            | :x:                        |
| `ext-elasticsearch-pass`           | Saleor/saleor                 | The password for an external elasticsearch database                    | :x:                        |
| `ext-sentry-dsn`                   | Saleor/saleor                 | The full dsn for the external sentry application                       | :x:                        |
| `braintree-private-key`            | Saleor/saleor                 | The private key for braintree payments integration                     | :x:                        |
| `razorpay-secret-key`              | Saleor/saleor                 | The secret key for razorpay payments integration                       | :x:                        |
| `stripe-secret-key`                | Saleor/saleor                 | The secret key for stripe payments integration                         | :x:                        |

## Chart Repository
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

(TODO)

## Installation

### Default installation
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

#### Step 1 (Default installation)

-   Add the secrets ti the `saleor` secrets file as required.
See [Secrets configuration](#secrets-configuration).

#### Step 2 (Default installation)

For now, a saleor chart archive has not yet been released so the repository needs to be downloaded.

```shell
git clone https://github.com/stephenmoloney/saleor-helm.git --branch=master && cd saleor-helm;
```

#### Step 3 (Default installation)

Install the helm chart
 
-   The `values.yaml` file can be configured as required.
See [Values configuration](#values-configuration)

```shell
helm dependency build ./deployment/saleor && \
helm install --name saleor ./deployment/saleor;
```

### Installation with custom secret
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

#### Step 1 (Installation with custom secret)

-   Create a new secrets file with a unique name (eg `saleor-custom`)
and add the secrets for api keys, etc as required.
See [Secrets configuration](#secrets-configuration).

#### Step 2 (Installation with custom secret)

For now, a saleor chart archive has not yet been released so the repository needs to be downloaded.

```shell
git clone https://github.com/stephenmoloney/saleor-helm.git --branch=master && cd saleor-helm;
```

#### Step 3 (Installation with custom secret)

Install the helm chart
 
-   The `values.yaml` file can be configured as required. See [Values configuration](#values-configuration)

For example, if using an existing secret, create a `values-prod.yaml`

```yaml
saleor:
existingSecret: saleor-custom
redis:
enabled: true
existingSecret: saleor-custom
postgresql:
enabled: true
existingSecret: saleor-custom
```

```shell
helm dependency build ./deployment/saleor && \
helm install --name saleor -f values-prod.yaml ./deployment/saleor;
```

## Upgrades
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

(TODO)

## Maintenance
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

(TODO)

### Backup

(TODO)

<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>

### Restore
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

(TODO)

## Uninstallation
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

```shell
helm delete saleor --purge;
```
