# syntax=docker/dockerfile:1

FROM debian:bookworm AS builder
ARG FREEBAYES_VERSION=v1.3.10

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        cmake \
        g++ \
        git \
        libfastahack-dev \
        libhts-dev \
        libseqlib-dev \
        libsmithwaterman-dev \
        libtabixpp-dev \
        libvcflib-dev \
        libwfa2-dev \
        libbz2-dev \
        liblzma-dev \
        make \
        meson \
        ninja-build \
        pkg-config \
        python3 \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 --branch "${FREEBAYES_VERSION}" --recursive https://github.com/freebayes/freebayes.git

WORKDIR /src/freebayes
RUN meson setup build --buildtype release \
    && ninja -C build \
    && install -d /out/usr/local/bin \
    && install -m755 build/freebayes /out/usr/local/bin/freebayes

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libbz2-1.0 \
        libdisorder0 \
        libfastahack0 \
        libfml0 \
        libhts3 \
        libhtscodecs2 \
        libjsoncpp25 \
        liblzma5 \
        libseqlib2 \
        libsmithwaterman0 \
        libssw0 \
        libtabixpp0 \
        libvcflib1 \
        libwfa2-0 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /out/ /

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/freebayes"]
CMD ["--help"]
