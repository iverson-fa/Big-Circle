# 解决 rosdep update 超时问题
思路：在 `https://raw.githubusercontent.com` 前添加 `https://ghproxy.com/`

1. `/usr/lib/python2.7/dist-packages/rosdep2/sources_list.py`

        72行
        308行 download_rosdep_data()函数的try后添加一行
              url="https://ghproxy.com/"+url

2. `/usr/lib/python2.7/dist-packages/rosdep2/gbpdistro_support.py`

        36行
        204行添加 gbpdistro_url = 'https://ghproxy.com/' + gbpdistro_url


3. `/usr/lib/python2.7/dist-packages/rosdep2/rep3.py`

        39行

4. `/usr/lib/python2.7/dist-packages/rosdistro/manifest_provider/github.py`

        68/119行

5. `/usr/lib/python2.7/dist-packages/rosdistro/_ __init___.py`

        68行
