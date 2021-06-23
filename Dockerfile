FROM hexpm/elixir:1.12.1-erlang-23.3.4.4-ubuntu-focal-20210325

ENV REFRESHED_AT=2021-06-21 \
  LANG=en_US.UTF-8 \
  HOME=/opt/build \
  TERM=xterm

WORKDIR /opt/build
ARG DEBIAN_FRONTEND=noninteractive

RUN \
  apt-get update -y && \
  apt-get install -y git wget curl vim locales gnupg2 && \
  locale-gen en_US.UTF-8 && \
  curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh && \
  chmod +755 /opt/build/nodesource_setup.sh && \
  /opt/build/nodesource_setup.sh && \
  apt-get install -y nodejs && rm /opt/build/nodesource_setup.sh && \
  mix local.hex --force

CMD ["/bin/bash"]
