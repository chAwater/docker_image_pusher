FROM pytorch/pytorch:2.1.2-cuda12.1-cudnn8-devel

ENV DEBIAN_FRONTEND=noninteractive


# Common CLI tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    vim && \
    rm -rf /var/lib/apt/lists/*

# Install PXDesign
WORKDIR /app
COPY . /app/pxdesign
WORKDIR /app/pxdesign

# Install dependencies
# 1. Install PXDesignBench from source (not on PyPI, caused previous failure)
# 2. Remove pxdbench/protenix from requirements.txt to avoid PyPI resolution errors
# 3. Install remaining requirements
# 4. Install PXDesign in editable mode
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir "git+https://github.com/bytedance/PXDesignBench.git" && \
    (sed -i -e '/pxdbench/d' -e '/protenix/d' requirements.txt || true) && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir -e .