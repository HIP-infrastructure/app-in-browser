# app-in-browser

`app-in-browser` allows controlling 3D accelerated graphic servers in the browser that will display a set of apps.

In order to deploy `app-in-browser` on Ubuntu 20.04, follow these steps.


## Machine preparation
1. Install docker using this [guide](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04). Don't forget to enable the docker service using `sudo systemctl enable docker`.
2. Install docker-compose using this [guide](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04). Use docker-compose version `1.29.0`.
3. Clone the repository with `git clone https://github.com/HIP-infrastructure/app-in-browser.git`. If you can see this `README.md`, it means you already have access to the repository.
4. `cd`into the `app-in-browser` directory.
5. If you are using `app-in-browser` on `Pollux` or `Pollux-TDS`, you need to configure docker to use a non-standard `MTU` of `1450`. Uncomment the following lines of the `docker-compose.yml` file:
```yaml
driver_opts:
   com.docker.network.driver.mtu: 1450
```
and add the following to `/etc/docker/daemon.json`:
```json
{
  "mtu": 1450
}
```
then restart the docker service with `sudo systemctl restart docker`.

6. Install the recommended Nvidia drivers for your system. Check which ones they are using `ubuntu-drivers devices` and then install them using `sudo ubuntu-drivers autoinstall`.
7. Reboot the system with `sudo reboot` and check that the drivers are functional using `sudo nvidia-smi`. Additionnaly you can check the nvidia module is loaded with `lspci -nnk | grep -i nvidia`.
8. Install the backend with `./scripts/installbackend.sh`.
9. Generate credentials for the REST API of the backend with `./scripts/gencreds.sh`. 

## Building `app-in-browser`
1. Build the base images:
   * `docker-compose build vgl-base`
   * `docker-compose build matlab-runtime`
2. Build the server:
   * `docker-compose build xpra-server`
3. Build the apps:
   * `docker-compose build brainstorm`
   * ... more apps to be added ...
 
## Running `app-in-browser`
1. Launch the backend with `./scripts/launchbackend.sh`
2. Control servers using the following REST API:

http://`url`:8060/control/server?action=`action`&sid=`sid`&hipuser=`hipuser`

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
3. Control apps using the following REST API:

http://`url`:8060/control/app?action=`action`&app=`app`&sid=`sid`&aid=`aid`&hipuser=`hipuser`

where
   * `url`is the url of the server where the backend is running
   * `action` is one of:
      * `start`: start app
      * `stop`: stop app
      * `restart`: restart app
      * `destroy`: destroy app
      * `logs`: show app log
      * `status`: show app status
   * `app` is the canonical name of the app to control
   * `sid` is the server id onto which the app is mapped
   * `aid` is the app id
   * `hipuser` is the username of the `Nextcloud` `HIP` user
