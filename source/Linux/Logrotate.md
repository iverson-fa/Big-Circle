# Ubuntu 日志轮转

## 1. **主日志文件**

* 系统日志通常写入 `/var/log/syslog`，由 `rsyslog` 或 `systemd-journald`（转发到 rsyslog）负责记录。

---

## 2. **日志轮转（logrotate）**

Ubuntu 默认使用 **logrotate** 工具管理日志文件，配置文件主要有：

* **全局配置**：`/etc/logrotate.conf`
* **具体规则**：`/etc/logrotate.d/*`
  其中 `/etc/logrotate.d/rsyslog` 里定义了对 `/var/log/syslog` 的轮转策略。

例如（典型配置片段）：

```conf
/var/log/syslog
{
    rotate 7
    daily
    missingok
    notifempty
    delaycompress
    compress
    postrotate
        invoke-rc.d rsyslog rotate > /dev/null
    endscript
}
```

---

## 3. **轮转规则解释**

* `rotate 7`：保留 7 个历史日志文件。
* `daily`：每天轮转一次。
* `compress`：用 gzip 压缩旧日志。
* `delaycompress`：延迟一轮压缩（即 syslog.1 不压缩，syslog.2 开始压缩）。
* `postrotate`：轮转后通知 `rsyslog` 重新打开日志文件。

---

## 4. **文件生成过程**

* 当 `logrotate` 触发时（通常由 **cron.daily** 或 **systemd timer** 调度执行）：

  1. 现有 `/var/log/syslog` 被重命名为 `/var/log/syslog.1`。
  2. 新的 `/var/log/syslog` 文件创建，并通知 `rsyslog` 写入新的文件。
  3. 之前的 `/var/log/syslog.1` 如果有 `delaycompress`，保持原样。
  4. 再老的 `/var/log/syslog.1` 会变成 `/var/log/syslog.2.gz`，此时会被 **gzip 压缩**。
  5. 继续类推，最老的会被删除，只保留 N 个。

---

## 5. **例子**

Ubuntu 22.04 默认 `/etc/logrotate.d/rsyslog` ：

```conf
/var/log/syslog
/var/log/mail.info
/var/log/mail.warn
/var/log/mail.err
/var/log/mail.log
/var/log/daemon.log
/var/log/kern.log
/var/log/auth.log
/var/log/user.log
/var/log/lpr.log
/var/log/cron.log
/var/log/debug
/var/log/messages
{
        rotate 4
        weekly
        missingok
        notifempty
        compress
        delaycompress
        sharedscripts
        postrotate
                /usr/lib/rsyslog/rsyslog-rotate
        endscript
}
```

---

### 5.1 规则覆盖的日志文件

```conf
/var/log/syslog
/var/log/mail.info
/var/log/mail.warn
/var/log/mail.err
/var/log/mail.log
/var/log/daemon.log
/var/log/kern.log
/var/log/auth.log
/var/log/user.log
/var/log/lpr.log
/var/log/cron.log
/var/log/debug
/var/log/messages
```

这些文件都会按照下面的策略进行轮转（包括 `syslog`）。

---

### 5.2 策略解释

```conf
{
    rotate 4
    weekly
    missingok
    notifempty
    compress
    delaycompress
    sharedscripts
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
```

* **rotate 4**
  每个日志文件只保留 **4 个历史版本**。超过的会被删除。

* **weekly**
  每周轮转一次。也就是说，日志每周会重命名一次。

* **missingok**
  如果日志文件不存在，就忽略，不报错。

* **notifempty**
  如果日志文件是空的，就不轮转。

* **compress**
  使用 gzip 压缩旧日志（生成 `.gz` 文件）。

* **delaycompress**
  延迟一轮压缩：

  * `syslog.1` → **未压缩**
  * `syslog.2.gz` → **压缩后的文件**

* **sharedscripts**
  这些日志文件共享同一个 `postrotate` 脚本（只执行一次，不是对每个文件单独执行）。

* **postrotate ... endscript**
  在轮转完成后执行 `/usr/lib/rsyslog/rsyslog-rotate`，作用是通知 rsyslog 重新打开日志文件，否则它还会继续往旧文件里写。

---

### 5.3 日志轮转的实际过程（以 `syslog` 为例）

1. 周日/周一（具体取决于 `cron` 定时），`logrotate` 运行：

   * `/var/log/syslog` → `/var/log/syslog.1`
   * 新建一个空的 `/var/log/syslog` 并让 rsyslog 继续写入。

2. 下一周再次运行：

   * `/var/log/syslog.1` → `/var/log/syslog.2.gz`（此时会被压缩）
   * `/var/log/syslog` → `/var/log/syslog.1`
   * 新建 `/var/log/syslog`。

3. 第三周：

   * `/var/log/syslog.2.gz` → `/var/log/syslog.3.gz`
   * `/var/log/syslog.1` → `/var/log/syslog.2.gz`
   * `/var/log/syslog` → `/var/log/syslog.1`

4. 第四周：

   * `/var/log/syslog.3.gz` → `/var/log/syslog.4.gz`
   * `/var/log/syslog.1` → `/var/log/syslog.2.gz`
   * 新 `/var/log/syslog` 生成

5. 第五周：

   * 因为配置了 `rotate 4`，所以最老的 `/var/log/syslog.4.gz` 会被删除。

---

这就解释了：

* `/var/log/syslog.1` 总是不压缩的最近一次轮转结果。
* `/var/log/syslog.2.gz`、`syslog.3.gz`、`syslog.4.gz` … 是更早的日志，并且是压缩过的。

---