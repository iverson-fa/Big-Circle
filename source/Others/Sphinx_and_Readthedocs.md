# 文档构建

## 0. Doc_index

- [Markdown 官方教程](	https://markdown.com.cn/)

- [ReadtheDocs](https://docs.readthedocs.io/en/stable/index.html)
- [A Brief Tutorial on Sphinx and reStructuredText](https://iridescent.ink/HowToMakeDocs/index.html)
- [MathJax](http://docs.mathjax.org/en/latest/input/tex/macros/index.html)
- [MathJax 中文文档](https://mathjax-chinese-doc.readthedocs.io/en/latest/)
- [Sphinx Tutorial](https://sphinx-handbook.readthedocs.io/en/latest/index.html)
- [Sphinx-doc](https://www.sphinx-doc.org/en/master/)
- [reST语法](http://www.pythondoc.com/sphinx/index.html#)
- [MkDocs](https://zj-sphinx-github-readthedocs.readthedocs.io/en/latest/)
- [Mkdocs 中文文档](https://mkdocs.zimoapps.com/)
- [Markdown Syntax](https://daringfireball.net/projects/markdown/syntax#link)

## 1. Sphinx_Installation

```python
   sudo apt install python3-pip
   pip install -i https://pypi.tuna.tsinghua.edu.cn/simple sphinx
   pip3 install --upgrade pip
   pip install -i https://pypi.tuna.tsinghua.edu.cn/simple sphinx-autobuild
```

## 2. 编译
   ```shell
   make build
   sphinx-autobuild source build/html
   ```
## 3. 项目结构

      |-- build       <--------  生成文件的输出目录
    
      |-- make.bat    <--------  Windows 命令行中编译用的脚本
    
      |-- requirements.txt    <--------  托管构建需要的插件
    
      |-- Makefile    <--------  编译脚本，make 命令编译时用
    
      `-- source      <--------  文档源文件
    
         |-- conf.py     <--------  进行 Sphinx 的配置，如主题配置等
    
         |-- index.rst   <--------  文档项目起始文件，用于配置文档的显示结构
    
         |-- _static     <--------  静态文件目录, 比如图片等
    
         |-- _templates  <--------  模板目录



## 4. 安装使用readthedocs主题
   `pip install -i https://pypi.tuna.tsinghua.edu.cn/simple sphinx_rtd_theme`

   修改conf.py
   ```python
   # html_theme = 'alabaster'
   html_theme = 'sphinx_rtd_theme'
   ```

## 5. 配置支持Markdown
   ```shell
   # 支持markdown
   $pip install -i https://pypi.tuna.tsinghua.edu.cn/simple recommonmark
   ​
   # 支持markdown表格
   $pip install -i https://pypi.tuna.tsinghua.edu.cn/simple sphinx_markdown_tables
   ```

   修改conf.py
   ```python
   extensions = ['sphinx.ext.autodoc',    'sphinx.ext.napoleon',    'sphinx.ext.mathjax','recommonmark','sphinx_markdown_tables']
   ```

## 6. 插件依赖

   `python3 -m pip freeze > requirements.txt`

   Note:不一定需要所有的插件，一般保留如下两行
   ```python
   recommonmark==0.7.1
   sphinx-markdown-tables==0.0.15
   ```

## 7. Latex

- example:

<!--

\\(
\begin{align*}
y = y(x,t) &= A e^{i\theta} \\
&= A (\cos \theta + i \sin \theta) \\
&= A (\cos(kx - \omega t) + i \sin(kx - \omega t)) \\
&= A\cos(kx - \omega t) + i A\sin(kx - \omega t)  \\
&= A\cos \Big(\frac{2\pi}{\lambda}x - \frac{2\pi v}{\lambda} t \Big) + i A\sin \Big(\frac{2\pi}{\lambda}x - \frac{2\pi v}{\lambda} t \Big)  \\
&= A\cos \frac{2\pi}{\lambda} (x - v t) + i A\sin \frac{2\pi}{\lambda} (x - v t)
\end{align*}
)\\
-- >

```{math}
a^2 + b^2 = c^2
```



