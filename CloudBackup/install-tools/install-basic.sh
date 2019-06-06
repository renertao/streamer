#!/bin/bash

### TODOLIST ###################################################################
  # report gdb
  # report htop
  # report man-pages
  # report net-tools
  # report psmisc
  # report tcpdump
  # report valgrind
  # install perl-ExtUtils-MakeMaker?
  ##############################################################################


### BUGLIST ####################################################################
  # nothing

### Workflow ###################################################################
  # pre-config
  # [✓] config /etc/environment
  # install
  # [?] yum
  # [✓] epel-release (Extra Packages for Enterprise Linux)
  # [✓] gawk
  # [✓] atop
  # [✓] curl
  # [✓] gcc
  # [✓] gcc-c++
  # [✓] gdb
  # [✓] htop
  # [✓] make
  # [✓] man
  # [✓] man-pages
  # [✓] net-tools
  # [✓] ntp
  # [✓] openssh
  # [✓] psmisc
  # [✓] tar
  # [✓] tcpdump
  # [✓] tree
  # [✓] valgrind
  # [✓] vim
  # [✓] wget
  # post-config
  # [✗] ntp
  # [?] openssh
  # [?] vim
  # report
  ##############################################################################


### type definition ############################################################
  # DO NOT modify type definition
  readonly BOOL_TRUE=1
  readonly BOOL_FALSE=0


### operating parameters #######################################################
  readonly WORKSPACE="/tmp/workspace_config_centos"
  readonly VIM_CONFIG_VIMRC_FILE_PATH="${HOME}/.vimrc"


### control function ###########################################################
function initialize() {
  if [[ ! -d ${WORKSPACE} ]]; then mkdir ${WORKSPACE}; fi
}

function install() {
  echo "- installing"

  local need_update_yum=${BOOL_FALSE}
  while :; do
    read -p "To update yum [y/N]: " result
    case ${result} in
      y | Y)
        need_update_yum=${BOOL_TRUE}
        break ;;
      n | N) break ;;
      *) ;;
    esac
  done

  test ${need_update_yum} -eq ${BOOL_FALSE} || yum update -y

  if [[ $(rpm -qa epel-release) == "" ]]; then
    yum install -y epel-release
  fi

  local packages="
    gawk
    atop
    curl
    gcc
    gcc-c++
    gdb
    htop
    make
    man
    man-pages
    ntp
    net-tools
    openssh
    psmisc
    tar
    tcpdump
    tree
    valgrind
    vim-enhanced
    wget"

  if [[ $(echo -e "${packages}" | sed -n '/[[:alnum:]]/p') == "" ]]; then
    echo -e "-- no basic packages need install."
  else
    echo -e "Start installing ${packages}"
    yum install -y ${packages}
  fi

  echo "- installed"
}

function report() {
  echo "- reporting"

  report_atop
  report_curl
  report_epel_release
  report_gawk
  report_gcc
  report_gcc_cxx
  report_man
  report_ntp
  report_openssh
  report_tree
  report_vim
  report_wget

  echo "- reported"
}

function shutdown() {
  while :; do
    read -p "to remove ${WORKSPACE} [y/N]: " result
    case ${result} in
      y | Y)
        rm -rfv ${WORKSPACE}
        break ;;
      n | N) break ;;
      *) ;;
    esac
  done
}

## basic block #################################################################
function pre_config() { # config /etc/environment
  echo "- configuring environment"

  local path="/etc/environment"
  if [ -f ${path} ] && [ ! -s ${path} ]; then
    # echo -e "-- ${path} existed but empty"
    rm -f ${path}
  fi
  if [[ ! -f ${path} ]]; then
    # echo -e "-- ${path} existed [\e[31mFALSE\e[39m]"
    # echo "-- will create '${path}'"
    cat <<EOF >${path}
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
EOF
  else
    echo -e "-- ${path} existed [\e[32mTRUE\e[39m]"
    if grep -Fxq "^LANG" ${path}; then
      sed -i '$a\LANG=en_US.utf-8' ${path}
    fi
    if grep -Fxq "^LC_ALL" ${path}; then
      sed -i '$a\LC_ALL=en_US.utf-8' ${path}
    fi
  fi
}

function post_config() {
  echo "- configuring"
  # config_ntp
  config_openssh
  config_vim
  echo "- configured"
}


## package block ###############################################################

# atop
function report_atop() {
  if ! command -v atop >/dev/null 2>&1; then
    echo -e "-- atop installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- atop installed [\e[32mTRUE\e[39m] $(which atop) $(atop -V | head -n 1 | gawk '{ print $2 }')"
  fi
}

# curl
function report_curl() {
  if ! command -v curl >/dev/null 2>&1; then
    echo -e "-- curl installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- curl installed [\e[32mTRUE\e[39m] $(which curl) $(curl --version | head -n 1 | gawk '{ print curl }')"
  fi
}

# epel-release
function report_epel_release() {
  if [[ $(rpm -qa epel-release) == "" ]]; then
    echo -e "-- epel-release installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- epel-release installed [\e[32mTRUE\e[39m]"
  fi
}

# gawk
function report_gawk() {
  if ! command -v gawk >/dev/null 2>&1; then
    echo -e "-- gawk installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- gawk installed [\e[32mTRUE\e[39m] $(which gawk) $(gawk --version | head -n 1 | gawk '{ print $3 }')"
  fi
}

