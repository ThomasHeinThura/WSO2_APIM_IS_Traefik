ARG BASE_IMAGE=wso2/wso2is:7.1.0
FROM ${BASE_IMAGE}

ARG MYSQL_CONNECTOR_VERSION=9.2.0

ADD --chown=wso2carbon:wso2 https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_CONNECTOR_VERSION}/mysql-connector-j-${MYSQL_CONNECTOR_VERSION}.jar ${WSO2_SERVER_HOME}/repository/components/lib/

# Import self-signed cert into client-truststore
COPY --chown=wso2carbon:wso2 config/traefik/certs/selfsigned.crt /tmp/selfsigned.crt
RUN keytool -import -alias traefik-selfsigned -file /tmp/selfsigned.crt \
    -keystore ${WSO2_SERVER_HOME}/repository/resources/security/client-truststore.jks \
    -storepass wso2carbon -noprompt && \
    rm /tmp/selfsigned.crt
