# Build the image by the following command:
#   docker build -t <image_name>:<tag> .
FROM nvidia/cuda:11.2.0-devel-ubuntu20.04 AS builder
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /root
RUN apt-get update && \
    apt-get install -y --no-install-recommends cmake wget python3 \
    python3-dev python3-pip

RUN pip3 install --upgrade pip setuptools wheel cmake pybind11

# Install Gromacs 2022.3 and its Python API
RUN wget https://ftp.gromacs.org/gromacs/gromacs-2022.3.tar.gz && \
    tar xvf gromacs-2022.3.tar.gz && \
    cd gromacs-2022.3 && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_C_COMPILER=gcc \
             -DCMAKE_CXX_COMPILER=g++ \
             -DGMX_MPI=off \
             -DGMX_GPU=CUDA \
             -DGMX_BUILD_OWN_FFTW=ON -DGMX_SIMD=AVX2_256 \
             -DCMAKE_BUILD_TYPE=Release && \
    make -j4 install
RUN gmxapi_ROOT=/usr/local/gromacs/ pip3 install --no-cache-dir gmxapi

FROM nvidia/cuda:11.2.0-runtime-ubuntu20.04
COPY --from=builder /usr/local/gromacs /usr/local/gromacs
COPY --from=builder /usr/local/lib/python3.8/dist-packages /usr/local/lib/python3.8/dist-packages

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 vim ssh sudo python3 python3-dev python3-pip curl \
    wget python-is-python3 build-essential
RUN pip3 install --upgrade notebook numpy scipy matplotlib pandas \
    mdtraj py3DMol
ENV PATH=$PATH:/usr/local/gromacs/bin

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

RUN useradd -ms /bin/bash gromacs && \
    usermod -aG sudo gromacs
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

EXPOSE 8888
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0"]