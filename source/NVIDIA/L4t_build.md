# L4T 编译

## 1 JP6.0 nvbuild.sh
以下是这段脚本逐行的详细解释。此脚本主要用于构建 Linux 内核源码和 NVIDIA 的外部模块（OOT 模块），支持可选的实时内核 (RT Kernel) 功能，并可以进行编译后的安装。

---

### **1.1 初始化部分**

```bash
set -e
```
- 启用错误检测：如果脚本中任何命令返回非零状态，脚本会立即退出。

```bash
SCRIPT_DIR="$(dirname $(readlink -f "${0}"))"
SCRIPT_NAME="$(basename "${0}")"
```
- 获取脚本的绝对路径和脚本名称。
  - `SCRIPT_DIR` 是脚本所在目录的绝对路径。
  - `SCRIPT_NAME` 是脚本文件的名称。

```bash
ENABLE_RT=0
OOT_MODULES_ONLY=0
DO_INSTALL=0
```
- 初始化全局变量：
  - `ENABLE_RT=0`：是否启用实时内核。
  - `OOT_MODULES_ONLY=0`：是否只编译和安装外部模块。
  - `DO_INSTALL=0`：是否进行安装。

```bash
source "${SCRIPT_DIR}/kernel_src_build_env.sh"
```
- 加载 `kernel_src_build_env.sh` 环境变量文件。

---

### **1.2 显示帮助信息函数**

```bash
function usage {
    cat <<EOM
Usage: ./${SCRIPT_NAME} [OPTIONS]
This script builds kernel sources in this directory.
It supports following options.
OPTIONS:
    -h              Displays this help
    -r              Enable RT Kernel
    -m              Build/install NVIDIA OOT modules only (skip kernel)
    -i              Perform install to INSTALL_MOD_PATH
    -o <outdir>     Creates kernel build output in <outdir>
EOM
}
```
- 定义 `usage` 函数，用于显示脚本的使用说明和支持的命令行选项。

---

### **1.3 解析命令行参数函数**

```bash
function parse_input_param {
	while [ $# -gt 0 ]; do
		case ${1} in
			-h)
				usage
				exit 0
				;;
			-r)
				ENABLE_RT=1
				shift 1
				;;
			-o)
				KERNEL_OUT_DIR="${2}"
				shift 2
				;;
			-m)
				OOT_MODULES_ONLY=1
				shift 1
				;;
			-i)
				DO_INSTALL=1
				shift 1
				;;
			*)
				echo "Error: Invalid option ${1}"
				usage
				exit 1
				;;
		esac
	done
}
```
- 根据传入的选项设置全局变量。
- 支持选项：
  - `-h`：显示帮助信息并退出。
  - `-r`：启用实时内核。
  - `-o <outdir>`：设置输出目录。
  - `-m`：只处理外部模块。
  - `-i`：执行安装步骤。

---

### **1.4 内核源码同步函数**

```bash
function sync_kernel_source {
	if [ ! -d "kernel/${KERNEL_SRC_DIR}" ]; then
		echo "Directory kernel/${KERNEL_SRC_DIR} is not found, exiting.."
		exit 1
	fi

	echo "Syncing kernel/${KERNEL_SRC_DIR}"
	rsync -a --delete "kernel/${KERNEL_SRC_DIR}" "${KERNEL_OUT_DIR}/kernel/"
	cp -a kernel/Makefile "${KERNEL_OUT_DIR}/kernel/"
}
```
- 同步内核源码到输出目录。
  - 检查目录 `kernel/${KERNEL_SRC_DIR}` 是否存在。
  - 使用 `rsync` 同步目录并删除多余文件。
  - 复制 `Makefile` 到输出目录。

---

### **1.5 外部模块同步函数**

```bash
function sync_oot_modules {
	for list in ${OOT_SOURCE_LIST}; do
		if [ ! -d "${list}" ]; then
			echo "Directory \"${list}\" is not found, exiting.."
			exit 1
		fi
	done

	for list in ${OOT_SOURCE_LIST}; do
		echo "Syncing ${list}"
		rsync -a --delete "${list}" "${KERNEL_OUT_DIR}"
	done
	cp -a Makefile "${KERNEL_OUT_DIR}/"
}
```
- 同步外部模块源码到输出目录。
  - 检查外部模块列表中的目录是否存在。
  - 使用 `rsync` 同步外部模块。

---

### **1.6 内核编译函数**

