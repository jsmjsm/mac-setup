#! /bin/bash
###
 # @Description  :
 # @Author       : jsmjsm
 # @Github       : https://github.com/jsmjsm
 # @Date         : 2021-07-11 21:42:27
 # @LastEditors  : jsmjsm
 # @LastEditTime : 2021-07-11 22:07:52
 # @FilePath     : /mac-setup/Test/check_installation.sh
###

# > Installed Package Checking
install() {
    echo "Debug: install Begin"
    check_installation $1
    if [[ $? -eq 0 ]]; then
        echo "👌 ==> Installed" $1 ", skip..."
    else
        echo "🔥 ==> Installing " $1
        echo "Debug: Running brew install "
    fi
}

check_installation() {
    # if [[ $type == "cli" ]]; then
    brew list -1 | grep $1 > /dev/null

    if [[ $? -eq 0 ]]; then
        # not installed, return 0
        return 0
    fi

    # installed, return 1
    return 1
}

install $1

exit

