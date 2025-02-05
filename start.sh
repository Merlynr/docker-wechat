#!/bin/bash

# 启动 DBus
service dbus start

# 启动 fcitx
fcitx -d

# 启动微信
deepin-wine /path/to/wechat.exe
