FROM ubuntu:22.04

ARG ERLANG_VERSION
ARG RABBITMQ_VERSION

RUN apt-get update && \
    apt-get install -y \
      curl \
      gnupg \
      apt-transport-https


RUN curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | apt-key add \
    && \
    curl -1sLf https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/gpg.9F4587F226208342.key | apt-key add \
    && \
    curl -1sLf https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/gpg.E495BB49CC4BBE5B.key | apt-key add  \
    && \
    echo "deb https://ppa1.novemberain.com/rabbitmq/rabbitmq-erlang/deb/ubuntu jammy main" > /etc/apt/sources.list.d/rabbitmq.list \
    && \
    echo "deb https://ppa1.novemberain.com/rabbitmq/rabbitmq-server/deb/ubuntu jammy main" >> /etc/apt/sources.list.d/rabbitmq.list \
    && \
    apt-get update

RUN echo "\
Package: erlang* \n\
Pin: version ${ERLANG_VERSION} \n\
Pin-Priority: 1001 \n\
\n\
Package: rabbitmq-server \n\
Pin: version ${RABBITMQ_VERSION} \n\
Pin-Priority: 1001 \n\
" > /etc/apt/preferences.d/rabbitmq

RUN apt-get install -y \
      erlang=${ERLANG_VERSION} \
      erlang-asn1=${ERLANG_VERSION} \
      erlang-crypto=${ERLANG_VERSION} \
      erlang-public-key=${ERLANG_VERSION} \
      erlang-ssl=${ERLANG_VERSION} \
      rabbitmq-server=${RABBITMQ_VERSION}

RUN rabbitmq-plugins enable --offline rabbitmq_management

WORKDIR /var/lib/rabbitmq
USER rabbitmq
ENTRYPOINT ["rabbitmq-server"]