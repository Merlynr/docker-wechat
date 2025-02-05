FROM merlynr/docker-wechat:base
    
# 安装中文输入法（fcitx + sogoupinyin）
RUN apt-get update && \
    apt-get install -y \
    fcitx \
    fcitx-sogoupinyin \
    fcitx-module-dbus \
    fcitx-config-gtk \
    dbus-x11 \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 设置环境变量
ENV GTK_IM_MODULE=fcitx
ENV QT_IM_MODULE=fcitx
ENV XMODIFIERS=@im=fcitx

# 启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 设置入口点
ENTRYPOINT ["/start.sh"]
