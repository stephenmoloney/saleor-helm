# Saleor helm chart

## Table of Contents 

- [Introduction](#introduction)
    - [What is Saleor ?](#what-is-saleor-)
- [Prerequisites](#prerequisites)
- [Quickstart](#quickstart)
- [Saleor components](#saleor-components)
    - [Cluster components](#cluster-components) 
    - [External components](#external-components)
- [Chart Architecture](#chart-architecture)
- [Chart Configuration](#chart-configuration)
    - [Values Configuration](#values-configuration)
    - [Secrets Configuration](#secrets-configuration)
- [Chart Repository](#chart-repository)
- [Installation](#installation)
    - [Default Installation](#default-installation)
    - [Installation with custom secret](#installation-with-custom-secret)
- [Upgrades](#upgrades)
- [Maintenance](#maintenance)
    - [Backup](#backup)
    - [Restore](#restore)
- [Uninstallation](#uninstallation)
- [Changelog](Changelog.md)

## Introduction

### What is Saleor ?
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

Saleor is a high-performance e-commerce solution created with Python and Django.
 
The traditional saleor MVC technology stack includes:
 
  - Django
  - NodeJs
  - PostgreSQL
  - Redis
  - ElasticSearch
  - Sentry 
  - Docker
  
The SPA saleor storefront technology stack includes:

  - GraphQL
  - ReactJS
  - Typescript
  
Features are describe in more depth on the [saleor README](https://github.com/mirumee/saleor#features)

## Prerequisites
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

- A kubernetes cluster with helm installed
- Persistent volumes available with a storageclass
- Sufficient cpu and memory resources for postgresql, redis, elasticsearch and saleor

*Note:*

- An elasticsearch cluster requires substantial memory resources, it should not be enabled
 unless the cluster has sufficient resources.

```text
elasticsearch:
  enabled: false
```

- The elasticsearch deployment can delay the total startup time, 
it may be necessary to increase the helm timeout if elasticsearch is enabled. 

```
helm install --timeout 900 ... 
```

## Quickstart
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

***Step 1:***

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
```

***Step 2:***

The chart must be downloaded as a chart archive has still not been created:

```bash
git clone https://github.com/stephenmoloney/saleor-helm.git --branch=master && cd saleor-helm;
```

***Step 3:***

Install the helm chart
 
- Modify the `values.yaml` file as required. See [Values configuration](#values-configuration)

  - For example, if using an existing secret, create a `values-prod.yaml`
  ```
  saleor:
    existingSecret: saleor-custom
  redis:
    enabled: true
    existingSecret: saleor-custom
  postgresql:
    enabled: true
    existingSecret: saleor-custom
  ```  

```bash
helm dependency build ./deployment/helm && \
helm install --name saleor -f values-prod.yaml ./deployment/helm;
```

## Saleor components
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

Saleor components could be divided into 2 groups:

- *Cluster components* are those components which can be self-hosted and part of the kubernetes cloud infrastructure
- *External components* are those componenets which are essentially software as a service (SAAS) components and 
are external to the kubernetes cloud infrastructure. They cannot be optionally self-hosted.

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

Saleor takes advantage of a number of external services to enhance functionality
and externalize development efforts for some parts of the application. If integration
with these components is necessary, read further documentation. Changes to `secrets.yaml`
and/or `values.yaml` with the details of your external provider account may be required.

| Service           | Description             | Essential                       |
|------------------ |------------------------ |-------------------------------- |
| Email Provider    | External email providers, eg mailgun, mailjet, sendgrid, amazon ses, etc, see [docs](https://github.com/mirumee/saleor/blob/master/docs/guides/email_integration.rst)         |   :heavy_check_mark:       |
| Google Recaptcha  | Spam mitigation, see [docs](https://github.com/mirumee/saleor/blob/master/docs/guides/recaptcha.rst)         | :x:       |
| Vat Layer API     | Maintaining correct EU vat rates See [docs](https://github.com/mirumee/saleor/blob/master/docs/guides/taxes.rst)    |  :heavy_check_mark:       |
| Open Exchanges API| Maintainance of up-to-date currency exchange rates See open exchanges api [website](https://openexchangerates.org/) | :heavy_check_mark:       |
| Transifex         | A localization helper service, see [docs](https://github.com/mirumee/saleor/blob/master/docs/architecture/i18n.rst) | :x:       |
| Sentry            | An externalized error monitoring tool, see [docs](https://github.com/mirumee/saleor/blob/master/docs/integrations/sentry.rst) | :x:       |
| Google for retail | Tools for generating product feed which can be used with Google Merchant Center, see [docs](https://github.com/mirumee/saleor/blob/master/docs/integrations/googleforretail.rst) | :x:       |
| Google Analytics  | Google analytics integration, see [docs](https://github.com/mirumee/saleor/blob/master/docs/integrations/googleanalytics.rst) | :x:       |
| Schema.org Markup | Schema.org markup for emails, see [docs](https://github.com/mirumee/saleor/blob/master/docs/integrations/emailmarkup.rst) and read [more here](https://developers.google.com/gmail/markup/overview) | :x:       |
| SMO               | Saleor uses opengraph for optimizing social media engagement, see [docs](https://github.com/mirumee/saleor/blob/master/docs/integrations/smo.rst) | :heavy_check_mark:       |
| SEO               | Saleor handles aspects of search engine optimization, see [docs](https://github.com/mirumee/saleor/blob/master/docs/integrations/seo.rst) | :heavy_check_mark:       |

## Chart Architecture
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

Parent Chart (saleor):

```text
./deployment/helm/templates/
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

| Template                        | Description                                |
| ------------------------------- | ------------------------------------------ |
| `celery-deployment.yaml`        | Deploys pod(s) for the celery worker(s). Handles task queues for emails, image thumbnails, etc |
| `celery-hpa.yaml`               | Horizontal pod autoscaling for the celery worker pods |
| `custom-settings.yaml`          | Some custom additions/amendments to the `settings.py` file |
| `custom-uwsgi.yaml`             | Some custom additions/amendments to the `custom-uwsgi.yaml` file |
| `django-deployment.yaml`        | Deploys pod(s) for the core saleor (django) application. |
| `django-hpa.yaml`               | Horizontal pod autoscaling for the saleor (django) pods |
| `django-service.yaml`           | A service resource for the django application |
| `env.yaml`                      | A configmap data file with non-sensitive environment variables |
| `_helpers.tpl`                  | Helper templates designed to reduce code replication (DRY) |
| `currency-update-cronjob.yaml`  | A cronjob for updating the currency rates periodically |
| `vat-update-cronjob.yaml`       | A cronjob for updating the vat rates periodically |
| `01_db-migrate-job.yaml`        | Executes saleor database migrations |
| `02_db-populate-demo-job.yaml`  | Executes saleor database population and media file creation for the demo storefront |
| `03_db-create-users-job.yaml`   | Executes saleor database population with predefined users |
| `04_currency-update-job.yaml`   | Inserts the currency rates |
| `05_vat-update-job.yaml`        | Inserts the vat rates |
| `06_nginx-job.yaml`             | Prepares nginx pod if nginx as a server is enabled |
| `ingress.yaml`                  | Defines how to handle incoming traffic to the service |
| `nginx-deployment.yaml`         | Deploys pod(s) for the nginx server. Handles serving static and media assets |
| `nginx-hpa.yaml`                | Horizontal pod autoscaling for the nginx pods |
| `nginx-service.yaml`            | A service resource for the nginx server |
| `nginx-template.yaml`           | A configmap with the default `nginx.conf` file specific for a saleor deployment |
| `NOTES.txt`                     | Notes about the deployment presented to the user on successful deployment |
| `pvc.yaml`                      | A persistent volume claim resource for storing /app/media content, ie. images, etc |
| `secrets.yaml`                  | A kubernetes secret file with sensitive environment variables |

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

| Chart                           |  Source                                                           | Notes |
| ------------------------------- |  ---------------------------------------------------------------- | ----  |
| Elasticsearch                   | https://github.com/helm/charts/tree/master/stable/elasticsearch   | |  
| Postgresql                      | https://github.com/helm/charts/tree/master/stable/postgresql      | |
| Redis                           | https://github.com/helm/charts/tree/master/stable/redis           | |

## Chart configuration
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

The chart configuration can be divided into two parts

  - setting the parameters in `values.yaml`
  - setting the parameters for secrets with sensitive variables

### Values configuration
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

Configuration for the parent chart parameters under the namespace `.Values.saleor.` 

| Parameter              | Description            | Default                |
| ---------------------- | ---------------------- | ---------------------- |
| `saleor.image.repository` | Docker image repository. |  `mirumee/saleor`
| `saleor.image.tag` | The version of the docker image |  `cffccecbcff1c13ac5c458b630abb38f3e74517a`
| `saleor.image.pullPolicy` | Conditions for pulling the docker image | `IfNotPresent`
| `saleor.image.pullSecret` | The pull secret required to authenticate with a private docker registry | `None`
| `saleor.existingSecret` | If set, the chart will disregard the default secret and use this secret instead  | `None`
| `saleor.gloal.service.type` | The type of service to be used, can be `ClusterIP`, `NodePort` or `Loadbalancer` | `LoadBalancer`
| `saleor.gloal.service.port` | The port on which to expose the saleor service  | `80`
| `saleor.ingress.enabled` | Whether to handle incoming traffic through and ingress controller | `false`
| `saleor.ingress.annotations` | Annotations to be set on the ingress resource | `{}`
| `saleor.ingress.path` | The path being handled by the ingress resource, traffic will be forwarded to the service |  | `/`
| `saleor.ingress.hosts` | A list of hosts to be handled by the ingress resource | `saleor.local` (This is just a placeholder, must be changed)
| `saleor.ingress.tls` | A list of tls related resources | `[]` 
| `saleor.persistence.enabled` | Whether to enable disk persistence for saleor media content  | `false` 
| `saleor.persistence.accessMode` | Disk access mode | `ReadWriteOnce` 
| `saleor.persistence.size` | Size of the disk to be allocated | `10Gi` 
| `saleor.persistence.volume` | Type of volume for the persistent disk | `Filesystem` 
| `saleor.persistence.persistentVolumeReclaimPolicy` | Reclaim policy for the PVC | `Delete` 
| `saleor.persistence.storageClass` | Set to the storage class to be used, usually depends on the cluster infrastructure | `None` 
| `saleor.persistence.existingPvc` | Whether to use an existing PVC with a different name | `None` 
| `saleor.jobs.init.migrations.enabled` | Whether to run saleor default migrations | `true` 
| `saleor.jobs.init.migrations.activeDeadlineSeconds` | How many seconds for the job to be active before automatic shutdown | `300` 
| `saleor.jobs.init.migrations.backOffLimit` | How many times to attempt the migrations if a failure occurs | `5` 
| `saleor.jobs.init.migrations.ttlSecondsAfterFinished` | How long in seconds before the job is cleaned up after successful job completion | `240` 
| `saleor.jobs.init.migrations.weight` | The level of priority for the migration job (lower numbers have higher precedence) | `1`
| `saleor.jobs.init.prePopulateDemo.enabled` | Whether to run saleor populateDB demos scripts. Will persist sample data and media. | `true` 
| `saleor.jobs.init.prePopulateDemo.activeDeadlineSeconds` | How many seconds for the job to be active before automatic shutdown | `300` 
| `saleor.jobs.init.prePopulateDemo.backOffLimit` | How many times to attempt the data population if a failure occurs | `5` 
| `saleor.jobs.init.prePopulateDemo.ttlSecondsAfterFinished` | How long in seconds before the job is cleaned up after successful job completion | `240` 
| `saleor.jobs.init.prePopulateDemo.weight` | The level of priority for the pre-populate demo job (lower numbers have higher precedence) | `2` 
| `saleor.jobs.init.createUsers.enabled` | Whether to create pre-defined users for this installation | `true` 
| `saleor.jobs.init.createUsers.activeDeadlineSeconds` | How many seconds for the job to be active before automatic shutdown | `300` 
| `saleor.jobs.init.createUsers.backOffLimit` | How many times to attempt the create users if a failure occurs | `5` 
| `saleor.jobs.init.createUsers.ttlSecondsAfterFinished` | How long in seconds before the job is cleaned up after successful job completion | `240` 
| `saleor.jobs.init.createUsers.weight` | The level of priority for the create users job (lower numbers have higher precedence) | `3` 
| `saleor.jobs.init.createUsers.users` | A list of users identified by email address to be added to the saleor installation | See `values.yaml`
| `saleor.jobs.init.currencyUpdates.enabled` | Whether to run currency updates job | `true` 
| `saleor.jobs.init.currencyUpdates.activeDeadlineSeconds` | How many seconds for the job to be active before automatic shutdown | `300` 
| `saleor.jobs.init.currencyUpdates.backOffLimit` | How many times to attempt the currency updates if a failure occurs | `5` 
| `saleor.jobs.init.currencyUpdates.ttlSecondsAfterFinished` | How long in seconds before the job is cleaned up after successful job completion | `240` 
| `saleor.jobs.init.currencyUpdates.weight` | The level of priority for the currency updates job (lower numbers have higher precedence) | `4`
| `saleor.jobs.init.vatUpdates.enabled` | Whether to run vat updates | `true` 
| `saleor.jobs.init.vatUpdates.activeDeadlineSeconds` | How many seconds for the job to be active before automatic shutdown | `300` 
| `saleor.jobs.init.vatUpdates.backOffLimit` | How many times to attempt the vat updates if a failure occurs | `5` 
| `saleor.jobs.init.vatUpdates.ttlSecondsAfterFinished` | How long in seconds before the job is cleaned up after successful job completion | `240` 
| `saleor.jobs.init.vatUpdates.weight` | The level of priority for the vat updates job (lower numbers have higher precedence) | `5`
| `saleor.jobs.init.nginx.activeDeadlineSeconds` | How many seconds for the nginx job to be active before automatic shutdown | `300` 
| `saleor.jobs.init.nginx.backOffLimit` | How many times to attempt the nginx job if a failure occurs | `5` 
| `saleor.jobs.init.nginx.ttlSecondsAfterFinished` | How long in seconds before the job is cleaned up after successful job completion | `240` 
| `saleor.jobs.init.nginx.weight` | The level of priority for the nginx job (lower numbers have higher precedence) | `6` 
| `saleor.jobs.cron.currencyUpdates.enabled` | Whether to run currency updates as a cronjob | `true` 
| `saleor.jobs.cron.currencyUpdates.cron` | The cron tab defining frequency to run the job, defaults to daily | `"0 6 * * *"` 
| `saleor.jobs.cron.vatUpdates.enabled` | Whether to run vat updates as a cronjob | `true` 
| `saleor.jobs.cron.vatUpdates.cron` | The cron tab defining frequency to run the job, defaults to daily | `"0 7 * * *"` 
| `saleor.django.alternativeSettingsConfigMap` | The name of a configmap to override the default configmap with the custom settings.py file | `None`
| `saleor.django.alternativeUwsgiConfigMap` | The name of a configmap to override the default uwsgi with the custom uwsgi.ini settings | `None`
| `saleor.django.debugMode` | Whether to set `DEBUG = False`, a development only configuration option | `false`
| `saleor.django.settingsModule` | The name of the custom settings files | `saleor.custom-settings`
| `saleor.django.uwsgi.processes` | The number of processes running uwsgi | `2`
| `saleor.django.uwsgi.disableLogging` | Whether to disable uwsgi logging, logging can make a difference to performance | `false`
| `saleor.django.uwsgi.enableThreads` | Allow multiple threads in uwsgi | `false`
| `saleor.django.uwsgi.harakiri` | Refer to uswsgi documentation, disabled by default | `0`
| `saleor.django.uwsgi.port` | Port on which to serve requests | `8000`
| `saleor.django.uwsgi.logFormat` | Log format for requests | `UWSGI uwsgi "%(method) %(uri) %(proto) %(addr)" %(status) %(size) %(msecs)ms [PID:%(pid):Worker-%(wid)] [RSS:%(rssM)MB]`
| `saleor.django.uwsgi.logXForwardedFor` | Whether to log the forwarded address instead, useful if using a proxy server or ingress controller | `true`
| `saleor.django.uwsgi.logMaxSize` | Maximum size of the log file | `1024`
| `saleor.django.uwsgi.muteHealthCheckLogs` | Stop kubernetes liveness probes from cluttering the logs  | `true`
| `saleor.django.uwsgi.maxRequests` | Refer to uwsgi documentation  | `100`
| `saleor.django.uwsgi.numberOfThreads` | Number of threads, only has effect if `enableThreads` is true | `100`
| `saleor.django.uwsgi.maxWorkerLifeTime` | Refer to uwsgi documentation | `None`
| `saleor.django.uwsgi.vacuum` | Refer to uwsgi documentation | `None`
| `saleor.django.replicaCount` | Number of pods for the saleor application to run when autoscaling is disabled | `1`
| `saleor.django.autoscaling.enabled` | Whether to enable autoscaling for the saleor application | `true`
| `saleor.django.autoscaling.minReplicaCount` | The minimum of saleor application replicas to deploy | `1`
| `saleor.django.autoscaling.maxReplicaCount` | The minimum of saleor application replicas to deploy | `8`
| `saleor.django.autoscaling.targetCPUUtilizationPercentage` | The amount of CPU utilization before triggering spawning of a new replica | `80`
| `saleor.django.internalIps` | Refer to saleor or django documentation | `- 127.0.0.1`
| `saleor.django.timezone` | Refer to saleor or django documentation | `Etc/UTC`
| `saleor.django.languageCode` | Refer to saleor or django documentation | `en`
| `saleor.django.internationalization` | Refer to saleor or django documentation | `true`
| `saleor.django.localization` | Refer to saleor or django documentation | `true`
| `saleor.django.ssl.enabled` | Whether to enable ssl | `false`
| `saleor.django.staticUrl` | The static assets url | `/static/`
| `saleor.django.mediaUrl` | The media assets url | `/media/`
| `saleor.django.enableSilk` | Refer to saleor or django documentation  | `false`
| `saleor.django.defaultCountry` | Refer to saleor or django documentation  | `IE`
| `saleor.django.defaultCurrency` | Refer to saleor or django documentation  | `USD`
| `saleor.django.availableCurrencies` | Refer to saleor or django documentation  | See `values.yaml`
| `saleor.django.loginRedirectUrl` | Refer to saleor or django documentation  | `home`
| `saleor.django.googleAnalyticsTrackingId` | Google analytics tracking id, refer to saleor documentation  | `None`
| `saleor.django.lowStockThreshold` | The threshold at which a warning about low stock will appear  | `10`
| `saleor.django.maxCartLineQuantity` | The maximum of a product that can be added to the cart  | `50`
| `saleor.django.paginateBy` | The number of products per page by default in shopfront | `16`
| `saleor.django.dashboardPaginateBy` | The number of products per page by default in admin dashboard | `30`
| `saleor.django.dashboardSearchLimit` | The search limit for products in the admin dashboard | `5`
| `saleor.django.allowedHosts.includeIngressHosts` | Whether to include the hosts in the ingress resource automatically as allowed hosts | `true`
| `saleor.django.allowedHosts.hosts` | A list of allowed hosts | `- localhost - 127.0.0.1`
| `saleor.django.admins` | A list of django admins | `[]`
| `saleor.django.levels.saleorLogs` | Refer to the saleor settings.py file | `DEBUG`
| `saleor.django.levels.djangoServerLogs` | Refer to the saleor settings.py file | `INFO`
| `saleor.django.levels.djangoLogs` | Refer to the saleor settings.py file | `INFO`
| `saleor.django.levels.rootLogs` | Refer to the saleor settings.py file | `DEBUG`
| `saleor.django.levels.consoleHandler` | Refer to the saleor settings.py file | `DEBUG`
| `saleor.django.levels.mailAdminsHandler` | Refer to the saleor settings.py file | `ERROR`
| `saleor.django.images.placeholders.size_60` | The file path for the 60x60 placeholder image | `images/placeholder60x60.png`
| `saleor.django.images.placeholders.size_120` | The file path for the 120x120 placeholder image | `images/placeholder120x120.png`
| `saleor.django.images.placeholders.size_255` | The file path for the 255x255 placeholder image | `images/placeholder255x255.png`
| `saleor.django.images.placeholders.size_540` | The file path for the 540x540 placeholder image | `images/placeholder540x540.png`
| `saleor.django.images.placeholders.size_1080` | The file path for the 1080x1080 placeholder image | `images/placeholder1080x1080.png`
| `saleor.django.images.createOnDemand` | Generate images on demand. Will not work if `.Values.saleor.nginx.serveMedia: true` | `false`
| `saleor.django.logoutOnPasswordChange` | Logout automatically is user password is changed | `false`
| `saleor.django.recaptcha` | Public key for google recaptcha. See https://developers.google.com/recaptcha/docs/versions | `None`
| `saleor.django.aws.static.enabled` | Whether to enable AWS for static assets (TODO) | `false`
| `saleor.django.aws.static.bucketName` | AWS bucket name for static assets, refer to aws docs https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html#create-bucket-intro (TODO) | `None`
| `saleor.django.aws.static.customDomain` | AWS custom domain for static assets, refer to aws docs https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html (TODO) | `None`
| `saleor.django.aws.static.location` | AWS region, refer to https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html (TODO) | `eu-west-1`
| `saleor.django.aws.static.queryStringAuth` | Refer to aws docs https://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html (TODO) | `false`
| `saleor.django.aws.media.enabled` | Whether to enable AWS for media files (TODO) | `false`
| `saleor.django.aws.media.bucketName` | AWS bucket name for media files, refer to aws docs https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html#create-bucket-intro (TODO) | `None`
| `saleor.django.aws.media.customDomain` | AWS custom domain for media files, refer to aws docs https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html (TODO) | `None`
| `saleor.django.aws.media.location` | AWS region, refer to https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html (TODO) | `eu-west-1`
| `saleor.django.aws.media.queryStringAuth` | Refer to aws docs https://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html (TODO) | `false`
| `saleor.django.email.defaultFromEmail` | Default sender email address | `saleor@saleor.local`
| `saleor.django.email.orderFromEmail` | Default orders sender email address, if unset defaults to defaultFromEmail | `None`
| `saleor.django.email.smtpSettings.generic.enabled` | Whether to enable a generic email provider | `false`
| `saleor.django.email.smtpSettings.password` | The password to the email provider | `None`
| `saleor.django.email.smtpSettings.generic.loginName` | The smtp login name, ref ``smtp://[loginName]@[customDomainName]:[password]@[providerDomainName]:[port]/[extraArgs]`` | `None`
| `saleor.django.email.smtpSettings.generic.customDomainName` | The custom domain name for sending email, eg `saleor.example.com` ref `smtp://[loginName]@[customDomainName]:[password]@[providerDomainName]:[port]/[extraArgs]` | `None`
| `saleor.django.email.smtpSettings.generic.providerDomainName` | The provider domain name for sending email, eg `smtp.mailgun.org` ref `smtp://[loginName]@[customDomainName]:[password]@[providerDomainName]:[port]/[extraArgs]` | `None`
| `saleor.django.email.smtpSettings.generic.port` | The provider port for sending email, ref `smtp://[loginName]@[customDomainName]:[password]@[providerDomainName]:[port]/[extraArgs]` | `465`
| `saleor.django.email.smtpSettings.generic.extraArgs` | Any extra arguments on the smtp url, ref `smtp://[loginName]@[customDomainName]:[password]@[providerDomainName]:[port]/[extraArgs]` | `?ssl=True`
| `saleor.django.email.smtpSettings.mailjet.enabled` | Whether to enable mailjet for sending email | `false`
| `saleor.django.email.smtpSettings.mailjet.username` | Mailjet username | `None`
| `saleor.django.email.smtpSettings.amazonSES.enabled` | Whether to enable amazon SES for sending email | `false`
| `saleor.django.email.smtpSettings.amazonSES.username` | Amazon SES username | `None`
| `saleor.django.email.smtpSettings.amazonSES.region` | Amazon SES region | `eu-west-1`
| `saleor.django.openExchangesApiKey` | The API key to communicate with the open exchanges api | `None`
| `saleor.django.secretKey` | The django encryption secret key | `None`
| `saleor.django.vatLayerApiKey` | The vatlayer api key | `None`
| `saleor.django.vatLayerApiKey` | The vatlayer api key | `None`
| `saleor.django.externalServices.redis.password` | The password to an external redis database | `None`
| `saleor.django.externalServices.redis.host` | The host to an external redis database | `None`
| `saleor.django.externalServices.redis.tls` | Whether to use SSL to an external redis database | `true`
| `saleor.django.externalServices.redis.port` | The port to an external redis database | `6379`
| `saleor.django.externalServices.redis.dbNumber` | The db number to an external redis database | `0`
| `saleor.django.externalServices.redis.celeryBrokerDbNumber` | The celery broken db number to an external redis database | `1`
| `saleor.django.externalServices.postgresql.password` | The password to an external postgresql database | `None`
| `saleor.django.externalServices.postgresql.user` | The user for the external postgresql database | `None`
| `saleor.django.externalServices.postgresql.host` | The host for the external postgresql database | `None`
| `saleor.django.externalServices.postgresql.port` | The port for the external postgresql database | `5432`
| `saleor.django.externalServices.postgresql.database` | The database name for the external postgresql database | `saleor`
| `saleor.django.externalServices.postgresql.requireSSL` | Whether to force the usage of SSL for the external postgresql database | `true`
| `saleor.django.externalServices.elasticsearch.enabled` | Whether to enable elasticsearch as an external service. Elasticsearch is an optional saleor component. | `false`
| `saleor.django.externalServices.elasticsearch.password` | The password to an external elasticsearch database | `None`
| `saleor.django.externalServices.elasticsearch.user` | The user for the external elasticsearch database | `None`
| `saleor.django.externalServices.elasticsearch.host` | The host for the external elasticsearch database | `None`
| `saleor.django.externalServices.elasticsearch.port` | The host for the external elasticsearch database | `9200`
| `saleor.django.externalServices.elasticsearch.tls` | Whether to use https instead of http to communicate with the external elasticsearch database | `true`
| `saleor.django.payments.braintree.enabled` | Enable braintree payments | `false`
| `saleor.django.payments.braintree.sandboxMode` | Use braintree sandbox mode | `true`
| `saleor.django.payments.braintree.merchantId` | Braintree merchant id | `None`
| `saleor.django.payments.braintree.publicId` | Braintree public id | `None`
| `saleor.django.payments.braintree.privateId` | Braintree private id. Warning ! Leave this empty and set with secret ! | `None`
| `saleor.django.payments.dummy.enabled` | Enable dummy payments method - for testing/demo purposes | `true`
| `saleor.django.payments.razorpay.enabled` | Enable razorpay payments | `false`
| `saleor.django.payments.razorpay.prefill` | Prefill user form data in checkout | `false`
| `saleor.django.payments.razorpay.storeName` | Name of your store | `None`
| `saleor.django.payments.razorpay.storeLogo` | Url link to your store logo image | `None`
| `saleor.django.payments.razorpay.publicKey` | Razorpay public id | `None`
| `saleor.django.payments.razorpay.secretKey` | Razorpay secret key. Warning ! Leave this empty and set with secret ! | `None`
| `saleor.django.payments.stripe.enabled` | Enable stripe payments | `false`
| `saleor.django.payments.stripe.prefill` | Prefill user form data in checkout | `false`
| `saleor.django.payments.stripe.storeName` | Name of your store | `None`
| `saleor.django.payments.stripe.storeLogo` | Url link to your store logo image | `None`
| `saleor.django.payments.stripe.rememberMe` | Remember users for future purchases | `true`
| `saleor.django.payments.stripe.locale` | The language for the checkout form | `auto`
| `saleor.django.payments.stripe.billingAddress` | Whether to ask for a billing address | `false`
| `saleor.django.payments.stripe.shippingAddress` | Whether to ask for a shipping address | `false`
| `saleor.django.payments.stripe.publicKey` | Stripe public id | `None`
| `saleor.django.payments.stripe.secretKey` | Stripe secret key. Warning ! Leave this empty and set with secret ! | `None`
| `saleor.django.tokens.jwt.expires` | Whether the django jwt tokens should expire | `true`
| `saleor.django.livenessProbeSettings.initialDelaySeconds` | Saleor pod liveness probe initialDelaySeconds | `60`
| `saleor.django.livenessProbeSettings.periodSeconds` | Saleor pod liveness probe periodSeconds | `15`
| `saleor.django.livenessProbeSettings.failureThreshold` | Saleor pod liveness probe failureThreshold | `5`
| `saleor.django.livenessProbeSettings.successThreshold` | Saleor pod liveness probe successThreshold | `1`
| `saleor.django.livenessProbeSettings.timeoutSeconds` | Saleor pod liveness probe timeoutSeconds | `1`
| `saleor.django.readinessProbeSettings.initialDelaySeconds` | Saleor pod liveness probe initialDelaySeconds | `30`
| `saleor.django.readinessProbeSettings.periodSeconds` | Saleor pod liveness probe periodSeconds | `5`
| `saleor.django.readinessProbeSettings.failureThreshold` | Saleor pod liveness probe failureThreshold | `5`
| `saleor.django.readinessProbeSettings.successThreshold` | Saleor pod liveness probe successThreshold | `1`
| `saleor.django.readinessProbeSettings.timeoutSeconds` | Saleor pod liveness probe timeoutSeconds | `1`
| `saleor.django.resources.requests.cpu` | Minimum cpu resources required for a saleor pod | `500m`
| `saleor.django.resources.requests.memory` | Minimum memory resources required for a saleor pod | `512Mi`
| `saleor.django.resources.limits.cpu` | Maximum cpu resources allowed for a saleor pod | `1000m`
| `saleor.django.resources.limits.memory` | Maximum memory resources allowed for a saleor pod | `1Gi`
| `saleor.django.nodeSelector` | Refer to kubernetes documentation | `{}`
| `saleor.django.tolerations` | Refer to kubernetes documentation | `[]`
| `saleor.django.affinity` | Refer to kubernetes documentation | `{}`
| `saleor.celery.replicaCount` | The number of celery worker pods to spawn when autoscaling is `false` | `1`
| `saleor.celery.autoscaling.enabled` | Whether to use horizontal pod autoscaling by default or not | `true`
| `saleor.celery.autoscaling.minReplicaCount` | The minimum number of celery workers when using horizontal pod autoscaling | `1`
| `saleor.celery.autoscaling.targetCPUUtilizationPercentage` | The target percentage usage of cpu | `80`
| `saleor.celery.concurrencyType` | This attribute specifies the type of concurrency for celery to use. Celery has builtin concurrency feature distinct from kubernetes horizontal pod autoscaling | `auto`
| `saleor.celery.fixedConcurrency` | Where fixed celery concurrency is used, specify the number of processes. Only has effect if `concurrencyType: fixed` | `4`
| `saleor.celery.maxConcurrency` | Where automatic celery concurrency is used, specify the minimum number of processes. Only has effect if `concurrencyType: auto` | `2`
| `saleor.celery.maxConcurrency` | Where automatic celery concurrency is used, specify the maximum number of processes. Only has effect if `concurrencyType: auto` | `6`
| `saleor.celery.heartBeatIntervalSeconds` | Refer to celery documentation | `10`
| `saleor.celery.softTimeLimitSeconds` | Refer to celery documentation | `None`
| `saleor.celery.hardTimeLimitSeconds` | Refer to celery documentation | `None`
| `saleor.celery.logLevel` | Log level for celery | `INFO`
| `saleor.celery.taskEventsMonitoringEnabled` | Refer to celery documentation | `true`
| `saleor.celery.livenessProbeSettings.initialDelaySeconds` | Celery pod liveness probe initialDelaySeconds | `60`
| `saleor.celery.livenessProbeSettings.periodSeconds` | Celery pod liveness probe periodSeconds | `30`
| `saleor.celery.livenessProbeSettings.failureThreshold` | Celery pod liveness probe failureThreshold | `3`
| `saleor.celery.livenessProbeSettings.successThreshold` | Celery pod liveness probe successThreshold | `1`
| `saleor.celery.livenessProbeSettings.timeoutSeconds` | Celery pod liveness probe timeoutSeconds | `12`
| `saleor.celery.readinessProbeSettings.initialDelaySeconds` | Celery pod liveness probe initialDelaySeconds | `60`
| `saleor.celery.readinessProbeSettings.periodSeconds` | Celery pod liveness probe periodSeconds | `15`
| `saleor.celery.readinessProbeSettings.failureThreshold` | Celery pod liveness probe failureThreshold | `3`
| `saleor.celery.readinessProbeSettings.successThreshold` | Celery pod liveness probe successThreshold | `1`
| `saleor.celery.readinessProbeSettings.timeoutSeconds` | Celery pod liveness probe timeoutSeconds | `12`
| `saleor.celery.resources.requests.cpu` | Minimum cpu resources required for a celery pod | `500m`
| `saleor.celery.resources.requests.memory` | Minimum memory resources required for a celery pod | `256Mi`
| `saleor.celery.resources.limits.cpu` | Maximum cpu resources allowed for a celery pod | `1000m`
| `saleor.celery.resources.limits.memory` | Maximum memory resources allowed for a celery pod | `1Gi`
| `saleor.celery.nodeSelector` | Refer to kubernetes documentation | `{}`
| `saleor.celery.tolerations` | Refer to kubernetes documentation | `[]`
| `saleor.celery.affinity` | Refer to kubernetes documentation | `{}`
| `saleor.nginx.replicaCount` | The number of nginx pods to spawn if autoscaling is set to `false` | `1`
| `saleor.nginx.autoscaling.enabled` | Whether to enable autoscaling for the nginx pods. Unlikely to be needed. | `true`
| `saleor.nginx.autoscaling.minReplicaCount` | The minimum number of nginx pods when autoscaling is enabled | `1`
| `saleor.nginx.autoscaling.maxReplicaCount` | The maximum number of nginx pods when autoscaling is enabled | `2`
| `saleor.nginx.autoscaling.targetCPUUtilizationPercentage` | The target percentage usage of cpu | `80`
| `saleor.nginx.serveMedia.enabled` | Whether nginx should serve media files | `true`
| `saleor.nginx.image.repository` | The nginx image repository | `nginxinc/nginx-unprivileged`
| `saleor.nginx.image.tag` | The nginx image version | `nginxinc/nginx-unprivileged/1.15.5-alpine`
| `saleor.nginx.image.pullPolicy` | The nginx image pullPolicy | `IfNotPresent`
| `saleor.nginx.image.pullSecret` | The nginx image pullSecret | `None`
| `saleor.nginx.image.containerPort` | The nginx container port | `8080`
| `saleor.nginx.livenessProbeSettings.initialDelaySeconds` | Nginx pod liveness probe initialDelaySeconds | `60`
| `saleor.nginx.livenessProbeSettings.periodSeconds` | Nginx pod liveness probe periodSeconds | `15`
| `saleor.nginx.livenessProbeSettings.failureThreshold` | Nginx pod liveness probe failureThreshold | `5`
| `saleor.nginx.livenessProbeSettings.successThreshold` | Nginx pod liveness probe successThreshold | `1`
| `saleor.nginx.livenessProbeSettings.timeoutSeconds` | Nginx pod liveness probe timeoutSeconds | `1`
| `saleor.nginx.readinessProbeSettings.initialDelaySeconds` | Nginx pod liveness probe initialDelaySeconds | `15`
| `saleor.nginx.readinessProbeSettings.periodSeconds` | Nginx pod liveness probe periodSeconds | `5`
| `saleor.nginx.readinessProbeSettings.failureThreshold` | Nginx pod liveness probe failureThreshold | `5`
| `saleor.nginx.readinessProbeSettings.successThreshold` | Nginx pod liveness probe successThreshold | `1`
| `saleor.nginx.readinessProbeSettings.timeoutSeconds` | Nginx pod liveness probe timeoutSeconds | `1`
| `saleor.nginx.config.workerProcesses` | The number of nginx worker processes | `2`
| `saleor.nginx.config.workerConnections` | The max number of nginx worker connections | `1024`
| `saleor.nginx.config.accessLogs.enabled` | Whether to enable logging of nginx access logs | `true`
| `saleor.nginx.config.accessLogs.muteHealthChecks` | Whether to filter the kubernetes liveness and readiness probe logs out of the access logs thereby reducing logs clutter | `true`
| `saleor.nginx.config.errorLogs.enabled` | Whether to enable nginx error logs | `true`
| `saleor.nginx.config.errorLogs.logFormat` | The level above which nginx errors logs will be logged  | `$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"`
| `saleor.nginx.resources.requests.cpu` | Minimum cpu resources required for a nginx pod | `500m`
| `saleor.nginx.resources.requests.memory` | Minimum memory resources required for a nginx pod | `512Mi`
| `saleor.nginx.resources.limits.cpu` | Maximum cpu resources allowed for a nginx pod | `1000m`
| `saleor.nginx.resources.limits.memory` | Maximum memory resources allowed for a nginx pod | `1Gi`
| `saleor.nginx.nodeSelector` | Refer to kubernetes documentation | `{}`
| `saleor.nginx.tolerations` | Refer to kubernetes documentation | `[]`
| `saleor.nginx.affinity` | Refer to kubernetes documentation | `{}`

<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

Configuration of the subcharts:

| Parameter              | Description            | Default                | Further reference      |
| ---------------------- | ---------------------- | ---------------------- | ---------------------- |
| `postgresql.enabled` | Whether to use an in-cluster deployment of postgresql | `true` | `https://github.com/helm/charts/tree/master/stable/postgresql`
| `redis.enabled` | Whether to use an in-cluster deployment of redis | `true` | `https://github.com/helm/charts/tree/master/stable/redis`
| `elasticsearch.enabled` | Whether to use an in-cluster deployment of elasticsearch | `true` | `https://github.com/helm/charts/tree/master/stable/elasticsearch`

<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

### Secrets configuration
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

In order for the saleor deployment to function properly, the following secrets should be set as required:

| Secret                             | Chart/secret                  | Description                                                            |  Autogeneration Possible    |
| ---------------------------------- | ----------------------------- | ---------------------------------------------------------------------- | --------------------------- |
| `postgresql-password`              | Postgresql/saleor-postgresql  | Password for the postgresql database                                   |  :heavy_check_mark:         |
| `postgresql-replication-password`  | Postgresql/saleor-postgresql  | Replication password for the postgresql database                       |  :heavy_check_mark:         |
| `redis-password`                   | Redis/saleor-redis            | Password for the redis database                                        |  :heavy_check_mark:         |
| `email-password`                   | Saleor/saleor                 | Password for the sending emails through an smtp provider               |  :x:                        |
| `open-exchanges-api-key`           | Saleor/saleor                 | API key to make calls to the open exchanges api                        |  :x:                        |
| `saleor-secret-key`                | Saleor/saleor                 | The django secret for the saleor application                           |  :heavy_check_mark:         |
| `saleor-user-1-saleor-pass`        | Saleor/saleor                 | A default user password in the user-create job                         |  :heavy_check_mark:         |
| `saleor-user-2-example-pass`       | Saleor/saleor                 | A default user password in the user-create job                         |  :heavy_check_mark:         |
| `saleor-superuser-1-saleor-pass`   | Saleor/saleor                 | A default superuser password in the user-create job                    |  :heavy_check_mark:         |
| `aws-access-key-id`                | Saleor/saleor                 | The aws access key id, required if serving content via s3 (TODO)       |  :x:                        |
| `aws-access-key-secret`            | Saleor/saleor                 | The aws access key secret, required if serving content via s3 (TODO)   |  :x:                        |
| `ext-redis-pass`                   | Saleor/saleor                 | The password for an external redis database                            |  :x:                        |
| `ext-postgresql-pass`              | Saleor/saleor                 | The password for an external redis database                            |  :x:                        |
| `ext-elasticsearch-pass`           | Saleor/saleor                 | The password for an external elasticsearch database                    |  :x:                        |
| `ext-sentry-dsn`                   | Saleor/saleor                 | The full dsn for the external sentry application                       |  :x:                        |

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

***Step 1:***

- Modify the `saleor` secrets file and add the secrets for api keys, etc as required. See [Secrets configuration](#secrets-configuration).

***Step 2:***

For now, a saleor chart archive has not yet been released so the repository needs to be downloaded.

```bash
git clone https://github.com/stephenmoloney/saleor-helm.git --branch=master && cd saleor-helm;
```

***Step 3:***

Install the helm chart
 
- Modify the `values.yaml` file as required. See [Values configuration](#values-configuration)

```bash
helm dependency build ./deployment/helm && \
helm install --name saleor ./deployment/helm; 
```

### Installation with custom secret
<div>
  <a style="font-size: 400%;" href="#table-of-contents"> ^ top </a>
</div>
<br>

***Step 1:***

- Create a new secrets file with a unique name (eg `saleor-custom`) and add the secrets for api keys, etc as required. See [Secrets configuration](#secrets-configuration).

***Step 2:***

For now, a saleor chart archive has not yet been released so the repository needs to be downloaded.

```bash
git clone https://github.com/stephenmoloney/saleor-helm.git --branch=master && cd saleor-helm;
```

***Step 3:***

Install the helm chart
 
- Modify the `values.yaml` file as required. See [Values configuration](#values-configuration)

  - For example, if using an existing secret, create a `values-prod.yaml`
  ```
  saleor:
    existingSecret: saleor-custom
  redis:
    enabled: true
    existingSecret: saleor-custom
  postgresql:
    enabled: true
    existingSecret: saleor-custom
  ```  

```bash
helm dependency build ./deployment/helm && \
helm install --name saleor -f values-prod.yaml ./deployment/helm;
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

```bash
helm delete saleor --purge;
```
