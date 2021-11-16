# Envio SaltStack

This repository contains the previously showcased proofs-of-concept which remove any use of unnecessary `cmd.run` calls
and tries to minimize overhead and repetition using the correct tools

These formulas aim to smooth out and speed up the deployment process of Envioller and all of the required dependencies
minimizing bandwidth consumption as well.

The following formulas have been tested with dummy `.deb` files which contain binaries and assets that weight
up to 50MB in total.

* envioller-\*-\*-buster.deb 10MB
* envioller-dependencies-\*-\*-buster.deb 40MB

# Getting started

We're gonna start by adding the main configuration file. This approach only uses one default `.yaml` file
to avoid redundancy and merging.

This approach has also proven to speed up the SaltStack tasks by avoiding adding a huge load into its pillars.

#### **1. Start by editing the file `defaults.yaml` to your needs. If none is needed, we can continue with the deploy.**


After the main structure is set, make a copy of `defaults.yaml.example` into the folder `salt`
named `defaults.yaml`.

```
/srv$ cp defaults.yaml.example salt/defaults.yaml
```

#### **2. Setting up**

The configuration file provides our `envioller` formula with configurable versions as templates. We can use
this to install an specific version of our packages and also allows us to rollback to an older available version
by just adjusting this parameter. You can see more about its usage in the file `salt/envioller/install.sls`.

```yaml
# Check "salt/envioller/install.sls" to see how these properties are used
# as templates.
envio:
  versions:
    envioller: 1.1.42-buster # Configuration should match envioller-1.1.42-buster.deb
    gwscheduler: 21.07.19
    dependencies: 1.1.42-buster # Configuration should match envioller-dependencies-1.1.42-buster.deb
```

#### **3. Prepare your packages**

We want to store our `.deb` packages inside `/srv/salt/gateway/modules/envioller/v1/files/packages`. E.g:

```
$ ls /srv/salt/files/packages/
envioller-1.1.42-buster.deb  envioller-dependencies-1.1.42-buster.deb
envioller-1.1.43-buster.deb  envioller-dependencies-1.1.43-buster.deb
```

If no packages are present or the configured version in your `defaults.yaml` file
does not match any package, SaltStack will not continue the deployment. Although
it will set a resume point until this issue is fixed and can continue further with
the deployment.

#### **4. Deploy to your minions**

We're going to deploy our software named envioller alongside its dependency package.
As shown before, we're not going to use HTTP to install these dependencies at all,
we're going to use the SaltStack transport layer.

To deploy the packages, run:

```
$ salt "my_beloved" state.sls envioller
```

This formula will prepare the minion by creating all the necessary folders and
the required configuration files, which are templates as well.

#### **5. After deploying our software, we can use it in our minions by just running:**

```
$ envioller
Greetings line 4, what is your name, traveler?
```

# Rolling back

In our example, we use 2 versions of our packages (`1.1.42-buster` and `1.1.43-buster`). We
can configure our master to rollback by adjusting the mentioned properties in
the 2nd step.

By changing the version to 1.1.42-buster, our master will detect a change of checksums
and replace the existing deployed version with the new configured one as well as its dependencies
without using HTTP or anything other than the SaltStack transport layer.

This also applies to our templates. If we have a change or add more options to the
templates located in `/srv/salt/gateway/modules/envioller/v1/files/`, the master will redeploy these.