```bash
function build_arm64_kernel_sources {
	source_dir="${SCRIPT_DIR}/kernel/${KERNEL_SRC_DIR}/"
	kernel_out_dir="${KERNEL_OUT_DIR}/kernel/"

	if [ "$ENABLE_RT" -eq 0 ] && grep -q "CONFIG_PREEMPT_RT=y" "${source_dir}/arch/arm64/configs/${KERNEL_DEF_CONFIG}"; then
		./generic_rt_build.sh "disable"
	fi

	if [ "$ENABLE_RT" -eq 1 ]; then
		./generic_rt_build.sh "enable"
	fi

	sync_kernel_source

	echo "Building kernel sources in ${kernel_out_dir}"
	make -C "${kernel_out_dir}"

	image="${kernel_out_dir}/${KERNEL_SRC_DIR}/arch/arm64/boot/Image"
	if [ ! -f "${image}" ]; then
		echo "Error: Missing kernel image ${image}"
		exit 1
	fi
	echo "Kernel sources compiled successfully."

	export KERNEL_HEADERS="${kernel_out_dir}/${KERNEL_SRC_DIR}"
}
```
- 编译内核源码：
  - 如果启用了实时内核，则调用 `generic_rt_build.sh`。
  - 调用 `sync_kernel_source` 同步源码。
  - 使用 `make` 进行编译。
  - 检查是否生成了内核镜像文件 `Image`。

---

### **1.7 外部模块编译函数**

```bash
function build_oot_modules {
	sync_oot_modules

	if [ "${ENABLE_RT}" -eq 1 ]; then
		export IGNORE_PREEMPT_RT_PRESENCE=1
	fi

	echo "Building NVIDIA OOT modules sources in ${KERNEL_OUT_DIR}"
	make -C "${KERNEL_OUT_DIR}" modules

	echo "Building NVIDIA DTBs"
	make -C "${KERNEL_OUT_DIR}" dtbs

	gpu_out="${KERNEL_OUT_DIR}/nvgpu/drivers/gpu/nvgpu/nvgpu.ko"
	if [ ! -f "${gpu_out}" ]; then
		echo "Error: Missing nvgpu.ko in \"${gpu_out}\""
		exit 1
	fi
	echo "Modules compiled successfully."
}
```
- 编译外部模块。
  - 调用 `sync_oot_modules` 同步模块源码。
  - 使用 `make` 构建模块和设备树二进制文件（DTBs）。

---

### **1.8 安装函数**

```bash
function install_kernel {
	kernel_out_dir="${KERNEL_OUT_DIR}/kernel/"
	echo "Installing kernel.."
	sudo -E make -C "${kernel_out_dir}" install
	export KERNEL_HEADERS="${kernel_out_dir}/${KERNEL_SRC_DIR}"
}

function install_oot_modules {
	echo "Installing NVIDIA OOT modules.."
	sudo -E make -C "${KERNEL_OUT_DIR}" INSTALL_MOD_DIR=updates modules_install
}
```
- 安装内核和外部模块到目标路径。

---

### **1.9 环境变量检查**

```bash
function check_env_vars {
	MACHINE=$(uname -m)
	if [[ "${MACHINE}" =~ "x86" ]]; then
		if [ -z "${CROSS_COMPILE}" ]; then
			echo "Error: Env variable CROSS_COMPILE is not set!!"
			exit 1
		fi
		if [ ! -f "${CROSS_COMPILE}gcc" ]; then
			echo "Error: Path ${CROSS_COMPILE}gcc does not exist."
			exit 1
		fi
		if [ "${OOT_MODULES_ONLY}" -eq 1 ]; then
			if [ -z "${KERNEL_HEADERS}" ]; then
				echo "Error: Env variable KERNEL_HEADERS is not set!!"
				exit 1
			fi
		fi
		if [ "${DO_INSTALL}" -eq 1 ]; then
			if [ -z "${INSTALL_MOD_PATH}" ]; then
				echo "Error: Env variable INSTALL_MOD_PATH is not set!!"
				exit 1
			fi
		fi
	fi
}
```
- 检查交叉编译器路径、内核头文件和安装路径是否设置正确。

---

### **1.10 主流程**
- 解析参数：`parse_input_param "$@"`
- 检查环境：`check_env_vars`
- 设置默认输出路径。
- 编译内核和外部模块。
- 根据需要执行安装步骤。


## 2 Makefile

