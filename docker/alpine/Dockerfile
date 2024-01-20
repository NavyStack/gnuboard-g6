FROM python:bookworm AS git
RUN git clone --recurse-submodules -j8 --depth 1 https://github.com/gnuboard/g6.git
WORKDIR /g6
ARG user=g6
RUN useradd --create-home --shell /bin/bash $user
RUN mkdir -p /g6/data
RUN chown -R $user:$user /g6
RUN find . -mindepth 1 -maxdepth 1 -name '.*' ! -name '.' ! -name '..' -exec bash -c 'echo "Deleting {}"; rm -rf {}' \;

# Encountering issues with the ownership change of the ./data directory.
# The exact cause is unclear, however, the COPY --chown option does not 
# seem to be working as expected for the ./data directory.
# As a result, we're utilising the RUN command to correctly set the ownership.

FROM python:alpine AS env-builder
COPY --from=git /g6/requirements.txt /g6/requirements.txt
WORKDIR /g6

RUN apk add --no-cache \
    build-base \
    tini \
    libffi-dev

RUN python3 -m venv /venv
RUN /venv/bin/python3 -m pip install -r requirements.txt -vvv
RUN find . -type f \( -name '__pycache__' -o -name '*.pyc' -o -name '*.pyo' \) -exec rm -f {} \;

FROM python:alpine AS final

ARG user=g6
RUN adduser -D $user

COPY --from=git --chown=$user:$user /g6 /g6
COPY --from=env-builder --chown=$user:$user /venv /venv
COPY --from=env-builder --chown=$user:$user /sbin/tini /sbin/tini

USER $user
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
