#! /bin/bash

# 全局变量
DIR=`pwd`

# > Install Homebrew
install_homebrew(){
    if `command -v brew > /dev/null 2>&1`; then
        echo '👌 Homebrew 已安装'
    else
        echo '🍺 正在安装 Homebrew... (link to Homebrew: https://brew.sh/)'
        # install script:
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        if [ $? -ne 0 ]; then
            echo '🍻 Homebrew 安装成功'
        else
            echo '🚫 安装失败，请检查你的网络环境，或尝试其他安装方式'
            exit 127
        fi
    fi
}

# > Backup Cask
backup_cask(){
    cd $DIR && brew list --cask > cask.list
    # cat $DIR/cask.list
}
# > Backup Formula
backup_formula(){
    $(cd $DIR && brew list --formula > formula.list)
    # cat $DIR/formula.list
}


# >>  主程序
cd $DIR
# 检查b ackup 文件夹是否存在
if [ ! -d backup  ];then
  mkdir backup
  DIR=`pwd`/backup
else
  DIR=`pwd`/backup
fi
install_homebrew
backup_cask
backup_formula
exit 0