```shell
MAKEFILE_DIR := $(abspath $(shell dirname $(lastword $(MAKEFILE_LIST))))
kernel_source_dir := $(MAKEFILE_DIR)/$(KERNEL_SRC_DIR)

ifdef KERNEL_OUTPUT
O_OPT := O=$(KERNEL_OUTPUT)
$(mkdir -p $(KERNEL_OUTPUT))
kernel_image := $(KERNEL_OUTPUT)/arch/arm64/boot/Image
else
kernel_image := $(kernel_source_dir)/arch/arm64/boot/Image
endif

NPROC ?= $(shell nproc)

# LOCALVERSION : -tegra or -rt-tegra
version = $(shell grep -q "CONFIG_PREEMPT_RT=y" \
    ${kernel_source_dir}/arch/arm64/configs/${KERNEL_DEF_CONFIG} && echo "-rt-tegra" || echo "-tegra")

.PHONY : kernel install clean help

kernel:
        @echo   "================================================================================"
        @echo   "Building $(KERNEL_SRC_DIR) sources"
        @echo   "================================================================================"
        $(MAKE) \
                ARCH=arm64 \
                -C $(kernel_source_dir) $(O_OPT) \
                LOCALVERSION=$(version) \
                $(KERNEL_DEF_CONFIG)

        $(MAKE) -j $(NPROC) \
                ARCH=arm64 \
                -C $(kernel_source_dir) $(O_OPT) \
                LOCALVERSION=$(version) \
                --output-sync=target Image

        $(MAKE) -j $(NPROC) \
                ARCH=arm64 \
                -C $(kernel_source_dir) $(O_OPT) \
                LOCALVERSION=$(version) \
                --output-sync=target dtbs

        $(MAKE) -j $(NPROC) \
                ARCH=arm64 \
                -C $(kernel_source_dir) $(O_OPT) \
                LOCALVERSION=$(version) \
                --output-sync=target modules

        @echo   "================================================================================"
        @if [ -f "$(kernel_image)" ] ; then \
                echo   "Kernel Image: $(kernel_image)"; \
        else \
                echo   "Error: Missing kernel image: $(kernel_image)"; \
        false ; \
        fi
        @echo   "Kernel sources compiled successfully."
        @echo   "================================================================================"


install:
        @echo   "================================================================================"
        @echo   "Installing $(KERNEL_SRC_DIR) sources"
        @echo   "================================================================================"
        install $(kernel_image) $(INSTALL_MOD_PATH)/boot/
        $(MAKE) \
                ARCH=arm64 \
                -C $(kernel_source_dir) $(O_OPT) \
                LOCALVERSION=$(version) \
                INSTALL_MOD_PATH=$(INSTALL_MOD_PATH) \
                modules_install
        @echo   "================================================================================"
        @echo   "Kernel and in-tree modules installed successfully."
        @echo   "================================================================================"


clean:
        @echo   "================================================================================"
        @echo   "Cleaning $(KERNEL_SRC_DIR) sources"
        @echo   "================================================================================"
        $(MAKE) \
                ARCH=arm64 \
                -C $(kernel_source_dir) $(O_OPT) \
                mrproper
        @echo   "================================================================================"
        @echo   "Kernel and in-tree modules installed successfully."
        @echo   "================================================================================"

# make help
help:
        @echo   "================================================================================"
        @echo   "Usage:"
        @echo   "   make or make kernel   # to build kernel"
        @echo   "   make install          # to install kernel image and in-tree modules"
        @echo   "   make clean            # to make clean kernel source"
        @echo   "================================================================================"
```
---
解读

### **Makefile 逐行解释**

该 Makefile 定义了一些用于构建、安装和清理 Linux 内核的规则，特别针对 ARM64 架构，可能用于 Jetson 或类似嵌入式设备环境。

---

### **定义的变量**

1. **`KERNEL_SRC_DIR` 和 `KERNEL_DEF_CONFIG`**:
   ```makefile
   KERNEL_SRC_DIR ?= kernel-jammy-src
   KERNEL_DEF_CONFIG ?= defconfig
   ```
   - `KERNEL_SRC_DIR`：内核源代码目录（默认是 `kernel-jammy-src`）。
   - `KERNEL_DEF_CONFIG`：使用的默认配置文件（`defconfig`）。

2. **`MAKEFILE_DIR` 和 `kernel_source_dir`**:
   ```makefile
   MAKEFILE_DIR := $(abspath $(shell dirname $(lastword $(MAKEFILE_LIST))))
   kernel_source_dir := $(MAKEFILE_DIR)/$(KERNEL_SRC_DIR)
   ```
   - `MAKEFILE_DIR`：Makefile 所在的绝对路径。
   - `kernel_source_dir`：内核源码目录的绝对路径。

3. **`O_OPT` 和 `kernel_image`**:
   ```makefile
   ifdef KERNEL_OUTPUT
   O_OPT := O=$(KERNEL_OUTPUT)
   $(mkdir -p $(KERNEL_OUTPUT))
   kernel_image := $(KERNEL_OUTPUT)/arch/arm64/boot/Image
   else
   kernel_image := $(kernel_source_dir)/arch/arm64/boot/Image
   endif
   ```
   - 如果定义了 `KERNEL_OUTPUT`（输出目录），则使用该目录存放编译结果，并指定选项 `O=$(KERNEL_OUTPUT)`。
   - 如果未定义 `KERNEL_OUTPUT`，编译结果保存在源码目录下。

