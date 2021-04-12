# app-in-browser

`app-in-browser` allows controlling 3D accelerated graphic servers in the browser that will display a set of apps.

In order to deploy `app-in-browser` on Ubuntu 20.04, follow these steps.


## Machine preparation
1. Install docker using this [guide](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04). Don't forget to enable the docker service using `sudo systemctl enable docker`.
2. Install docker-compose using this [guide](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04). Use docker-compose version `1.29.0`.


## Deployment
1. Clone the repository with `git clone https://github.com/HIP-infrastructure/app-in-browser.git`. If you can see this `README.md`, it means you already have access to the repository.
2. `cd`into the `app-in-browser` directory.
3. If you are using `app-in-browser` on `Pollux` or `Pollux-TDS`, you need to configure docker to use a non-standard `MTU` of `1450`. Uncomment the following lines of the `docker-compose.yml` file:
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

4. Build the base images:
  * `docker-compose build vgl-base`
  * `docker-compose build matlab-runtime`
  * ... to be continued ...
