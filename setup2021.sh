#! /bin/bash

cat << -EOF
#######################################################################
# 当前脚本用于在运行OS X的电脑上安装应用程序
#
# 使用方法: 只需要在以下两个列表中填入自己需要的程序即可
# > 命令行模块列表: formula.list
# > GUI 程序列表: cask.list
#
# 原理为: 利用 homebrew 作为OS X的包管理器
#        brew install 安装命令行，GUI程序
#        Happy coding ~ Happy life.
#
# 由于 Homebrew 更新后，brew cask install 整合到 brew install 中，因此旧脚本可能运行失败
# 原 Github: https://github.com/jsycdut/mac-setup
# 2021-7 更新 Github:  https://github.com/jsmjsm/mac-setup
#
# 祝使用愉快，有问题的话可以去 GitHub 提 issue
#
# 注意事项
#
# 1. OS X尽量保持较新版本，否则可能满足不了Homebrew的依赖要求
# 2. 中途若遇见安装非常慢的情况，可用 Ctrl+C 打断，直接进行下一项的安装
#######################################################################
-EOF

# Global Variable
# type 0 -> formula
# type 1 -> cask
type=0
WD=`pwd`/backup

# > Install Homebrew
install_homebrew (){
    if `command -v brew > /dev/null 2>&1`; then
        echo '👌 Homebrew 已安装'
    else
        echo '🍺 正在安装 Homebrew...  (link to Homebrew: https://brew.sh/)'
        # install script:
        /usr/bin/ruby -e "$ (curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        if [ $? -ne 0 ]; then
            echo '🍻 Homebrew 安装成功'
        else
            echo '🚫 安装失败，请检查你的网络环境，或尝试其他安装方式'
        fi
    fi
}

# > Change to diffrent Homebrew source
select_homebrew_mirror (){
    flag=0;
    while [ "$flag" != 1 ]
    do
        echo
        echo "      请选择 Homebrew 镜像: "
        echo "      默认选项:[1] Homebrew 官方源"
        echo "      1: Homebrew Default Mirror 官方源"
        echo "      2: 清华大学 Tuna 源"
        echo "      3: USTC 中科大源"
        echo
        read input

    case $input in
        1)
            # echo "select_homebrew_mirror -> Debug: 1"
            _change_homebrew_default
            flag=1
            ;;
        2)
            # echo "select_homebrew_mirror -> Debug: 2"
            _change_homebrew_tuna
            flag=1
            ;;
        3)
            # echo "select_homebrew_mirror -> Debug: 3"
            _change_homebrew_tuna
            flag=1
            ;;
        *)
            _change_homebrew_default
            # echo "select_homebrew_mirror -> Debug: default"
            flag=1
            ;;
    esac
    done
}

_change_homebrew_default (){
    echo "Changing the homebrew mirror to: Deafult ..."
    git -C "$ (brew --repo homebrew/core)" remote set-url origin https://github.com/Homebrew/homebrew-core.git
    git -C "$ (brew --repo homebrew/cask)" remote set-url origin https://github.com/Homebrew/homebrew-cask.git
    echo "Change Finifh! Run 'brew update' now. "
    brew update
}

_change_homebrew_tuna (){
    echo "Changing the homebrew mirror to: Tuna (清华大学 Tuna 源)  ..."
    echo "Reference from  (参考): https://mirror.tuna.tsinghua.edu.cn/help/homebrew/ "
    git -C "$ (brew --repo homebrew/core)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
    git -C "$ (brew --repo homebrew/cask)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git
    echo "Change Finifh! Run 'brew update' now. "
    brew update
}

_change_homebrew_ustc (){
    echo "Changing the homebrew mirror to: USTC (USTC 中科大源)  ..."
    echo "Reference from  (参考): https://lug.ustc.edu.cn/wiki/mirrors/help/brew.git "
    cd "$ (brew --repo)"
    git remote set-url origin https://mirrors.ustc.edu.cn/brew.git
    cd "$ (brew --repo)/Library/Taps/homebrew/homebrew-core"
    git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git
    echo "Change Finifh! Run 'brew update' now. "
    brew update
}

# > Install List

list_install (){
    # echo "Debug: list install Begin"
    for app in `cat $1`
    do
        install $app
    done
    # echo "Debug: list install End"
}

# > Install Package
install () {
    # echo "Debug: install Begin"
    check_installation $1
    if [[ $? -eq 0 ]]; then
        echo "👌 ==> 已安装" $1 ", 尝试安装下一项..."
    else
        echo "🔥 ==> 正在安装: " $1
        # echo "Debug: Running brew install "
        brew install $1 > /dev/null
        echo $?
    fi

    if [[ $? -eq 0 ]]; then
        echo "🍺 ==> 安装成功 " $1
    else
        echo "🚫 ==> 安装失败" $1
    fi
}

# > Installed Package Checking
check_installation (){
    # if [[ $type == "cli" ]]; then
    brew list -1 | grep $1 > /dev/null

    if [[ $? -eq 0 ]]; then
        # not installed, return 0
        return 0
    fi
    # installed, return 1
    return 1
}

# > show menu
# TODO: update the menu
show_menu () {
    echo
    read -p "✨ 请选择要安装的软件包类型: [0] 命令行 [1] 图形化 (默认): " ans
    echo

    case $ans in
        0) cd $WD && cat formula.list && type=0
        ;;
        1) cd $WD && cat cask.list && type=1
        ;;
        *) cd $WD && cat cask.list && type=1
        ;;
    esac
}

# 检查AWK是否可用
check_awk () {
  if ! `command -v awk > /dev/null`; then
    echo 未检测到AWK，请先安装AWK再执行本程序...
    exit 127
  fi
}


#! 程序入口
echo
echo "🙏  请花 5 秒时间看一下上述注意事项"
sleep 5s
install_homebrew
echo '🪞 假如你处于中国大陆境内，网络环境不佳，可以尝试使用 Homebrew 国内镜像源 (脚本结束后可以切换回官方源) '
select_homebrew_mirror
while : ; do
    show_menu
    # echo "Debug: type: $type"
    echo

    case $type in
        0)  list_install formula.list
        ;;
        1)  list_install cask.list
        ;;
        *)  echo "Debug: error list"
        ;;
    esac

    echo
    read  -p "📕 是否继续查看菜单列表，Y/y继续，N/n退出 : " ans
    case $ans in
        Y|y) :
        ;;
        *) break
        ;;
    esac
done

echo '🪞 脚本运行结束前，你可以再次选取 Homebrew 的镜像源'
select_homebrew_mirror
echo '🤔 查看 package 信息 (用于配置环境变量): 运行 $brew info [模块名]'
echo '🎉 享受你的新 Mac 吧！'
exit 0
