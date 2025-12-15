[server]
hostname = "__IS_HOSTNAME__"
node_ip = "0.0.0.0"
base_path = "https://$ref{server.hostname}:${carbon.management.port}"
offset = "0"

[transport.https.properties]
proxyPort = 443
server = "WSO2 Carbon Server"

[transport.https.sslHostConfig.properties]
protocols = "+TLSv1.2, +TLSv1.3"
ciphers = "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384, TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384, TLS_DHE_DSS_WITH_AES_256_GCM_SHA384, TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256, TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256, TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256, TLS_DHE_DSS_WITH_AES_128_GCM_SHA256"

[super_admin]
username = "admin"
password = "admin"
create_admin_account = true

[user_store]
type = "database_unique_id"

[database.identity_db]
type = "mysql"
url = "jdbc:mysql://__MYSQL_HOST__:3306/__IS_IDENTITY_DB__?autoReconnect=true&amp;useSSL=false&amp;allowPublicKeyRetrieval=true"
username = "__MYSQL_USER__"
password = "__MYSQL_PASSWORD__"
driver = "com.mysql.cj.jdbc.Driver"

[database.shared_db]
type = "mysql"
url = "jdbc:mysql://__MYSQL_HOST__:3306/__IS_SHARED_DB__?autoReconnect=true&amp;useSSL=false&amp;allowPublicKeyRetrieval=true"
username = "__MYSQL_USER__"
password = "__MYSQL_PASSWORD__"
driver = "com.mysql.cj.jdbc.Driver"

[database.user]
type = "mysql"
url = "jdbc:mysql://__MYSQL_HOST__:3306/__IS_SHARED_DB__?autoReconnect=true&amp;useSSL=false&amp;allowPublicKeyRetrieval=true"
username = "__MYSQL_USER__"
password = "__MYSQL_PASSWORD__"
driver = "com.mysql.cj.jdbc.Driver"

[datasource.WSO2ConsentDS]
id = "WSO2CONSENT_DB"
type = "mysql"
url = "jdbc:mysql://__MYSQL_HOST__:3306/__IS_IDENTITY_DB__?autoReconnect=true&amp;useSSL=false&amp;allowPublicKeyRetrieval=true"
username = "__MYSQL_USER__"
password = "__MYSQL_PASSWORD__"
driver = "com.mysql.cj.jdbc.Driver"
jmx_enable = false

[keystore.primary]
file_name = "wso2carbon.p12"
password = "wso2carbon"
type="PKCS12"

[truststore]
file_name="client-truststore.p12"
password="wso2carbon"
type="PKCS12"

[account_recovery.endpoint.auth]
hash= "66cd9688a2ae068244ea01e70f0e230f5623b7fa4cdecb65070a09ec06452262"

[identity.auth_framework.endpoint]
app_password= "dashboard"
