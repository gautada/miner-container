FROM alpine:3.12.1 as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:3.12.1 as cpuminor-build

RUN apk add --no-cache autoconf \
                       automake \
                       build-base \
                       git \
                       curl-dev \
                       gmp-dev \
                       jansson-dev \
                       libressl-dev 

RUN git clone --depth 1 https://github.com/pooler/cpuminer.git
WORKDIR /cpuminer
RUN ./autogen.sh
RUN ./configure CFLAGS="-O3"
RUN make

# RUN git clone --depth 1 https://github.com/gautada/cpuminer-multi.git cpuminer
# RUN git clone --branch linux --depth 1 https://github.com/gautada/cpuminer-multi.git
# WORKDIR /cpuminer-multi
#
# RUN ./autogen.sh
# RUN ./configure CFLAGS="-march=native" --with-crypto --with-curl  
# RUN make

FROM alpine:3.12.1

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone
COPY --from=cpuminor-build /cpuminer/minerd /usr/bin/minerd

RUN apk add --no-cache jansson libcurl procps

ENTRYPOINT ["/usr/bin/minerd"]
