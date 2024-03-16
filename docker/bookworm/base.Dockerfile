FROM python:3.12 AS git
RUN git clone --recurse-submodules -j8 --depth 1 https://github.com/gnuboard/g6.git
WORKDIR /g6
ARG USER=g6
RUN useradd --create-home --shell /bin/bash ${USER}
RUN mkdir -p /g6/data
RUN chown -R ${USER}:${USER} /g6
# Encountering issues with the ownership change of the ./data directory.
# The exact cause is unclear, however, the COPY --chown option does not 
# seem to be working as expected for the ./data directory.
# As a result, we're utilising the RUN command to correctly set the ownership.
RUN find . -mindepth 1 -maxdepth 1 -name '.*' ! -name '.' ! -name '..' -exec bash -c 'echo "Deleting {}"; rm -rf {}' \;

FROM python:3.12 AS env-builder

RUN curl https://sh.rustup.rs -sSf | sh -s -- --profile minimal -y && \
    echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
ENV PATH "$HOME/.cargo/bin:$PATH"

ARG USER=g6
RUN useradd --create-home --shell /bin/bash ${USER}

COPY --from=git /g6/requirements.txt /g6/requirements.txt

WORKDIR /g6
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get -y --no-install-recommends install \
        locales \
        tini \
        cmake \
        ninja-build \
        build-essential \
        g++ \
        gobjc \
        meson \
        openssl \
        libssl-dev \
        libffi-dev \
        liblapack-dev \
        libblis-dev \
        libblas-dev \
        libopenblas-dev;

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales

RUN --mount=type=tmpfs,target=/root/.cargo \
    python3 -m venv /venv \
    && /venv/bin/python3 -m pip install --upgrade pip \
    && /venv/bin/python3 -m pip install -r requirements.txt
    
COPY --from=git --chown=${USER}:${USER} /g6 /standby-g6