4. **`NPROC`**:
   ```makefile
   NPROC ?= $(shell nproc)
   ```
   - 默认并行构建的线程数，等于当前系统的 CPU 核心数（通过 `nproc` 命令获取）。

5. **`version`**:
   ```makefile
   version = $(shell grep -q "CONFIG_PREEMPT_RT=y" \
       ${kernel_source_dir}/arch/arm64/configs/${KERNEL_DEF_CONFIG} && echo "-rt-tegra" || echo "-tegra")
   ```
   - 检查配置文件是否启用了实时（RT）内核 (`CONFIG_PREEMPT_RT=y`)。
   - 如果启用了，`version` 为 `-rt-tegra`；否则为 `-tegra`。

---

### **定义的规则**

#### **1. `kernel` 规则**
构建内核（包含镜像、设备树、模块）。
```makefile
.PHONY : kernel
kernel:
    @echo   "Building $(KERNEL_SRC_DIR) sources"
    $(MAKE) ARCH=arm64 -C $(kernel_source_dir) $(O_OPT) LOCALVERSION=$(version) $(KERNEL_DEF_CONFIG)
    $(MAKE) -j $(NPROC) ARCH=arm64 -C $(kernel_source_dir) $(O_OPT) LOCALVERSION=$(version) --output-sync=target Image
    $(MAKE) -j $(NPROC) ARCH=arm64 -C $(kernel_source_dir) $(O_OPT) LOCALVERSION=$(version) --output-sync=target dtbs
    $(MAKE) -j $(NPROC) ARCH=arm64 -C $(kernel_source_dir) $(O_OPT) LOCALVERSION=$(version) --output-sync=target modules
    @if [ -f "$(kernel_image)" ]; then \
        echo "Kernel Image: $(kernel_image)"; \
    else \
        echo "Error: Missing kernel image: $(kernel_image)"; \
        false; \
    fi
```
- **执行的操作**：
  1. 运行默认配置文件（如 `defconfig`）。
  2. 编译内核镜像 (`Image`)。
  3. 编译设备树二进制文件 (`dtbs`)。
  4. 编译内核模块 (`modules`)。
  5. 检查生成的内核镜像是否存在。

- **并行构建**：
  使用 `-j $(NPROC)` 实现多线程构建，提高效率。

#### **2. `install` 规则**
安装内核镜像和模块到目标目录。
```makefile
.PHONY : install
install:
    @echo   "Installing $(KERNEL_SRC_DIR) sources"
    install $(kernel_image) $(INSTALL_MOD_PATH)/boot/
    $(MAKE) ARCH=arm64 -C $(kernel_source_dir) $(O_OPT) LOCALVERSION=$(version) INSTALL_MOD_PATH=$(INSTALL_MOD_PATH) modules_install
    @echo   "Kernel and in-tree modules installed successfully."
```
- **操作步骤**：
  1. 使用 `install` 命令将内核镜像复制到 `$(INSTALL_MOD_PATH)/boot/`。
  2. 安装内核模块到指定的目标路径。

- **关键变量**：
  - `INSTALL_MOD_PATH`：模块安装路径（需在运行前定义）。

#### **3. `clean` 规则**
清理构建目录。
```makefile
.PHONY : clean
clean:
    @echo   "Cleaning $(KERNEL_SRC_DIR) sources"
    $(MAKE) ARCH=arm64 -C $(kernel_source_dir) $(O_OPT) mrproper
    @echo   "Kernel and in-tree modules installed successfully."
```
- **操作步骤**：
  调用 `make mrproper` 清理内核源码目录中的编译产物。

#### **4. `help` 规则**
打印帮助信息。
```makefile
.PHONY : help
help:
    @echo   "Usage:"
    @echo   "   make or make kernel   # to build kernel"
    @echo   "   make install          # to install kernel image and in-tree modules"
    @echo   "   make clean            # to make clean kernel source"
```
- **说明**：
  详细列出 Makefile 支持的命令及其用途。

---

### **运行示例**
1. **构建内核**：
   ```bash
   make kernel KERNEL_OUTPUT=output_dir
   ```
2. **安装内核及模块**：
   ```bash
   make install KERNEL_OUTPUT=output_dir INSTALL_MOD_PATH=/target_path
   ```
3. **清理构建产物**：
   ```bash
   make clean KERNEL_OUTPUT=output_dir
   ```