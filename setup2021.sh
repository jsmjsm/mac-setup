#! /bin/bash

cat << -EOF
###
 # @Description  : macOS Setup script
 # @Author       : jsmjsm
 # @Github       : https://github.com/jsmjsm
 # @Date         : 2021-07-11 21:15:09
 # @LastEditors  : jsmjsm
 # @LastEditTime : 2021-07-12 15:56:10
 # @FilePath     : /mac-setup/setup2021.sh
###
-EOF

# Global Variable
type=cli
WD=`pwd`

# > Install Homebrew
install_homebrew(){
    if `command -v brew > /dev/null 2>&1`; then
        echo '👌 Homebrew has been installed.'
    else
        echo '🍺 Try to install Homebrew now (link to Homebrew: https://brew.sh/)'
        # install script:
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        if [ $? -ne 0 ]; then
            echo '🍻 Homebrew has been installed successfully!'
        else
            echo '🚫 Install failed! Try to check your network!'
        fi
    fi
}

# > Change to diffrent Homebrew source
select_homebrew_mirror(){
    flag=0;
    while [ "$flag" != 1 ]
    do
        echo
        echo "      Please select the Homebrew mirror"
        echo "      请选择 Homebrew 镜像: "
        echo "      Deafult Select 1"
        echo "      1: Homebrew Default Mirror 官方源"
        echo "      2: 清华大学 Tuna 源"
        echo "      3: USTC 中科大源"
        echo
        read input

    case $input in
        1)
            echo "select_homebrew_mirror -> Debug: 1"
            _change_homebrew_default
            flag=1
            ;;
        2)
            echo "select_homebrew_mirror -> Debug: 2"
            _change_homebrew_tuna
            flag=1
            ;;
        3)
            echo "select_homebrew_mirror -> Debug: 3"
            _change_homebrew_tuna
            flag=1
            ;;
        *) change_homebrew_default
            echo "select_homebrew_mirror -> Debug: default"
            flag=1
            ;;
    esac
    done
}

_change_homebrew_default(){
    echo "Changing the homebrew mirror to: Deafult ..."
    git -C "$(brew --repo homebrew/core)" remote set-url origin https://github.com/Homebrew/homebrew-core.git
    git -C "$(brew --repo homebrew/cask)" remote set-url origin https://github.com/Homebrew/homebrew-cask.git
    echo "Change Finifh! Run 'brew update' now. "
    brew update
}

_change_homebrew_tuna(){
    echo "Changing the homebrew mirror to: Tuna（清华大学 Tuna 源） ..."
    echo "Reference from (参考): https://mirror.tuna.tsinghua.edu.cn/help/homebrew/ "
    git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
    git -C "$(brew --repo homebrew/cask)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git
    echo "Change Finifh! Run 'brew update' now. "
    brew update
}

_change_homebrew_ustc(){
    echo "Changing the homebrew mirror to: USTC（USTC 中科大源） ..."
    echo "Reference from (参考): https://lug.ustc.edu.cn/wiki/mirrors/help/brew.git "
    cd "$(brew --repo)"
    git remote set-url origin https://mirrors.ustc.edu.cn/brew.git
    cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
    git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git
    echo "Change Finifh! Run 'brew update' now. "
    brew update
}

# > Install List

list_install(){
    echo "Debug: list install Begin"
    for app in `cat $1`
    do
        install $app
    done
    echo "Debug: list install End"
}

# > Install Package
install() {
    # echo "Debug: install Begin"
    check_installation $1
    if [[ $? -eq 0 ]]; then
        echo "👌 ==> Installed" $1 ", skip..."
    else
        echo "🔥 ==> Installing: " $1
        # echo "Debug: Running brew install "
        brew install $1 > /dev/null
        echo $?
    fi

    if [[ $? -eq 0 ]]; then
        echo "🍺 ==> Install Success " $1
    else
        echo "🚫 ==> Install Fail" $1
    fi
}

# > Installed Package Checking
check_installation(){
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
show_menu() {
    echo
    read -p "✨ Select the package category to install [0]CLI [1]CASK(Default)" an
    echo

    case $ans in
        0) cd $WD && cat cli.txt && type="cli"
        ;;
        1) cd $WD && cat gui.txt && type="gui"
        ;;
        *) cd $WD && cat gui.txt && type="gui"
        ;;
    esac

    echo
}

# 检查AWK是否可用
check_awk() {
  if ! `command -v awk > /dev/null`; then
    echo 未检测到AWK，请先安装AWK再执行本程序...
    exit 127
  fi
}


#! 程序入口
echo
echo "🙏  请花5秒时间看一下上述注意事项"
sleep 5s
install_homebrew
while : ; do
    show_menu
    echo

    case $type in
    "cil")  list_install formula.list
    ;;
    "gui")  list_install cask.list
    ;;
    *) echo "Debug: error list"

    read  -p "📕 是否继续查看菜单列表，Y/y继续，N/n退出 ：" ans
    case $ans in
        Y|y) :
        ;;
        *) break
        ;;
    esac
done

