FROM quay.io/uninuvola/base:main

# DO NOT EDIT USER VALUE
USER root

## -- ADD YOUR CODE HERE !! -- ##
## 1. -- UniNuvola conda
ENV PATH="/opt/conda/bin:${PATH}"
ENV JUPYTER_PATH="/usr/local/share/jupyter/kernels"

RUN echo "/opt/conda/bin/conda init > /dev/null " >> /etc/profile.d/conda.sh && \
    echo "exec /bin/bash" >> /etc/profile

## 2. -- Pytorch GPU 

# install CuDA-toolkit
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && apt update && apt install -y cuda-toolkit

RUN conda create -n MTK -y python=3.11.5 \
    pytorch torchvision torchaudio pytorch-cuda=12.4 \
    numpy scipy pandas h5py tqdm matplotlib seaborn scikit-learn umap-learn \
    ipykernel \
    -c pytorch -c nvidia && \
    conda clean -afy && \
    conda init && \
    /opt/conda/envs/MTK/bin/python -m ipykernel install \
        --name MTK \
        --display-name MTK && \
    /opt/conda/bin/conda shell.bash deactivate

WORKDIR /app
RUN apt update && apt install -y fuse libfuse2 && \
    wget https://github.com/Syllo/nvtop/releases/download/3.1.0/nvtop-x86_64.AppImage && \
    chmod u+x  nvtop-x86_64.AppImage  && ./nvtop-x86_64.AppImage --appimage-extract && \
    ln  /app/squashfs-root/usr/bin/nvtop /usr/local/bin/. &&\
    cp  /app/squashfs-root/usr/lib/*  /usr/local/lib/. &&\
    chmod 755 /usr/local/bin/nvtop

    # Install Julia 1.10.4
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.12/julia-1.12.5-linux-x86_64.tar.gz \
    && tar -xzf julia-1.12.5-linux-x86_64.tar.gz \
    && mv julia-1.12.5 /opt/julia-1.12 \
    && rm julia-1.12.5-linux-x86_64.tar.gz


# Add Julia to PATH
ENV PATH="/opt/julia-1.12/bin:$PATH"

# Verify Julia installation
RUN julia --version

## --------------------------- ##
#HOMEBREWD version - TODO try to install a proper release 
#https://anaconda.org/channels/conda-forge/packages/flash-attn/overview
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb && \
    /opt/conda/bin/conda clean -afy


RUN echo "/opt/conda/bin/conda init > /dev/null " >> /etc/profile.d/conda.sh && \
    echo "export PATH=\"$PATH:/usr/local/cuda-13.0/bin\" " >> /etc/profile.d/cudatoolkit.sh && \
    echo "exec /bin/bash" >> /etc/profile

