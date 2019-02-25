# Saleor-Helm

## Goals

This is a repository designed for development of saleor-helm charts. 

When the charts have matured sufficiently, potential goals may include: 

-   Update the [PR](https://github.com/mirumee/saleor/pull/2702) in saleor
 
-   Submit a pull request to helm/charts for the saleor deployment 

Refer to the [Helm README](deployment/helm/README.md) file for detailed documentation

## Roadmap

See the [Project Roadmap](https://github.com/stephenmoloney/saleor-helm/projects/1)

## Demo

Demos sites can be found as follows:

| App Type                 | URL                                                      | Notes                                            |
| ------------------------ | -------------------------------------------------------- | ------------------------------------------------ |
| Saleor MVC app           | [saleor mvc demo](https://staging.store.saleor-demo.com) | Backend rendered templates and business logic    |
| Saleor storefront app    |  TODO                                                    | Graphql driven single page app                   |

The demo of this project will be continuously deployed on the master
branch using the [weaveworks flux](https://github.com/weaveworks/flux)
continuous deployment system for kubernetes when:

-   a new image is built and pushed to the [docker registry](https://hub.docker.com/r/smoloney/saleor/tags)
-   this repository helm chart is modified

A Braintree sandbox account is setup for the demo site for testing payments.
The [braintree testing credit card numbers](https://developers.braintreepayments.com/guides/credit-cards/testing-go-live/python)
may be used for the braintree testing sandbox.

## Sentry

To generate sentry as part of the deployment process, see `fork/sentry-charts`.
For now, the easiest way to introduce sentry as part of your deployment is to
deploy the [helm/stable/sentry](https://github.com/helm/charts/tree/master/stable/sentry)
chart separately and then add the sentry dns to the `values.yaml` file.

## Contributing

Contributions are welcome, please read the 
[contributing guide](https://raw.githubusercontent.com/stephenmoloney/saleor-helm/master/.github/CONTRIBUTING.md).

## License

[Apache 2.0 license](./LICENSE)
