FROM python:3.12 AS git
RUN git clone --recurse-submodules -j8 --depth 1 https://github.com/gnuboard/g6.git

FROM navystack/gnuboard-g6:base-nightly AS base
RUN rm -rf /g6/requirements.txt
COPY --from=git --chown=${USER}:${USER} /g6/requirements.txt /g6/requirements.txt

RUN /venv/bin/python3 -m pip install -r requirements.txt
RUN find . -type f \( -name '__pycache__' -o -name '*.pyc' -o -name '*.pyo' \) -exec bash -c 'echo "Deleting {}"; rm -f {}' \;

FROM python:3.12-slim-bookworm AS final

ARG USER=g6
RUN useradd --create-home --shell /bin/bash ${USER}

COPY --from=base --chown=${USER}:${USER} /standby-g6 /g6
COPY --from=base --chown=${USER}:${USER} /venv /venv
COPY --from=base --chown=${USER}:${USER} /usr/bin/tini /usr/bin/tini

USER g6
WORKDIR /g6
VOLUME /g6
EXPOSE 8000

ENTRYPOINT ["tini", "--"]
# Utilising tini as our init system within the Docker container for graceful start-up and termination.
# Tini serves as an uncomplicated init system, adept at managing the reaping of zombie processes and forwarding signals.
# This approach is crucial to circumvent issues with unmanaged subprocesses and signal handling in containerised environments.
# By integrating tini, we enhance the reliability and stability of our Docker containers.
# Ensures smooth start-up and shutdown processes, and reliable, safe handling of signal processing.

CMD ["/venv/bin/uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
