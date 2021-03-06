#!/bin/bash
source variables.config

replace_values() {
  VALUE_TO_REPLACE=${2}
  if [ "$3" = "ENCODE" ] ; then
    # TODO convert to sealed-secret here
    VALUE_TO_REPLACE=`echo -n $2 | base64 -w 0`
  fi

  find platform/ -type f -name "*.yaml" -print0 | xargs -0 sed -i "s|${1}|${VALUE_TO_REPLACE}|g" && \
  find configs/ -type f -name "*.*" -print0 | xargs -0 sed -i "s|${1}|${VALUE_TO_REPLACE}|g"
}

replace_configs() {
    VALUE_TO_REPLACE=`cat $2 | base64 -w 0`
    find platform/ -type f -name "*.*" -print0 | xargs -0 sed -i "s|${1}|${VALUE_TO_REPLACE}|g"
}

replace_domain_in_tests() {
    find scripts/tests -type f -name "*.sh" -print0 | xargs -0 sed -i "s|DOMAIN|${DOMAIN}|g"
}

replace_secrets_with_sealed_secrets() {
  find platform/**/secrets -type f -name "*.yaml" | while read secretFile; do
      SEALED_SECRET="$(kubeseal --cert ./configs/sealed-secret-tls.cert < $secretFile -o yaml)"
      if [ ! -z "$SEALED_SECRET" ] ; then
        echo "$SEALED_SECRET" > $secretFile
      fi
  done
}

update_sealed_secrets_tls_cert_secret() {
  TLS_CRT_VALUE=`cat configs/sealed-secret-tls.cert | base64 -w 0`
  TLS_CRT_KEY=`cat configs/sealed-secret-tls.key | base64 -w 0`
  sed -i "s/BASE64_ENCODED_SEALED_SECRETS_TLS_KEY/${TLS_CRT_KEY}/g" configs/secret-sealed-secret-tls-cert.yaml
  sed -i "s/BASE64_ENCODED_SEALED_SECRETS_TLS_CRT/${TLS_CRT_VALUE}/g" configs/secret-sealed-secret-tls-cert.yaml
}

