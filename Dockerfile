ARG CUDA_VERSION=10.2
ARG RAPIDS_VERSION=0.18
ARG OS_PLATFORM=ubuntu18.04
FROM nvcr.io/nvidia/cuda:${CUDA_VERSION}-base-${OS_PLATFORM}

# Labels
LABEL org.opencontainers.image.authors="Don Chesworth <donald.chesworth@gmail.com>"
LABEL org.opencontainers.image.url="https://github.com/donchesworth/rapids-dask-pytorch-images"
LABEL org.opencontainers.image.source="https://github.com/donchesworth/rapids-dask-pytorch-images"
LABEL org.opencontainers.image.version="py38-cuda10.2-rapids0.18-ubuntu18.04"

# Install gcc, postgres, conda
ENV PATH="/opt/conda/envs/rd/bin:/opt/conda/bin:$PATH"
RUN apt-get update && apt-get -y install wget && \
    apt-get install -y --no-install-recommends build-essential libpq-dev && \
    wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    chmod +x ~/miniconda.sh &&  ~/miniconda.sh -b -p /opt/conda && conda update conda

# conda package installs
RUN conda create -n rd python=3.8 && \
    conda install --name rd -c rapidsai -c nvidia -c conda-forge -c defaults \
    cudf=${RAPIDS_VERSION} cuml=${RAPIDS_VERSION} dask-cudf=${RAPIDS_VERSION} \
    dask-cuda=${RAPIDS_VERSION} cudatoolkit=${CUDA_VERSION} && \
    conda clean --all

# Setup working dir
WORKDIR /opt/rd
RUN chgrp -R 0 /opt/rd/ && \
    chmod -R g+rwX /opt/rd/

