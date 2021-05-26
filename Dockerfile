FROM ubuntu:20.04 AS cpuminer-build
# ENV CPUMINER_BRANCH=v2.5.1

RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install --yes autoconf automake build-essential \
 libgmp-dev libjansson-dev libcurl4-openssl-dev
# git
# RUN git config --global advice.detachedHead false
# RUN git clone --branch=$CPUMINER_BRANCH --depth=1 https://github.com/gautada/cpuminer.git
COPY cpuminer /cpuminer
WORKDIR /cpuminer
RUN ./autogen.sh
RUN ./configure CFLAGS="-O3"
RUN make




FROM ubuntu:20.04 AS xmrig-build
# ENV XMRIG_BRANCH=v6.12.1

RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
 build-essential cmake libuv1-dev libssl-dev libhwloc-dev
# git
# RUN git config --global advice.detachedHead false
# RUN git clone --branch=$XMRIG_BRANCH --depth=1 https://github.com/gautada/xmrig.git
COPY xmrig /xmrig
RUN mkdir /xmrig/build
WORKDIR /xmrig/build
RUN cmake .. && make




FROM ubuntu:20.04 AS proxy-build
# ENV XMRIGPROXY_BRANCH=v6.12.0
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install --yes build-essential cmake \
 libuv1-dev uuid-dev libmicrohttpd-dev libssl-dev
# RUN git config --global advice.detachedHead false
# RUN git clone --branch=$XMRIGPROXY_BRANCH --depth=1 https://github.com/gautada/xmrig-proxy.git
COPY xmrig-proxy /xmrig-proxy
RUN mkdir /xmrig-proxy/build
WORKDIR /xmrig-proxy/build
RUN cmake .. && make




FROM ubuntu:20.04
EXPOSE 3333
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install --yes libhwloc15 openssl libcurl4
COPY --from=xmrig-build /xmrig/build/xmrig /usr/bin/xmrig
COPY --from=xmrig-build /xmrig/scripts/randomx_boost.sh /randomx_boost.sh
COPY --from=proxy-build /xmrig-proxy/build/xmrig-proxy /usr/bin/xmrig-proxy
COPY --from=cpuminer-build /cpuminer/minerd /usr/bin/minerd                                                                                                                                                                          
COPY install-msr /install-msr                                                                                                                                             
RUN /install-msr      
# ENTRYPOINT ["/usr/bin/xmrig"]
# CMD ["tail", "-f", "/dev/null"]