# Replace following keys with their values in config and platform
replace_values CLOUD_PROVIDER $CLOUD_PROVIDER && \
replace_values DNS_PROVIDER $DNS_PROVIDER && \
replace_values DOMAIN $DOMAIN && \
replace_values BASE64_ENCODED_SSL_CERTIFICATE_CA_CRT $BASE64_ENCODED_SSL_CERTIFICATE_CA_CRT && \
replace_values BASE64_ENCODED_SSL_CERTIFICATE_TLS_CRT $BASE64_ENCODED_SSL_CERTIFICATE_TLS_CRT && \
replace_values BASE64_ENCODED_SSL_CERTIFICATE_TLS_KEY $BASE64_ENCODED_SSL_CERTIFICATE_TLS_KEY && \
replace_values STAKATER_PLATFORM_SSH_GIT_URL $STAKATER_PLATFORM_SSH_GIT_URL && \
replace_values STAKATER_PLATFORM_BRANCH $STAKATER_PLATFORM_BRANCH && \
replace_values USER_MAIL $USER_MAIL && \
replace_values USER_NAME $USER_NAME && \
replace_values REPO_ACCESS_TOKEN $REPO_ACCESS_TOKEN && \
replace_values EXTERNAL_DNS_AWS_ACCESS_KEY_ID $EXTERNAL_DNS_AWS_ACCESS_KEY_ID ENCODE && \
replace_values EXTERNAL_DNS_AWS_SECRET_ACCESS_KEY $EXTERNAL_DNS_AWS_SECRET_ACCESS_KEY ENCODE && \
replace_values IMC_API_KEY $IMC_API_KEY && \
replace_values IMC_ALERT_CONTACTS $IMC_ALERT_CONTACTS && \
replace_values NEXUS_ADMIN_ACCOUNT_USER $NEXUS_ADMIN_ACCOUNT_USER && \
replace_values NEXUS_CLUSTER_ACCOUNT_USER $NEXUS_CLUSTER_ACCOUNT_USER && \
replace_values NEXUS_ADMIN_ACCOUNT_PASSWORD $NEXUS_ADMIN_ACCOUNT_PASSWORD && \
replace_values NEXUS_CLUSTER_ACCOUNT_PASSWORD $NEXUS_CLUSTER_ACCOUNT_PASSWORD && \
replace_values KEYCLOAK_CLIENT_ID $KEYCLOAK_CLIENT_ID && \
replace_values KEYCLOAK_CLIENT_SECRET $KEYCLOAK_CLIENT_SECRET && \
replace_values KEYCLOAK_DEFAULT_PASSWORD $KEYCLOAK_DEFAULT_PASSWORD && \
replace_values KEYCLOAK_DEFAULT_USERNAME $KEYCLOAK_DEFAULT_USERNAME && \
replace_values KEYCLOAK_DB_USER $KEYCLOAK_DB_USER ENCODE && \
replace_values KEYCLOAK_DB_PASSWORD $KEYCLOAK_DB_PASSWORD ENCODE && \
replace_values KEYCLOAK_PASSWORD $KEYCLOAK_PASSWORD ENCODE && \
replace_values JENKINS_NOTIFICATIONS_SLACK_CHANNEL $JENKINS_NOTIFICATIONS_SLACK_CHANNEL ENCODE && \
replace_values JENKINS_NOTIFICATIONS_SLACK_WEBHOOK_URL $JENKINS_NOTIFICATIONS_SLACK_WEBHOOK_URL ENCODE && \
replace_values JENKINS_PIPELINE_GITHUB_TOKEN $JENKINS_PIPELINE_GITHUB_TOKEN ENCODE && \
replace_values JENKINS_PIPELINE_GITLAB_TOKEN $JENKINS_PIPELINE_GITLAB_TOKEN ENCODE && \
replace_values JENKINS_PIPELINE_BITBUCKET_TOKEN $JENKINS_PIPELINE_BITBUCKET_TOKEN ENCODE && \
replace_values JENKINS_DOCKER_MAVEN_USERNAME $JENKINS_DOCKER_MAVEN_USERNAME && \
replace_values JENKINS_DOCKER_MAVEN_PASSWORD $JENKINS_DOCKER_MAVEN_PASSWORD && \
replace_values JENKINS_LOCAL_NEXUS_USERNAME $JENKINS_LOCAL_NEXUS_USERNAME && \
replace_values JENKINS_LOCAL_NEXUS_PASSWORD $JENKINS_LOCAL_NEXUS_PASSWORD && \
replace_values JENKINS_NEXUS_USERNAME $JENKINS_NEXUS_USERNAME && \
replace_values JENKINS_NEXUS_PASSWORD $JENKINS_NEXUS_PASSWORD && \
replace_values SLACK_INFRA_ALERTS_WEBHOOK_URL $SLACK_INFRA_ALERTS_WEBHOOK_URL && \
replace_values SLACK_INFRA_ALERTS_CHANNEL $SLACK_INFRA_ALERTS_CHANNEL && \
replace_values SLACK_APPS_ALERTS_WEBHOOK_URL $SLACK_APPS_ALERTS_WEBHOOK_URL && \
replace_values SLACK_APPS_ALERTS_CHANNEL $SLACK_APPS_ALERTS_CHANNEL && \
replace_values GRAFANA_USERNAME $GRAFANA_USERNAME ENCODE && \
replace_values GRAFANA_PASSWORD $GRAFANA_PASSWORD ENCODE && \
replace_values KIALI_USERNAME $KIALI_USERNAME ENCODE && \
replace_values KIALI_PASSWORD $KIALI_PASSWORD ENCODE && \
replace_values JENKINS_NEXUS_AUTH "$NEXUS_ADMIN_ACCOUNT_USER:$NEXUS_ADMIN_ACCOUNT_PASSWORD" ENCODE && \

# Replace following Configs with their base64 encoded values in secrets in platform
replace_configs  BASE64_ENCODED_ALERTMANAGER_CONFIG configs/alertmanager.yaml && \
replace_configs  BASE64_ENCODED_IMC_CONFIG configs/imc.yaml && \
replace_configs  BASE64_ENCODED_JENKINS_CONFIG configs/jenkins.json && \
replace_configs  BASE64_ENCODED_JENKINS_MAVEN_CONFIG configs/jenkins-maven-config.xml && \
replace_configs  BASE64_ENCODED_KEYCLOAK_CONFIG configs/keycloak.json && \
replace_configs  BASE64_ENCODED_NEXUS_ADMIN_ACCOUNT_JSON configs/nexus-admin-account.json && \
replace_configs  BASE64_ENCODED_NEXUS_CLUSTER_ACCOUNT_JSON configs/nexus-cluster-account.json && \
replace_configs  BASE64_ENCODED_PROXYINJECTOR_CONFIG configs/proxyinjector.yaml && \
replace_configs  BASE64_ENCODED_FLUX_PRIVATE_KEY configs/flux && \

# Update secret-sealed-secret-tls-cert
update_sealed_secrets_tls_cert_secret && \

# Convert all secrets to sealed secrets
replace_secrets_with_sealed_secrets && \

# Replace DOMAIN in test suite
replace_domain_in_tests

if [ $?==0 ]; then
  exit 0
else
  exit 1
fi