# gcc
function report_gcc() {
  if ! command -v gcc >/dev/null 2>&1; then
    echo -e "-- gcc installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- gcc installed [\e[32mTRUE\e[39m] $(which gcc) $(gcc --version | head -n 1 | gawk '{ print $3 }')"
  fi
}

# gcc-c++
function report_gcc_cxx() {
  if [[ $(rpm -qa gcc-c++) == "" ]]; then
    echo -e "-- gcc-c++ installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- gcc-c++ installed [\e[32mTRUE\e[39m]"
  fi
}

# man
function report_man() {
  if ! command -v man >/dev/null 2>&1; then
    echo -e "-- man installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- man installed [\e[32mTRUE\e[39m] $(which man) $(man --version | head -n 1 | gawk '{ print $2 }')"
  fi
}

# ntp
function report_ntp() {
  if [[ $(rpm -qa ntp) == "" ]]; then
    echo -e "-- ntp installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- ntp installed [\e[32mTRUE\e[39m]"
  fi
}

function config_ntp() { # config ntp, system datetime
  date
  while :; do
    read -p "need restart ntpd [y/N]: " result
    case ${result} in
      y | Y)
        service ntpd restart
        service ntpd status
        date
        break ;;
      n | N)
        break ;;
      *) ;;
    esac
  done
}

# openssh
function report_openssh() {
  if ! command -v ssh >/dev/null 2>&1; then
    echo -e "-- openssh installed [\e[31mFALSE\e[39m]"
  else
    # 不能打印版本信息
    # echo -e "-- openssh installed [\e[32mTRUE\e[39m] $(which ssh) $(ssh -V | head -n 1 | gawk '{ print $1 }')"
    echo -e "-- openssh installed [\e[32mTRUE\e[39m] $(which ssh)"
  fi
}

function config_openssh() {
  local file="${HOME}/.ssh/id_rsa"

  if [[ ! -f ${file} ]]; then
    echo -e "Exists ${file} [\e[31mFALSE\e[39m]"
  else
    echo -e "Exists ${file} [\e[32mTRUE\e[39m]"
  fi

  local need_config=${BOOL_FALSE}
  while :; do
    read -p "need (re-)config ${file} [y/N]: " result
    case ${result} in
      y | Y)
        need_config=${BOOL_TRUE}
        break ;;
      n | N)
        break ;;
      *) ;;
    esac
  done

  if [ ${need_config} -eq ${BOOL_TRUE} ]; then
    ssh-keygen -t rsa -b 4096 -f ${file}
  fi
}

# tree
function report_tree() {
  if ! command -v tree >/dev/null 2>&1; then
    echo -e "-- tree installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- tree installed [\e[32mTRUE\e[39m] $(which tree) $(tree --version | head -n 1 | gawk '{ print $2 }')"
  fi
}

# vim
function report_vim() {
  if ! command -v vim >/dev/null 2>&1; then
    echo -e "-- vim-enhanced installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- vim-enhanced installed [\e[32mTRUE\e[39m] $(which vim) $(vim --version | head -n 1 | gawk '{ print $5 }')"
  fi
}

function config_vim() { # config vim
  if [[ ! -f ${VIM_CONFIG_VIMRC_FILE_PATH} ]]; then
    echo -e "Exists ${VIM_CONFIG_VIMRC_FILE_PATH} [\e[31mFALSE\e[39m]"
  else
    echo -e "Exists ${VIM_CONFIG_VIMRC_FILE_PATH} [\e[32mTRUE\e[39m]"
  fi

  local need_config=${BOOL_FALSE}
  while :; do
    read -p "need (re-)config ${VIM_CONFIG_VIMRC_FILE_PATH} [y/N]: " result
    case ${result} in
      y | Y)
        need_config=${BOOL_TRUE}
        break ;;
      n | N)
        break ;;
      *) ;;
    esac
  done

  if [ ${need_config} -eq ${BOOL_TRUE}  ]; then
    cat <<EOF >${VIM_CONFIG_VIMRC_FILE_PATH}
" 检测文件类型
filetype on
" 允许插件
filetype plugin on
" 针对不同文件类型采用不同的缩进格式
filetype indent on

" 设置Tab键的宽度
set tabstop=2
" 每一次缩进对应的空格数
set shiftwidth=2
" 按退格键时可以一次删掉的空格数
set softtabstop=2
" 将Tab键自动转换成空格，Ctrl+V+Tab输入Tab字符 
set expandtab

" 显示行号
set nu

" 自动缩进
set autoindent

" 新文件编码
set encoding=utf-8

" 阻止粘贴时自动缩进
" set paste
EOF
    source ${VIM_CONFIG_VIMRC_FILE_PATH}
  fi
}

# yum
function report_yum() {
  if ! command -v yum >/dev/null 2>&1; then
    echo -e "-- yum installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- yum installed [\e[32mTRUE\e[39m] $(which yum) $(yum --version | head -n 1 | gawk '{ print $1 }')"
  fi
}

# wget
function report_wget() {
  if ! command -v wget >/dev/null 2>&1; then
    echo -e "-- wget installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- wget installed [\e[32mTRUE\e[39m] $(which wget) $(wget --version | head -n 1 | gawk '{ print $3 }')"
  fi
}


### main ########################################################################

# set -x
echo "- start to working ..."
initialize
pre_config
install
report
post_config
shutdown
echo "- finished working ..."
echo "-- if /etc/environment is configured will need reboot"
exit
