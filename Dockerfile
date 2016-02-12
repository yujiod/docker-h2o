FROM ubuntu:trusty

RUN apt update && apt upgrade -y && apt-get dist-upgrade -y
RUN apt install locate git cmake build-essential checkinstall autoconf pkg-config libtool python-sphinx wget libcunit1-dev nettle-dev libyaml-dev libuv-dev zlib1g-dev -y
RUN apt install ruby ruby-dev bison -y

WORKDIR /root

RUN git clone https://github.com/tatsuhiro-t/wslay.git --depth 1 \
    && cd wslay \
    && autoreconf -i \
    && automake \
    && autoconf \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf wslay

RUN wget -O h2o-latest.tar.gz  "$(wget -O - https://api.github.com/repos/h2o/h2o/releases/latest | grep tarball_url | head -n 1 | cut -d '"' -f 4)" \
    && tar xzf h2o-latest.tar.gz \
    && cd "$(ls | grep h2o-h2o)" \
    && cmake -DWITH_BUNDLED_SSL=on -DWITH_MRUBY=on . \
    && make \
    && make install \
    && cd .. \
    && rm -rf h2o*

RUN apt-get autoremove --purge -y && apt-get autoclean -y && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

VOLUME ["/etc/h2o", "/var/www"]

EXPOSE 80
EXPOSE 443

CMD h2o -c /etc/h2o/h2o.conf
