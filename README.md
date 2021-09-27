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

## Getting and configuring `app-in-browser`
1. Clone the repository with `git clone https://github.com/HIP-infrastructure/app-in-browser.git`. If you can see this `README.md`, it means you already have access to the repository.
2. `cd`into the `app-in-browser` directory.
3. If you are using `app-in-browser` on `CSCS`, you need to configure docker to use a non-standard `MTU` of `1450`. Uncomment the following line of the `.env` file:
```bash
MTU=1450
```
and add the following to `/etc/docker/daemon.json`:
```json
{
  "mtu": 1450,
}
```
then restart the docker service with `sudo systemctl restart docker`.

4. If you don't have a supported Nvidia graphics card, you need to the modify the `.env` file as follows:
```bash
CARD=none
RUNTIME=runc
```
5. If you have several graphics cards on your machine, you need to figure out which one is the Nvidia one and configure `app-in-browser` to use it. Change the `CARD` variable to match the output of
```bash
readlink -f /dev/dri/by-path/pci-0000:`lspci | grep NVIDIA | awk '{print $1}'`-card | xargs basename
```
6. Copy the backend environment template file with `cp backend/backend.env.template backend/backend.env` and modify the `BACKEND_DOMAIN` variable to the domain on which the backend is will be hosted.
7. Install and start the backend with `./scripts/installbackend.sh`.
8. Generate credentials for the REST API of the backend with `./scripts/gencreds.sh`. 
9. Build all docker images with `./scripts/buildall.sh`. Sit back as this will likely take some time :)
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
   * `start`: `./scripts/launchserver.sh sid hipuser`
   * `stop`: `./scripts/stopserver.sh sid hipuser`
   * `restart`: `./scripts/restartserver.sh sid hipuser`
   * `destroy`: `./scripts/destroyserver.sh sid hipuser`
   * `healthcheck`: `./scripts/checkserverhealth.sh sid hipuser`
   * `logs`: `./scripts/viewserverlogs.sh sid hipuser`
   * `status`: `./scripts/serverstatus.sh sid hipuser`
2. Apps:
   * `start`: `./scripts/launchapp.sh app sid aid hipuser hippass "nc"`
   * `stop`: `./scripts/stopapp.sh app sid aid hipuser`
   * `restart`: `./scripts/restartapp.sh app sid aid hipuser hippass "nc"`
   * `destroy`: `./scripts/destroyapp.sh app sid aid hipuser`
   * `healthcheck`: `./scripts/checkapphealth.sh app sid aid hipuser`
   * `logs`: `./scripts/viewapplogs.sh app sid aid hipuser`
   * `status`: `./scripts/appstatus.sh app sid aid hipuser`
