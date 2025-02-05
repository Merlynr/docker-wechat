FROM merlynr/docker-wechat:base

# 安装 fcitx 及其依赖项
RUN apt-get install -y \
    curl \
    im-config \
    fcitx \
    fcitx-config-gtk \
    fcitx-frontend-all \
    fcitx-ui-classic \
    fcitx-dbus-status \
    libdbus-1-3 \
    dbus-x11 \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 设置环境变量
ENV DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
    GTK_IM_MODULE=fcitx \
    QT_IM_MODULE=fcitx \
    XMODIFIERS=@im=fcitx

# 启动 dbus 服务
RUN mkdir -p /var/run/dbus && \
    dbus-uuidgen > /var/lib/dbus/machine-id

# 创建启动脚本
RUN echo '#!/bin/sh' > /startapp.sh && \
    echo 'dbus-daemon --system --fork' >> /startapp.sh && \
    echo 'fcitx &' >> /startapp.sh && \
    echo 'exec /usr/bin/wechat' >> /startapp.sh && \
    chmod +x /startapp.sh

# 下载微信安装包
RUN curl -O "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb" && \
    dpkg -i WeChatLinux_x86_64.deb 2>&1 | tee /tmp/wechat_install.log && \
    rm WeChatLinux_x86_64.deb

# 下载搜狗拼音输入法的 deb 文件
RUN curl -O "https://ime-sec.gtimg.com/202502051746/2a563b2547c239f2d6ab02bc3165779d/pc/dl/gzindex/1680521801/sogoupinyin_4.2.1.145_loongarch64.deb"

# 安装搜狗拼音输入法
RUN dpkg -i sogoupinyin_4.2.1.145_loongarch64.deb || apt-get install -f -y && \
    rm -f sogoupinyin_4.2.1.145_loongarch64.deb

# 配置输入法
RUN im-config -n fcitx && \
    fcitx-configtool

# 创建启动脚本
RUN echo '#!/bin/sh' > /startapp.sh && \
    echo 'fcitx &' >> /startapp.sh && \
    echo 'exec /usr/bin/wechat' >> /startapp.sh && \
    chmod +x /startapp.sh

# 挂载卷
VOLUME /root/.xwechat
VOLUME /root/xwechat_files
VOLUME /root/downloads

# 配置微信版本号（可选）
RUN set-cont-env APP_VERSION "$(grep -o 'Unpacking wechat ([0-9.]*)' /tmp/wechat_install.log | sed 's/Unpacking wechat (\(.*\))/\1/')"

# 暴露端口（如果需要）
EXPOSE 5900

# 启动容器时运行的命令
CMD ["/startapp.sh"]
