# Shell

```latex
\frac{x^2}{k+1}
x^{\frac{2}{k+1}}
x^{1/2}
```

```latex
$$
\begin{align*}
y = y(x,t) &= A e^{i\theta} \\
&= A (\cos \theta + i \sin \theta) \\
&= A (\cos(kx - \omega t) + i \sin(kx - \omega t)) \\
&= A\cos(kx - \omega t) + i A\sin(kx - \omega t)  \\
&= A\cos \Big(\frac{2\pi}{\lambda}x - \frac{2\pi v}{\lambda} t \Big) + i A\sin \Big(\frac{2\pi}{\lambda}x - \frac{2\pi v}{\lambda} t \Big)  \\
&= A\cos \frac{2\pi}{\lambda} (x - v t) + i A\sin \frac{2\pi}{\lambda} (x - v t)
\end{align*}
$$
```

`:math:`\sum\limits_{k=1}^\infty \frac{1}{2^k} = 1``

```latex
$$y(n)=(f\ast g)(n)=\sum_{\tau =\infty}^{\infty}f(\tau )g(n-\tau )d\tau $$
```

```latex
$$\frac{1}{9}\begin{bmatrix}
1 & 1 & 1\\
1 & 1 & 1\\
1 & 1 & 1
\end{bmatrix}$$
```
## 1 8路相机出图
```shell
#!/bin/bash

# 视频设备数组
devices=(/dev/video0 /dev/video1 /dev/video2 /dev/video3 /dev/video4 /dev/video5 /dev/video6 /dev/video7)

# 视频格式设置
width=1920
height=1080
pixelformat=BA12
bypass_mode=0

# 命令模板
cmd_template="v4l2-ctl -d DEVICE --set-fmt-video=width=$width,height=$height,pixelformat=$pixelformat --set-ctrl bypass_mode=$bypass_mode --stream-mmap"

# 启动终端并执行命令
for i in "${!devices[@]}"; do
    device=${devices[$i]}
    cmd=${cmd_template/DEVICE/$device}
    gnome-terminal --title="Camera $i" -- bash -c "$cmd; exec bash" &
done

```

