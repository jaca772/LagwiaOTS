FROM ubuntu:20.04 AS build

ENV DEBIAN_FRONTEND=noninteractive TZ=Europe/Warsaw

RUN apt-get update && apt-get install -y \
    tzdata \
    build-essential \
    cmake \
    git \
    libboost-all-dev \
    libssl-dev \
    libmysqlclient-dev \
    lua5.1-dev \
    liblua5.3-dev \
    libpugixml-dev \
    libcrypto++-dev \
    liblua5.3-0 \
    libfmt-dev \
    libgmp-dev \
    && rm -rf /var/lib/apt/lists/*

COPY cmake /usr/src/forgottenserver/cmake/
COPY src /usr/src/forgottenserver/src/
COPY CMakeLists.txt /usr/src/forgottenserver/

WORKDIR /usr/src/forgottenserver/build
RUN cmake .. && make

FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive TZ=Europe/Warsaw
RUN apt-get update && apt-get install -y \
    libboost-system1.71.0 \
    libboost-filesystem1.71.0 \
    libboost-iostreams1.71.0 \
    libssl1.1 \
    libmysqlclient21 \
    liblua5.1 \
    libpugixml-dev \
    libcrypto++6 \
    libfmt-dev \
    zlib1g \
    libomp5 \
    && apt-get clean

COPY --from=build /usr/src/forgottenserver/build/tfs /bin/tfs
COPY data /srv/data/
COPY config.lua *.sql /srv/

EXPOSE 7171 7172
WORKDIR /srv
VOLUME /srv

ENTRYPOINT ["/bin/tfs"]