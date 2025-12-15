ARG BASE_IMAGE=wso2/wso2is:7.1.0
FROM ${BASE_IMAGE}

ARG MYSQL_CONNECTOR_VERSION=9.2.0

ADD --chown=wso2carbon:wso2 https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_CONNECTOR_VERSION}/mysql-connector-j-${MYSQL_CONNECTOR_VERSION}.jar ${WSO2_SERVER_HOME}/repository/components/lib/
