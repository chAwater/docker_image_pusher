FROM mambaorg/micromamba:cuda12.1.1-ubuntu22.04 as micromamba

FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

ARG MAMBA_DOCKERFILE_ACTIVATE=1

USER root

RUN apt-get update && apt-get install -y git

# if your image defaults to a non-root user, then you may want to make the
# next 3 ARG commands match the values in your image. You can get the values
# by running: docker run --rm -it my/image id -a
ARG MAMBA_USER=mambauser
ARG MAMBA_USER_ID=57439
ARG MAMBA_USER_GID=57439
ENV MAMBA_USER=$MAMBA_USER
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"
ENV CUTLASS_PATH="/app/cutlass"

COPY --from=micromamba "$MAMBA_EXE" "$MAMBA_EXE"
COPY --from=micromamba /usr/local/bin/_activate_current_env.sh /usr/local/bin/_activate_current_env.sh
COPY --from=micromamba /usr/local/bin/_dockerfile_shell.sh /usr/local/bin/_dockerfile_shell.sh
COPY --from=micromamba /usr/local/bin/_entrypoint.sh /usr/local/bin/_entrypoint.sh
COPY --from=micromamba /usr/local/bin/_dockerfile_initialize_user_accounts.sh /usr/local/bin/_dockerfile_initialize_user_accounts.sh
COPY --from=micromamba /usr/local/bin/_dockerfile_setup_root_prefix.sh /usr/local/bin/_dockerfile_setup_root_prefix.sh

RUN /usr/local/bin/_dockerfile_initialize_user_accounts.sh && \
    /usr/local/bin/_dockerfile_setup_root_prefix.sh

RUN git clone -b v3.5.1 https://github.com/NVIDIA/cutlass.git "/app/cutlass"

USER $MAMBA_USER

COPY --chown=$MAMBA_USER:$MAMBA_USER . /app/pxdesign

WORKDIR /app/pxdesign

# ENV_NAME=pxdesign
RUN bash -x install.sh --env pxdesign --pkg_manager micromamba --cuda-version 12.1

SHELL ["/usr/local/bin/_dockerfile_shell.sh"]

ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]

# You can modify the CMD statement as needed....
CMD ["/bin/bash"]
