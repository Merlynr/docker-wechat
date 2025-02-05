FROM merlynr/docker-wechat:base

# 安装必要的依赖
RUN apt-get update && \
    apt-get install -y \
    curl \
    im-config \
    fcitx \
    fcitx-config-gtk \
    dbus-x11 \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
