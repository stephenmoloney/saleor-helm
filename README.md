# Saleor-Helm

### Goals

This is a repository designed for development of saleor-helm charts. 

When the charts have matured sufficiently, potential goals may include: 

  - Update the [PR](https://github.com/mirumee/saleor/pull/2702) in saleor 
  - Submit a pull request to helm/charts for the saleor deployment 

Refer to the [Helm README](deployment/helm/README.md) file for detailed documentation

### Roadmap

See the github [Project Roadmap](https://github.com/stephenmoloney/saleor-helm/projects/1)

### Demo

Demos sites can be found as follows:

| App Type  | URL  | Notes |
|---|---|---|
| Saleor MVC app | https://store.saleor-demo.com  | Backend rendered templates and business logic |
| Saleor storefront app  |  TODO | Graphql driven single page app |

The demo of this project will be continuously deployed whenever
a new image is built and pushed to the [docker registry](https://hub.docker.com/r/smoloney/saleor/tags)

A Braintree sanbox account is in place for testing payments.
Only, the [braintree testing credit card numbers](https://hub.docker.com/r/smoloney/saleor/tags)
may be used for the braintree testing sandbox.


### Sentry

In order to generate sentry as part of the deployment process, see `fork/sentry-charts`.
This fork might be eventually be reintroduced to master. For now, the
easiest way to introduce sentry as part of your deployment is to
deploy the [helm/stable/sentry](https://github.com/helm/charts/tree/master/stable/sentry)
chart and then add the sentry dns to to the `values.yaml` file.

## Contributing

Contributions are welcome, please read the [contributing guide](https://raw.githubusercontent.com/stephenmoloney/saleor-helm/master/.github/CONTRIBUTING.md)

## License

- The license for the saleor charts is the Apache license. [License](#LICENSE)
- The license for modifications to the sentry charts is the Apache license. [License](#LICENSE)
