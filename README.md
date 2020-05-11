# Introdution
This dockerfile provides the services with nvidia-gpu, pytorch and rstudio-server.

This image is based on the `nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04`, you may need to select other CUDA versions, see https://hub.docker.com/r/nvidia/cuda/.


In addition, some additional packages have be installed for my personal used, thus, you may need some personalized customizations in this Dockerfile.


# Prerequistes
- Docker
- [nvidia-docker2](https://github.com/NVIDIA/nvidia-docker)



# References

https://github.com/rocker-org/rocker/blob/dd21f0b706/r-apt/xenial/Dockerfile

https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/3.5.2/Dockerfile

