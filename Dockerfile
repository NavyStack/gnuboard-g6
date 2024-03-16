FROM python:3.12 AS git

RUN curl https://sh.rustup.rs -sSf | sh -s -- --profile minimal -y && \
    echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
ENV PATH "$HOME/.cargo/bin:$PATH"

ARG user=g6
RUN useradd --create-home --shell /bin/bash $user

RUN git clone --recurse-submodules -j8 --depth 1 https://github.com/gnuboard/g6.git

WORKDIR /g6

RUN mkdir -p /g6/data
RUN chown -R $user:$user /g6
# Encountering issues with the ownership change of the ./data directory.
# The exact cause is unclear, however, the COPY --chown option does not 
# seem to be working as expected for the ./data directory.
# As a result, we're utilising the RUN command to correctly set the ownership.
RUN find . -mindepth 1 -maxdepth 1 -name '.*' ! -name '.' ! -name '..' -exec bash -c 'echo "Deleting {}"; rm -rf {}' \;

FROM python:3.12 AS env-builder

ARG user=g6
RUN useradd --create-home --shell /bin/bash $user

COPY --from=git --chown=$user:$user /g6/requirements.txt /g6/requirements.txt

WORKDIR /g6
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
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

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
RUN dpkg-reconfigure --frontend=noninteractive locales
RUN python3 -m venv /venv
RUN /venv/bin/python3 -m pip install --upgrade pip
RUN --mount=type=tmpfs,target=/root/.cargo \
    /venv/bin/python3 -m pip install -r requirements.txt
RUN find . -type f \( -name '__pycache__' -o -name '*.pyc' -o -name '*.pyo' \) -exec bash -c 'echo "Deleting {}"; rm -f {}' \;

FROM python:3.12-slim-bookworm AS final

ARG user=g6
RUN useradd --create-home --shell /bin/bash $user

COPY --from=git --chown=$user:$user /g6 /g6
COPY --from=env-builder --chown=$user:$user /venv /venv
COPY --from=env-builder --chown=$user:$user /usr/bin/tini /usr/bin/tini

USER g6
WORKDIR /g6
VOLUME /g6/data
EXPOSE 8000

ENTRYPOINT ["tini", "--"]
# Utilising tini as our init system within the Docker container for graceful start-up and termination.
# Tini serves as an uncomplicated init system, adept at managing the reaping of zombie processes and forwarding signals.
# This approach is crucial to circumvent issues with unmanaged subprocesses and signal handling in containerised environments.
# By integrating tini, we enhance the reliability and stability of our Docker containers.
# Ensures smooth start-up and shutdown processes, and reliable, safe handling of signal processing.

CMD ["/venv/bin/uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
