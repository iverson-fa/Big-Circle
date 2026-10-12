# 环境搭建

1. 安装 CUDA 10.0

- step1: remove nvidia
    ```shell
    sudo apt-get remove --purge nvidia*
    ```

- step2:  install cuda 10.0

    下载链接: [cuda-repo-ubuntu1804_10.0.130-1_amd64.deb](https://pan.baidu.com/s/1sPDjRRlXWx5HOWBDK7yxqQ)   (提取码：o8wy)
    ```shell
    ## Install cuda
    ## https://developer.nvidia.com/cuda-toolkit-archive
    sudo dpkg -i cuda-repo-ubuntu1804_10.0.130-1_amd64.deb
    sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
    sudo apt-get update
    sudo apt-get install cuda-10-0
    ```

- Step 3: install cuDNN

    下载链接: [libcudnn7_7.5.0.56-1+cuda10.0_amd64.deb](https://pan.baidu.com/s/1xJPZYe3QZu4naYrPzn1HFw) (提取码：4nzt)
    ```shell
    ## https://developer.nvidia.com/rdp/cudnn-archive
    ## cuDNN v7.5.0 (Feb 21, 2019), for CUDA 10.0

    sudo dpkg -i libcudnn7_7.5.0.56-1+cuda10.0_amd64.deb
    ```
- Step 4: 添加环境变量

    在 *${HOME}/.bash_aliases* 添加
    ```shell
    ##################################
    #  CUDA
    ##################################
    export CUDA_HOME=/usr/local/cuda-10.0
    export PATH=$PATH:$CUDA_HOME/bin
    export LD_LIBRARY_PATH=${CUDA_HOME}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    ```
    ```shell
    source ${HOME}/.bash_aliases
    # 查看 CUDA 版本
    nvcc -V
    ```
- Step 5: 重启系统
    ```shell
    sudo shutdown -r now
    ```