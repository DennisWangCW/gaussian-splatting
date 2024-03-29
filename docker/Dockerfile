# Use the base image with PyTorch and CUDA support
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-devel


# NOTE:
# Building the libraries for this repository requires cuda *DURING BUILD PHASE*, therefore:
# - The default-runtime for container should be set to "nvidia" in the deamon.json file. See this: https://github.com/NVIDIA/nvidia-docker/issues/1033
# - For the above to work, the nvidia-container-runtime should be installed in your host. Tested with version 1.14.0-rc.2
# - Make sure NVIDIA's drivers are updated in the host machine. Tested with 525.125.06



# Trouble: https://github.com/ceres-solver/ceres-solver/issues/1049
# Edit  edited /usr/local/lib/cmake/Ceres/FindGlog.cmake line 348 with
## if(NOT TARGET glog::glog)
##    add_library(glog::glog INTERFACE IMPORTED)
##    target_include_directories(glog::glog INTERFACE ${GLOG_INCLUDE_DIRS})
##    target_link_libraries(glog::glog INTERFACE ${GLOG_LIBRARY})
## endif()


ENV DEBIAN_FRONTEND=noninteractive

ARG TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6"

# Update and install some dependencies
RUN apt update && apt install -y tzdata curl wget vim locate git && apt clean && rm -rf /var/lib/apt/lists/*


# Install nerfstudio
WORKDIR /workspace
RUN git clone https://github.com/nerfstudio-project/nerfstudio.git
RUN cd nerfstudio && pip install --upgrade pip setuptools && pip install -e .

# Build colmap first
WORKDIR /workspace
RUN apt update && apt install -y imagemagick
RUN apt update && apt install -y libgl1-mesa-dev libcgal-dev libboost-all-dev libflann-dev qt5-default libmetis-dev \
    libglew-dev libfreeimage-dev libceres-dev && apt clean && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/colmap/colmap
RUN mkdir colmap/build
WORKDIR /workspace/colmap/build
RUN echo "set_target_properties(colmap_main PROPERTIES BUILD_WITH_INSTALL_RPATH TRUE \
    INSTALL_RPATH /usr/lib/x86_64-linux-gnu:/opt/conda/lib)" >> ../src/colmap/exe/CMakeLists.txt
RUN cmake .. -DCMAKE_CUDA_ARCHITECTURES="60;70;80;86" #-DCUDA_ENABLED=OFF 
RUN make -j8
RUN make install
RUN echo "export PATH=$PATH:/workspace/colmap/build/src/colmap/exe" >> /root/.bashrc

# Create a workspace directory and clone the repository
WORKDIR /workspace
RUN git clone https://github.com/graphdeco-inria/gaussian-splatting --recursive

# Create a Conda environment and activate it
WORKDIR /workspace/gaussian-splatting

RUN conda env create --file environment.yml && conda init bash && exec bash && conda activate gaussian_splatting

# Make gaussian_splatting the default environment on start
RUN echo "conda activate gaussian_splatting" >> /root/.bashrc

# Tweak the CMake file for matching the existing OpenCV version. Fix the naming of FindEmbree.cmake
WORKDIR /workspace/gaussian-splatting/SIBR_viewers/cmake/linux
RUN sed -i 's/find_package(OpenCV 4\.5 REQUIRED)/find_package(OpenCV 4.2 REQUIRED)/g' dependencies.cmake
RUN sed -i 's/find_package(embree 3\.0 )/find_package(EMBREE)/g' dependencies.cmake
# RUN mv /workspace/gaussian-splatting/SIBR_viewers/cmake/linux/Modules/FindEmbree.cmake /workspace/gaussian-splatting/SIBR_viewers/cmake/linux/Modules/FindEMBREE.cmake

# Fix the naming of the embree library in the rayscaster's cmake
RUN sed -i 's/\bembree\b/embree3/g' /workspace/gaussian-splatting/SIBR_viewers/src/core/raycaster/CMakeLists.txt

# Ready to build the viewer now.
WORKDIR /workspace/gaussian-splatting/SIBR_viewers 
RUN apt update && \
    apt install -y libglew-dev libassimp-dev libboost-all-dev libgtk-3-dev libopencv-dev libglfw3-dev libavdevice-dev \
    libavcodec-dev libeigen3-dev libxxf86vm-dev libembree-dev && \
    apt clean && rm -rf /var/lib/apt/lists/*

RUN cmake -Bbuild . -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build -j24 --target install

RUN echo "export PATH=$PATH:/workspace/gaussian-splatting/SIBR_viewers/install/bin" >> /root/.bashrc
RUN echo "export MESA_GL_VERSION_OVERRIDE=4.5" >> /root/.bashrc

# install point cloud library to view .ply file
RUN apt update && apt install -y libpcl-dev pcl-tools && apt clean && rm -rf /var/lib/apt/lists/*

# RUN echo "conda activate gaussian_splatting" >> /root/.bashrc
WORKDIR /workspace

