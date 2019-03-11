# Links

## Build for release

To build for a release, run the following commands from the root directory:

* `docker build -t elixir-ubuntu:latest .`
* `docker run -v $(pwd):/opt/build --rm -it elixir-ubuntu:latest /opt/build/bin/build`

## Deploy

To deploy, `scp` the tarball to the server, `scp _build/docker/rel/links-0.1.0.tar.gz <your username>@<production server domain>:<target directory>`

Then, unpack the tarball and start the process, `rm -rf /var/www/links/ && mkdir /var/www/links && tar -xzf links-0.1.0.tar.gz -C /var/www/links`