# 文档构建

## Sphinx

#### 0. 官方资料

- [ReadtheDocs](https://docs.readthedocs.io/en/stable/index.html)

#### 1. Sphinx_Installation

```python
   sudo apt install python-pip
   pip install -i https://pypi.tuna.tsinghua.edu.cn/simple sphinx
   pip3 install --upgrade pip
   pip install -i https://pypi.tuna.tsinghua.edu.cn/simple sphinx-autobuild
```

#### 2. 编译
   ```shell
   make build
   sphinx-autobuild source build/html
   ```
#### 3. 项目结构

      |-- build       <--------  生成文件的输出目录

      |-- make.bat    <--------  Windows 命令行中编译用的脚本

      |-- requirements.txt    <--------  托管构建需要的插件

      |-- Makefile    <--------  编译脚本，make 命令编译时用

      `-- source      <--------  文档源文件

         |-- conf.py     <--------  进行 Sphinx 的配置，如主题配置等

         |-- index.rst   <--------  文档项目起始文件，用于配置文档的显示结构

         |-- _static     <--------  静态文件目录, 比如图片等

         |-- _templates  <--------  模板目录



#### 4. 安装使用readthedocs主题
   `pip install -i https://pypi.tuna.tsinghua.edu.cn/simple sphinx_rtd_theme`

   修改conf.py
   ```python
   # html_theme = 'alabaster'
   html_theme = 'sphinx_rtd_theme'
   ```

#### 5. 配置支持Markdown
   ```shell
   # 支持markdown
   $pip install -i https://pypi.tuna.tsinghua.edu.cn/simple recommonmark
   ​
   # 支持markdown表格
   $pip install -i https://pypi.tuna.tsinghua.edu.cn/simple sphinx_markdown_tables
   ```

   修改conf.py
   ```python
   extensions = ['recommonmark','sphinx_markdown_tables']
   ```

#### 6. 插件依赖

   `python3 -m pip freeze > requirements.txt`

   Note:不一定需要所有的插件，一般保留如下两行
   ```python
   recommonmark==0.7.1
   sphinx-markdown-tables==0.0.15
   ```

## Typora

##### 1. Typora_Installation

```shell
# or run:
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BA300B7755AFCFAE
wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
# add Typora's repository
sudo add-apt-repository 'deb https://typora.io/linux ./'
sudo apt-get update
# install typora
sudo apt-get install typora
```

