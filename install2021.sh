#! /bin/bash

cat << -EOF
#######################################################################
# 当前脚本用于在运行OS X的电脑上安装应用程序
# 原理为：利用homebrew作为OS X的包管理器
#         brew install 安装命令行程序
#         brew install 安装GUI程序
#         Happy coding ~ Happy life.
#
# 原 Github: https://github.com/jsycdut/mac-setup
# 2021 更新 Github： https://github.com/jsmjsm/mac-setup
#
# 祝使用愉快，有问题的话可以去GitHub提issue
#
# 注意事项
#
# 1. OS X尽量保持较新版本，否则可能满足不了Homebrew的依赖要求
# 2. 中途若遇见安装非常慢的情况，可用Ctrl+C打断，直接进行下一项的安装
#######################################################################
-EOF

# 全局变量
row_number=0
column_number=0
type=cli
WD=`pwd`

# 安装Homebrew并换TUNA源
install_homebrew() {
  if `command -v brew > /dev/null 2>&1`; then
    echo '👌  Homebrew已安装'
  else
    echo '🍼  正在安装Homebrew'
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [[ $? -eq 0  ]]; then
      echo '🍻  Homebrew安装成功'
    else
      echo '🚫  Homebrew安装失败，请检查网络连接...'
      exit 127
    fi
  fi

  echo '👍  为了让brew运行更加顺畅，将使用中国科学技术大学USTC提供的镜像，更新中，请等待...'
  cd "$(brew --repo)"
  git remote set-url origin https://mirrors.ustc.edu.cn/brew.git

  cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
  git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git

  cd "$(brew --repo)"/Library/Taps/homebrew/homebrew-cask
  git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-cask.git

  brew update
}

# 检查是否已安装某软件包
check_installation() {
  if [[ $type == "cli" ]]; then
    brew list -l | grep $1 > /dev/null
  else
    brew list -1 | grep $1 > /dev/null
  fi

  if [[ $? -eq 0 ]]; then
     return 0
  fi

  return 1
}

# 使用brew安装软件包
install() {
  check_installation $1
  if [[ $? -eq 0 ]]; then
    echo "👌 ==>已安装" $1 "，跳过..."
  else
    echo "🔥 ==>正在安装 " $1
    if [[ "$type" == "cli" ]]; then
      brew install $1 > /dev/null
      echo $?
    else
      brew install $1 > /dev/null
    fi

    if [[ $? -eq 0 ]]; then
      echo "🍺 ==>安装成功 " $1
    else
      echo "🚫 ==>安装失败 " $1
    fi
  fi
}

# 显示菜单
show_menu() {
  echo
  read  -p "✨ 请选择要显示的软件包菜单列表类型 [0]命令行 [1]图形化(默认)：" ans
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

# 利用awk，从cli.txt gui.txt两文件中截取软件包名称
get_package_name() {
  local file_name=$1
  local row=$2
  local col=$3
  awk -v line=$row -v field=$col '{if(NR==line){print $field}}' $file_name
}

# 计算与软件名称编号对应的行和列号码
# 不要破坏cli.txt gui.txt文件排版
# 否则会导致计算行列值失败，进而无法提取出正确的软件包名称
locate() {
  local tmp=`expr $1 + 2`
  row_number=`expr $tmp \/ 3`
  tmp=`expr $1 % 3`
  [ $tmp -eq 0 ] && tmp=3
  column_number=`expr $tmp \* 3 - 1`
}

# > 程序入口
echo
echo "🙏  请花5秒时间看一下上述注意事项"
sleep 5s
install_homebrew
while : ; do
  show_menu
  read  -p "✍️  请输入您想要安装的软件包的编号（多个软件包请用空格分隔，直接回车则全部安装）" ans
  echo
  IFS=$'\n'
  read -d "" -ra arr <<< "${ans//' '/$'\n'}" # 本脚本中最喜欢的一句代码了

  # 处理单纯的回车
  if [[ "${#arr[@]}" -eq 0 ]]; then
    lines=`wc -l "$type"".txt" | awk '{printf $1}'`
    count=`expr $lines \* 3`
    for((i=0; i<$count; i++)); do
      arr[$i]=`expr $i + 1`
    done
  fi

  for app in ${arr[*]}; do
    if [ $app -eq $app 2>/dev/null ]; then
      :
    else
      continue
    fi

    locate $app
    name=`get_package_name "$type"".txt" $row_number $column_number`
    [ -z "$name" ] && continue
    install $name
  done

  read  -p "📕 是否继续查看菜单列表，Y/y继续，N/n退出 ：" ans
  case $ans in
    Y|y) :
    ;;
    *) break
    ;;
  esac
done

# 更改回Homebrew的官方源
cat << EOF
  目前正在使用中国科学技术大学的Homebrew源，建议没有配置网络代理的同学，
  保持现有状况，不要切回官方源，否则会导致以后安装软件包的下载速度缓慢，
  对于配置了网络代理的同学，也可以选择将源切换回官方的源。
EOF

sleep 1s
read  -p "是否需要将Homebrew的源改回为官方源，[Y/y]确认，直接回车将跳过" ans
case $ans in
  Y|y)
    echo "正在将Homebrew的源切换回官方源..."
    cd "$(brew --repo)"/Library/Taps/homebrew/homebrew-cask
    git remote set-url origin https://github.com/Homebrew/homebrew-cask
    cd "$(brew --repo)"
    git remote set-url origin https://github.com/Homebrew/brew.git
    cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
    git remote set-url origin https://github.com/Homebrew/homebrew-core
    echo "已将Homebrew的源切换回官方源."
  ;;
esac
