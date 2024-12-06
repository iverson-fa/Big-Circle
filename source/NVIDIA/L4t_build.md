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
