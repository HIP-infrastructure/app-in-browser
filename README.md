# app-in-browser

`app-in-browser` allows controlling 3D accelerated graphic servers in the browser that will display a set of apps. Additionally, it mounts `Nextcloud` homedirs and group folders into the app containers.

In order to deploy `app-in-browser` on Ubuntu 20.04, follow these steps.


## Machine preparation
1. Install `docker` using this [guide](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04). Don't forget to enable the docker service using `sudo systemctl enable docker`.
2. Install `Node.js` using the following commands:
```bash
curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
sudo apt-get install -y nodejs
```

## Docker configuration
1. By default, docker only allows to create 32 bridge networks. As each server uses two of them, you'll only be able to start 16 servers with the default configuration. To bump this number to 256 servers, add the following to `/etc/docker/daemon.json`:
```json
{
   "default-address-pools":[
      {
         "base":"172.17.0.0/12",
         "size":20
      },
      {
         "base":"192.168.0.0/16",
         "size":24
      }
   ]
}
```
then restart the docker service with `sudo systemctl restart docker`.

## GPU support setup (optional)
1. Install the recommended Nvidia drivers for your system. Check which ones are recommended using the command `ubuntu-drivers devices` and then install them using `sudo ubuntu-drivers autoinstall`.
2. Reboot the system with `sudo reboot` and check that the drivers are functional using `sudo nvidia-smi`. Additionnaly you can check that the nvidia module is loaded with `lspci -nnk | grep -i nvidia`.
3. Install the nvidia-docker runtime stable repository and GPG key:
```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
```
4. Run `sudo apt-get update` and then install the runtime with `sudo apt-get install -y nvidia-docker2`.
5. Finally restart the docker service with `sudo systemctl restart docker`.
6. You can test your installation is working by running the following image `sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi` and getting the same output as in step 2 above.
7. You might want to deactivate kernel automatic upgrades:
```bash
sudo apt-get remove linux-image-virtual
sudo apt-get autoremove
```

## Getting `app-in-browser`
1. Clone the repository with `git clone --recurse-submodules https://github.com/HIP-infrastructure/app-in-browser.git`. If you can see this `README.md`, it means you already have access to the repository.
2. `cd` into the `app-in-browser` directory.
3. Change to the branch of your liking. If unsure use the `master` branch.
4. Run `./build/submodule_branch.sh [branch_name]` to get the right version of the submodules.

## Configuring `app-in-browser`
1. Run `cp hip.config.template.yml hip.config.yml` to copy the config file from its template.
2. Edit the config file as specified in the next points.
3. If you don't have a supported Nvidia graphics card, you need to edit these settings:
```yaml
backend:
  dri:
    card: none
    runtime: runc
```
4. If you have several graphics cards on your machine, you need to figure out which one is the Nvidia one and configure `app-in-browser` to use it. Change the `card` variable above to match the output of
```bash
readlink -f /dev/dri/by-path/pci-0000:`lspci | grep NVIDIA | awk '{print $1}'`-card | xargs basename
```

5. Edit the ['backend']['auth'] settings with the credentials generated on the frontend.
6. If you'd like to use `keycloak`, enter the `keycloak` client information and set to `['server']['keycloak']['auth']` to `yes`.
7. Put the `tls` certificates you generated on the frontend and collab in `['base']['dockerfs']['cert_private']` and `['base']['dockerfs']['cert_collab']` respectively. The certificates need to be transformed to single lines. You can use the following command:
```bash
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' /path/to/cert.pem
```
8. Copy the backend environment template file with `cp backend/backend.env.template backend/backend.env` and modify the `BACKEND_DOMAIN` variable to the domain on which the backend is will be hosted.
9. Install the HIP backend with `./scripts/install.sh`. This script will interactively generate credentials for the REST API of the backend if they don't already exist.
10. Check that the backend is running with `./scripts/backendstatus.sh` and by checking https://`url`/api/ok.
 
## Using `app-in-browser`
There are two options to control `app-in-browser`. You can use the REST API, or bash scripts. The former is used for integration and the latter option can be used for debug.

### REST API
1. Control servers using the following REST API:

https://`url`/api/control/server?action=`action`&sid=`sid`&hipuser=`hipuser`

where
   * `url`is the url of the server where the backend is running
   * `action` is one of:
      * `start`: start server
      * `pause`: pause server
      * `resume`: resume server
      * `start`: start server 
      * `start`: start server
      * `stop`: stop server
      * `restart`: restart server
      * `destroy`: destroy server
      * `logs`: show server log
      * `status`: show server status
   * `sid` is the server id
   * `hipuser` is the username of the `Nextcloud` `HIP` user
2. Start and restart apps use the following REST API:

https://`url`/api/control/app?action=`action`&app=`app`&sid=`sid`&aid=`aid`&hipuser=`hipuser`&hippass=`hippass`&nc=`https://example.com`

where
   * `url`is the url of the server where the backend is running
   * `action` is one of:
      * `start`: start app
      * `restart`: restart app
   * `app` is the canonical name of the app to control
   * `sid` is the server id onto which the app is mapped
   * `aid` is the app id
   * `hipuser` is the username of the `Nextcloud` `HIP` user
   * `hippass` is the password of the `Nextcloud` `HIP` user
   * `nc` is the complete url of the `Nextcloud` instance to connect to
 3. For all other actions to control apps use the following REST API:

https://`url`/api/control/app?action=`action`&app=`app`&sid=`sid`&aid=`aid`&hipuser=`hipuser`

where
   * `url`is the url of the server where the backend is running
   * `action` is one of:
      * `pause`: pause app
      * `resume`: resume app
      * `stop`: stop app
      * `destroy`: destroy app
      * `logs`: show app log
      * `status`: show app status
   * `app` is the canonical name of the app to control
   * `sid` is the server id onto which the app is mapped
   * `aid` is the app id
   * `hipuser` is the username of the `Nextcloud` `HIP` user

### Bash scripts
You can launch servers and apps using the following bash scripts from the `app-in-browser` directory. The parameters are as described above.
1. Servers:
   * start: `./scripts/startserver.sh sid hipuser auth_groups`
   * pause: `./scripts/pauseserver.sh sid hipuser`
   * resume: `./scripts/unpauseserver.sh sid hipuser`
   * stop: `./scripts/stopserver.sh sid hipuser`
   * restart: `./scripts/restartserver.sh sid hipuser`
   * destroy: `./scripts/destroyserver.sh sid hipuser`
   * healthcheck: `./scripts/checkserverhealth.sh sid hipuser`
   * logs: `./scripts/viewserverlogs.sh sid hipuser`
   * status: `./scripts/serverstatus.sh sid hipuser`
2. Apps:
   * start: `./scripts/startapp.sh app sid aid hipuser hippass "nc" "ab" group_folders`
   * pause: `./scripts/pauseapp.sh app sid aid hipuser`
   * resume: `./scripts/unpause.sh app sid aid hipuser`
   * stop: `./scripts/stopapp.sh app sid aid hipuser`
   * restart: `./scripts/restartapp.sh app sid aid hipuser hippass "nc" "ab" group_folders`
   * destroy: `./scripts/destroyapp.sh app sid aid hipuser`
   * healthcheck: `./scripts/checkapphealth.sh app sid aid hipuser`
   * logs: `./scripts/viewapplogs.sh app sid aid hipuser`
   * status: `./scripts/appstatus.sh app sid aid hipuser`
