#!/bin/sh

export GCLOUD_VERSION="342.0.0-linux-x86_64"
export GCLOUD_DIRNAME="google-cloud-sdk"
export GCLOUD_FILENAME="$GCLOUD_DIRNAME-$GCLOUD_VERSION.tar.gz"
export GCLOUD_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$GCLOUD_FILENAME"
export GCLOUD_SHA512="5ff9c271df3a7cf02e841b67615433bf5260c622b9bd2051d9d7eaf6b51c3aca61f0a18823df63eabdecd0ab9814ac4557dd68f4b9ec07f06c63463b57ee8ee6"

export GCLOUD_INSTALL_DIR="$WERCKER_STEP_ROOT/$GCLOUD_DIRNAME"

gcloud="$GCLOUD_INSTALL_DIR/bin/gcloud"
kubectl="$GCLOUD_INSTALL_DIR/bin/kubectl"

# Extract gcloud SDK files if not already extracted
if [ ! -f "$gcloud" ]; then
  pushd "$WERCKER_STEP_ROOT"

  if which curl; then
    curl -L "$GCLOUD_URL" -o "$GCLOUD_FILENAME"
  elif which wget; then
    wget -q "$GCLOUD_URL" -O "$GCLOUD_FILENAME"
  else
    echo "curl or wget not installed; unable to download gcloud"
    exit 1
  fi

  if ! sha512sum "$GCLOUD_FILENAME" | grep -q "$GCLOUD_SHA512"; then
    echo "gcloud archive sha512sum do not match"
    exit 1
  fi

  tar zxf "$GCLOUD_FILENAME"
  $gcloud components install kubectl

  popd
fi

gcloud_auth_config() {
  if [ ! -n "$WERCKER_KUBECTL_GKE_CLUSTER_NAME" ]; then
    fail "GKE cluster name must be provided."
  fi

  if [ ! -n "$WERCKER_KUBECTL_GKE_CLUSTER_ZONE" ]; then
    fail "GKE cluster zone must be provided."
  fi

  if [ ! -n "$WERCKER_KUBECTL_GKE_CLUSTER_PROJECT" ]; then
    fail "GKE cluster project name must be provided."
  fi

  gcloud_key_file="$WERCKER_STEP_ROOT/gcloud.json"

  export CLOUDSDK_COMPUTE_ZONE="$WERCKER_KUBECTL_GKE_CLUSTER_ZONE"
  export CLOUDSDK_CORE_PROJECT="$WERCKER_KUBECTL_GKE_CLUSTER_PROJECT"

  # Write the JSON string to a temporary file
  echo "$WERCKER_KUBECTL_GCLOUD_KEY_JSON" > "$gcloud_key_file"

  # Attempt to activate the service account with Google
  if ! $gcloud auth activate-service-account --key-file "$gcloud_key_file"; then
    fail "Unable to authenticate with Google Cloud..."
  fi

  # This env var pointing to the temporary JSON key file needs to be exported
  # as it's read by kubectl's GKE authenticator plugin
  export GOOGLE_APPLICATION_CREDENTIALS="$gcloud_key_file"

  # This will set the kubectl config...
  if ! $gcloud container clusters get-credentials "$WERCKER_KUBECTL_GKE_CLUSTER_NAME"; then
    fail "Unable to get kubectl credentials for GKE cluster."
  fi
}

