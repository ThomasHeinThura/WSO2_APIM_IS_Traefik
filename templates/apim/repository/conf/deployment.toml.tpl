[transport.https]
properties.port = 9443
properties.proxyPort = 443

[server]
hostname = "__APIM_HOSTNAME__"
base_path = "${carbon.protocol}://${carbon.host}:${carbon.management.port}"
server_role = "default"

[super_admin]
username = "admin"
password = "admin"
create_admin_account = true

[user_store]
type = "database_unique_id"

[database.apim_db]
type = "mysql"
url = "jdbc:mysql://__MYSQL_HOST__:3306/__APIM_DB__?autoReconnect=true&amp;allowPublicKeyRetrieval=true&amp;useSSL=false"
username = "__MYSQL_USER__"
password = "__MYSQL_PASSWORD__"
driver = "com.mysql.cj.jdbc.Driver"

[database.shared_db]
type = "mysql"
url = "jdbc:mysql://__MYSQL_HOST__:3306/__APIM_SHARED_DB__?autoReconnect=true&amp;allowPublicKeyRetrieval=true&amp;useSSL=false"
username = "__MYSQL_USER__"
password = "__MYSQL_PASSWORD__"
driver = "com.mysql.cj.jdbc.Driver"

[keystore.tls]
file_name =  "wso2carbon.jks"
type =  "JKS"
password =  "wso2carbon"
alias =  "wso2carbon"
key_password =  "wso2carbon"

[apim]
gateway_type = "Regular"

[[apim.gateway.environment]]
name = "Default"
type = "hybrid"
gateway_type = "Regular"
provider = "wso2"
display_in_api_console = true
description = "Default gateway profile"
show_as_token_endpoint_url = true
service_url = "https://localhost:${mgt.transport.https.port}/services/"
username= "${admin.username}"
password= "${admin.password}"
ws_endpoint = "ws://__APIM_WS_HOST__"
wss_endpoint = "wss://__APIM_WS_HOST__"
http_endpoint = "http://__APIM_GATEWAY_HOST__"
https_endpoint = "https://__APIM_GATEWAY_HOST__"
websub_event_receiver_http_endpoint = "http://__APIM_WEBSUB_HOST__"
websub_event_receiver_https_endpoint = "https://__APIM_WEBSUB_HOST__"

[apim.sync_runtime_artifacts.gateway]
gateway_labels =["Default"]

[apim.analytics]	
enable = true	
type = "elk"

[apim.ai]
enable = false
key = ""
endpoint = ""

[apim.key_manager]
enable_lightweight_apikey_generation = true

[apim.cors]
allow_origins = "*"
allow_methods = ["GET","PUT","POST","DELETE","PATCH","OPTIONS"]
allow_headers = ["authorization","Access-Control-Allow-Origin","Content-Type","SOAPAction","apikey","Internal-Key"]
allow_credentials = false

[[event_handler]]
name="userPostSelfRegistration"
subscriptions=["POST_ADD_USER"]

[service_provider]
sp_name_regex = "^[\\sa-zA-Z0-9._-]*$"

[database.local]
url = "jdbc:h2:./repository/database/WSO2CARBON_DB;DB_CLOSE_ON_EXIT=FALSE"

[[event_listener]]
id = "token_revocation"
type = "org.wso2.carbon.identity.core.handler.AbstractIdentityHandler"
name = "org.wso2.is.notification.ApimOauthEventInterceptor"
order = 1
[event_listener.properties]
notification_endpoint = "https://localhost:${mgt.transport.https.port}/internal/data/v1/notify"
username = "${admin.username}"
password = "${admin.password}"
'header.X-WSO2-KEY-MANAGER' = "default"

[oauth.grant_type.token_exchange]
enable = true
allow_refresh_tokens = true
iat_validity_period = "1h"

[apim.open_telemetry]
remote_tracer.enable = false
log_tracer.enable = true
