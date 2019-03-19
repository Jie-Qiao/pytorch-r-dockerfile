# Introdution
This dockerfile provides the services for nvidia-gpu support, pytorch and rstudio server.

This image is built based on the `nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04`, you may need to select the right CUDA version, see https://hub.docker.com/r/nvidia/cuda/.


In addition, some additional packages have be installed for my personal used, thus, you may need some personalized customizations in this Dockerfile.


# Prerequistes
- Docker
- [nvidia-docker2](https://github.com/NVIDIA/nvidia-docker)



# References

https://github.com/rocker-org/rocker/blob/dd21f0b706/r-apt/xenial/Dockerfile

https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/3.5.2/Dockerfile

