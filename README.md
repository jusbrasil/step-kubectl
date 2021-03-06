# kubectl

This step vendors the kubectl executable, and allows the user to execute a
command. Most options are passed along to the `kubectl` executable as is.

# Options:

- `debug` (optional, default: `false`) List the kubectl before running it.
Warning, all environment variables are expanded, including the password.
- `cmd` (optional) The kubectl command which needs to be run.
- `raw-global-args` (optional) Arguments that are placed before `cmd`.
- `raw-args` (optional) Arguments that are placed after `cmd`.

## Kubectl flags

The following options are available as wercker properties. The values are passed
directly to the `kubectl` command. See the `kubectl` for the documentation.

- `all`
- `current-replicas`
- `deployment-label-key`
- `file`
- `grace-period`
- `image`
- `insecure-skip-tls-verify`
- `interactive`
- `output`
- `overwrite`
- `password`
- `patch`
- `pod`
- `poll-interval`
- `replicas`
- `resource-version`
- `rollback`
- `selector`
- `server`
- `stdin`
- `template`
- `timeout`
- `token`
- `tty`
- `update-period`
- `username`

If a flag is not available, use the `raw-global-args` or the `raw-args` option.

# Example

```
deploy:
    steps:
      - jusbrasil/kubectl:
          server: $KUBERNETES_MASTER
          username: $KUBERNETES_USERNAME
          password: $KUBERNETES_PASSWORD
          insecure-skip-tls-verify: true
          command: create -f cities-controller.json
```

# Google Container Engine (GKE) clusters

Passing the contents of a Google service account private key JSON file in optional parameter `gcloud-key-json` will
cause this step to use the gcloud SDK to authenticate kubectl for access to GKE with a Google service account.

You'll also need to pass:

```
  gcloud-key-json:
    type: string
    required: false
  gke-cluster-name:
    type: string
    required: false
  gke-cluster-zone:
    type: string
    required: false
  gke-cluster-project:
    type: string
    required: false
```

# License

The MIT License (MIT)

# Changelog

## 3.12.0

- Install the `gcloud` SDK and install `kubectl` via the
  `gcloud components install kubectl` command
- Add support for authenticating with GKE clusters with a Google service account

## 3.11.0

- Update to kubectl version `1.15.12`

## 3.10.0

- Update to kubectl to version `1.14.8`

## 3.9.0

- Update to kubectl to version `1.10.5`

## 3.5.0

- Update to kubectl to version `1.7.6`

## 3.4.0

- Update to kubectl to version `1.6.2`

## 3.3.0

- Update to kubectl to version `1.5.3`

## 3.2.0-kube1.5.2

- Update to kubectl to version `1.5.2`

## 3.1.0

- Update to kubectl to version `1.4.4`

## 3.0.0

- Update to kubectl to version `1.3.4`

## 2.1.0

- Add `certificate-authority`, `client-certificate`, `client-key`

## 2.0.0

- Update to kubectl to version `1.2.0`

## 1.1.0

- Update to kubectl to version `1.1.3`

## 1.0.0

- Initial release
