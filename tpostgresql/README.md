# Postsgres chart abstraction

this provide way to configure postgres to be used in 3 different configurations :
  * embedded : the postgres cluster is created inside the K8s cluster.
  * external : the postgres cluster is outside the K8s cluster
  * osba : the postgres cluster is outside the cluster but managed from the cluster through the Open service broker APIs.

## TL;DR;

```bash
$ helm install <chart_folder_location>
```

### Introduction
The idea here is to create a unique master secret ( named $release-.Values.masterSecretName ) with all the information required for other services to gain access to the postgres cluster whatever the resources is provided or created by this chart.
 * embedded : install the official postgresql chart and create the master secret password from the postgres created secret and the given values.
 * external : this will create a secret from the values provided when installing this chart.
 * osba : this will install an external postgres depending on the OSBA service provided by the cloud provider and then create the master secret according to the credentials created by the OSBA binding.

 the secret created will be populated with the following values
```
postgresql.database: <the name of the DB >
postgresql.host: <host name, can be an IP or a K8s service name>
postgresql.password: <master password>
postgresql.port: <cluster port, usually 5432>
postgresql.user: master-user

```

### Prerequisites
- Kubernetes v1.9+
- <other dependencies or prerequisites>

### Installing the chart
To install the chart with the release name postgresql on your local k8s cluster you need to:

```$ helm install --name postgresql <proj_root_folder>/deploy/kubernetes/postgresql```

To install the chart on the k8s cluster you also need to set the Tiller namespace and the application namespace. You can do this with one of the following two commands:
```
$ helm install --name postgresql . 
```

The command deploys the postgresql Service on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

### Uninstalling the chart

To uninstall/delete the postgresql deployment:

```$ helm delete --purge postgresql```

This command removes all the Kubernetes components associated with the chart and deletes the release.

### Configuration

The following tables lists the configurable parameters of the postgresql chart and their default values. 

Parameter                          | Description	                                    | Default
-----------------------------------|--------------------------------------------------|--------------------------------
`global.infraReleaseName`          | Helm release name for infrastructure             | infra
`global.postgresqlImageTag`        | Docker image tag/versionNumber                   | latest
`external.enabled`                 | creates the master secret from given values       | false
`osba.enabled`                     | creates the master secret after OSBA binding is created| false
`postgresqlembedded.enabled`       | creates the master secret once the embedded postgres secret is create| true

All of the last three above values are mutually exclusive.
1) **external.enabled=true**, Create a master secret to connect to any external postgres cluster.

Parameter                          | Description	                                    | Default
-----------------------------------|--------------------------------------------------|--------------------------------
`external.host`                    | the external host IP or K8s service to the external host   | 
`external.user`                    | master postgresql DB user name    | 
`external.password`                | master postgresql DB password   | 
`external.port`                    | the postgresql external cluster port   | 
`external.database`                | name of a default created DB (should not be used, each app shall create their own)   | 

2) **osba.enabled=true**, this enable a secret to be created to connect to any external postgres cluster.
Here the parameters are dependent of the resource provider (there is one example for Arzure)

3) **postgresqlembedded.enabled=true**, create a secret for using the embedded postgresql cluster.
see https://github.com/kubernetes/charts/tree/master/stable/postgresql

WARNING:
Due to a wierd helm behaviour : https://github.com/kubernetes/helm/issues/3533

if you want to disable the embedded postgresql you must set the following values at the **root chart** : 
```
postgresqlembeddedDependency: 
  enabled: false
```

#### RBAC
For the embedded and osba option you also need to enable specific roles for create and deleting secrets.
Parameter                          | Description	                                    | Default
-----------------------------------|--------------------------------------------------|--------------------------------
`serviceAccount.create`            | create a service account for the specific role   | true
`rbac.create`                    | create role and rolebinding    | true


You can override these values at runtime using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name postgresql \
  --set <parameter1>=<value1>,<parameter2>=<value2> \
    <proj_root_folder>/deploy/kubernetes/postgresql
```

The above command deploys the postgresql service in the k8s cluster.

