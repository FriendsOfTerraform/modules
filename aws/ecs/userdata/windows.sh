<powershell> Initialize-ECSAgent -Cluster ${cluster_name} -EnableTaskIAMRole -LoggingDrivers '["json-file","awslogs"]' </powershell>
