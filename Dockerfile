FROM micromamba:cuda12.1.1-ubuntu22.04

ARG MAMBA_DOCKERFILE_ACTIVATE=1

USER root

RUN apt-get update && apt-get install -y git

USER $MAMBA_USER

COPY --chown=$MAMBA_USER:$MAMBA_USER . /app/pxdesign

WORKDIR /app/pxdesign

# ENV_NAME=pxdesign
RUN bash -x install.sh --env pxdesign --pkg_manager micromamba --cuda-version 12.1