main() {
  display_version

  if [ -n "$WERCKER_KUBECTL_GCLOUD_KEY_JSON" ]; then
    # Google cloud key JSON found. We'll assume kubectl
    # needs access to a GKE cluster, and will configure kubectl
    # to use the service account that should be defined in the JSON string.
    echo "Configuring gcloud service account"

    gcloud_auth_config;
  fi

  if [ -z "$WERCKER_KUBECTL_COMMAND" ]; then
    fail "wercker-kubectl: command argument cannot be empty"
  fi

  cmd="$WERCKER_KUBECTL_COMMAND"

  # Global args
  #global_args
  global_args=
  raw_global_args="$WERCKER_KUBECTL_RAW_GLOBAL_ARGS"

  # token
  if [ -n "$WERCKER_KUBECTL_TOKEN" ]; then
    global_args="$global_args --token=\"$WERCKER_KUBECTL_TOKEN\""
  fi

  # username
  if [ -n "$WERCKER_KUBECTL_USERNAME" ]; then
    global_args="$global_args --username=\"$WERCKER_KUBECTL_USERNAME\""
  fi

  # password
  if [ -n "$WERCKER_KUBECTL_PASSWORD" ]; then
    global_args="$global_args --password=\"$WERCKER_KUBECTL_PASSWORD\""
  fi

  # server
  if [ -n "$WERCKER_KUBECTL_SERVER" ]; then
    global_args="$global_args --server=\"$WERCKER_KUBECTL_SERVER\""
  fi

  # insecure-skip-tls-verify
  if [ -n "$WERCKER_KUBECTL_INSECURE_SKIP_TLS_VERIFY" ]; then
    global_args="$global_args --insecure-skip-tls-verify=\"$WERCKER_KUBECTL_INSECURE_SKIP_TLS_VERIFY\""
  fi
    # certificate-authority
  if [ -n "$WERCKER_KUBECTL_CERTIFICATE_AUTHORITY" ]; then
    global_args="$global_args --certificate-authority=\"$WERCKER_KUBECTL_CERTIFICATE_AUTHORITY\""
  fi
    # client-certificate
  if [ -n "$WERCKER_KUBECTL_CLIENT_CERTIFICATE" ]; then
    global_args="$global_args --client-certificate=\"$WERCKER_KUBECTL_CLIENT_CERTIFICATE\""
  fi
    # client-key
  if [ -n "$WERCKER_KUBECTL_CLIENT_KEY" ]; then
    global_args="$global_args --client-key=\"$WERCKER_KUBECTL_CLIENT_KEY\""
  fi

  # Command specific flags
  args=
  raw_args="$WERCKER_KUBECTL_RAW_ARGS"

  # file
  if [ -n "$WERCKER_KUBECTL_FILE" ]; then
    args="$args --file=\"$WERCKER_KUBECTL_FILE\""
  fi

  # output
  if [ -n "$WERCKER_KUBECTL_OUTPUT" ]; then
    args="$args --output=\"$WERCKER_KUBECTL_OUTPUT\""
  fi

  # template
  if [ -n "$WERCKER_KUBECTL_TEMPLATE" ]; then
    args="$args --template=\"$WERCKER_KUBECTL_TEMPLATE\""
  fi

  # patch
  if [ -n "$WERCKER_KUBECTL_PATCH" ]; then
    args="$args --patch=\"$WERCKER_KUBECTL_PATCH\""
  fi

  # interactive
  if [ -n "$WERCKER_KUBECTL_INTERACTIVE" ]; then
    args="$args --interactive=\"$WERCKER_KUBECTL_INTERACTIVE\""
  fi

  # image
  if [ -n "$WERCKER_KUBECTL_IMAGE" ]; then
    args="$args --image=\"$WERCKER_KUBECTL_IMAGE\""
  fi

  # timeout
  if [ -n "$WERCKER_KUBECTL_TIMEOUT" ]; then
    args="$args --timeout=\"$WERCKER_KUBECTL_TIMEOUT\""
  fi

  # update-period
  if [ -n "$WERCKER_KUBECTL_UPDATE_PERIOD" ]; then
    args="$args --update-period=\"$WERCKER_KUBECTL_UPDATE_PERIOD\""
  fi

  # deployment-label-key
  if [ -n "$WERCKER_KUBECTL_DEPLOYMENT_LABEL_KEY" ]; then
    args="$args --deployment-label-key=\"$WERCKER_KUBECTL_DEPLOYMENT_LABEL_KEY\""
  fi

  # poll-interval
  if [ -n "$WERCKER_KUBECTL_POLL_INTERVAL" ]; then
    args="$args --poll-interval=\"$WERCKER_KUBECTL_POLL_INTERVAL\""
  fi

  # rollback
  if [ -n "$WERCKER_KUBECTL_ROLLBACK" ]; then
    args="$args --rollback=\"$WERCKER_KUBECTL_ROLLBACK\""
  fi

  # replicas
  if [ -n "$WERCKER_KUBECTL_REPLICAS" ]; then
    args="$args --replicas=\"$WERCKER_KUBECTL_REPLICAS\""
  fi

  # current-replicas
  if [ -n "$WERCKER_KUBECTL_CURRENT_REPLICAS" ]; then
    args="$args --current-replicas=\"$WERCKER_KUBECTL_CURRENT_REPLICAS\""
  fi

  # resource-version
  if [ -n "$WERCKER_KUBECTL_RESOURCE_VERSION" ]; then
    args="$args --resource-version=\"$WERCKER_KUBECTL_RESOURCE_VERSION\""
  fi

  # pod
  if [ -n "$WERCKER_KUBECTL_POD" ]; then
    args="$args --pod=\"$WERCKER_KUBECTL_POD\""
  fi

  # stdin
  if [ -n "$WERCKER_KUBECTL_STDIN" ]; then
    args="$args --stdin=\"$WERCKER_KUBECTL_STDIN\""
  fi

  # tty
  if [ -n "$WERCKER_KUBECTL_TTY" ]; then
    args="$args --tty=\"$WERCKER_KUBECTL_TTY\""
  fi

  # grace-period
  if [ -n "$WERCKER_KUBECTL_GRACE_PERIOD" ]; then
    args="$args --grace-period=\"$WERCKER_KUBECTL_GRACE_PERIOD\""
  fi

  # selector
  if [ -n "$WERCKER_KUBECTL_SELECTOR" ]; then
    args="$args --selector=\"$WERCKER_KUBECTL_SELECTOR\""
  fi

  # all
  if [ -n "$WERCKER_KUBECTL_ALL" ]; then
    args="$args --all=\"$WERCKER_KUBECTL_ALL\""
  fi

  # overwrite
  if [ -n "$WERCKER_KUBECTL_OVERWRITE" ]; then
    args="$args --overwrite=\"$WERCKER_KUBECTL_OVERWRITE\""
  fi

  info "Running kubectl command"
  if [ "$WERCKER_KUBECTL_DEBUG" = "true" ]; then
    info "kubectl $global_args $raw_global_args $cmd $args $raw_args"
  fi

  eval "$kubectl" "$global_args" "$raw_global_args" "$cmd" "$args" "$raw_args"
}

display_version() {
  info "Running kubectl version:"
  "$kubectl" version --client
  echo ""
}

main;
