FROM ubuntu:20.04 AS xmrig-source

RUN apt-get update 

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y git \
 build-essential cmake libuv1-dev libssl-dev libhwloc-dev 

RUN git clone https://github.com/xmrig/xmrig.git

RUN mkdir /xmrig/build

WORKDIR /xmrig/build

RUN cmake .. && make

FROM ubuntu:20.04

RUN apt-get update

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y libhwloc15 openssl

COPY --from=xmrig-source /xmrig/build/xmrig /usr/bin/xmrig

ENTRYPOINT ["/usr/bin/xmrig"]


