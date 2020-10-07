FROM ubuntu:16.04

ENV REFRESHED_AT=2020-09-07 \
  LANG=en_US.UTF-8 \
  HOME=/opt/build \
  TERM=xterm

WORKDIR /opt/build

RUN \
  apt-get update -y && \
  apt-get install -y git wget vim locales && \
  locale-gen en_US.UTF-8 && \
  wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && \
  dpkg -i erlang-solutions_2.0_all.deb && \
  rm erlang-solutions_2.0_all.deb && \
  apt-get update -y && \
  apt-get install -y erlang elixir curl && \
  curl -sL https://deb.nodesource.com/setup_13.x | bash - && \
  apt-get install -y nodejs

CMD ["/bin/bash"]
