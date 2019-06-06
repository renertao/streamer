#!/bin/bash


### DEPENDENCIES ###############################################################
  # docbook2X
  # libcurl-devel expat-devel gettext-devel openssl-devel zlib-devel asciidoc xmlto perl-ExtUtils-MakeMaker autoconf


### BUGLIST ####################################################################
  # >>> config_git_alias, if not install git or has configured, then nothing to do
  #
  # >>> config_docbook2X, if not install docbook2X or has configured ,then nothing to do
  #
  # >>> config_git_completion, if not install git or has configured, then nothing to do


### operating parameters #######################################################
readonly WORKSPACE="/tmp/workspace_config_centos"


### package variables ##########################################################
readonly GIT_VERSION="2.19.1"
readonly GIT_SOURCE_PACKAGE_NAME="git-${GIT_VERSION}.tar.gz"
readonly GIT_SOURCE_PACKAGE_LINK="https://www.kernel.org/pub/software/scm/git/${GIT_SOURCE_PACKAGE_NAME}"


### utility function ###########################################################
function version_ge() { # ">="; arguments: version1, version2; return true/false
  test "$(echo -e "$@" | tr " " "\n" | sort -rV | head -n 1)" = "$1"
}

### package block ##############################################################
function config_docbook2X() {
  cd /usr/bin/
  ln -s db2x_docbook2texi docbook2x-texi
}

function install_git_from_source() {
  if [[ ! -d ${WORKSPACE} ]]; then mkdir ${WORKSPACE}; fi

  if ! command -v git >/dev/null 2>&1; then
    echo -e "-- git ${GIT_VERSION} installed [\e[31mFALSE\e[39m]"
  else
    if version_ge $(git --version | head -n 1 | gawk '{ print $3 }') ${GIT_VERSION}; then
      echo -e "-- git $(git --version | head -n 1 | gawk '{ print $3 }') ( >= ${GIT_VERSION}) installed [\e[32mTRUE\e[39m]"
      exit
    else
      echo -e "-- git ${GIT_VERSION} installed [\e[31mFALSE\e[39m]"
    fi
  fi

  local package_install_from_yum="
    docbook2X
    libcurl libcurl-devel
    expat expat-devel
    gettext gettext-devel
    openssl openssl-devel
    zlib zlib-devel
    asciidoc
    xmlto
    perl-ExtUtils-MakeMaker
    autoconf"
  yum install -y ${package_install_from_yum}
  config_docbook2X

  cd ${WORKSPACE}

  if [[ ! -f ${GIT_SOURCE_PACKAGE_NAME} ]]; then
    wget ${GIT_SOURCE_PACKAGE_LINK} -O ${GIT_SOURCE_PACKAGE_NAME}
  fi
  local source_dir="git-${GIT_VERSION}"
  if [[ -d ${source_dir} ]]; then
    rm -rf ${source_dir}
  fi
  mkdir ${source_dir}
  tar -xzf ${GIT_SOURCE_PACKAGE_NAME} --directory ${source_dir} --strip-components=1
  cd ${source_dir}

  make configure
  ./configure --prefix=/usr
  make -j $(nproc) all doc info
  make install install-doc install-html install-info

  if ! command -v git >/dev/null 2>&1; then
    echo -e "-- git installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- git installed [\e[32mTRUE\e[39m] $(which git) $(git --version | head -n 1 | gawk '{ print $3 }')"
  fi

  config_git_alias
  config_git_completion
}

function config_git_alias() {
  git config --global alias.br "branch"
  git config --global alias.ci "commit"
  git config --global alias.co "checkout"
  git config --global alias.cp "cherry-pick"
  git config --global alias.fe "fetch"
  git config --global alias.last "log -1 HEAD"
  git config --global alias.lg "log --oneline --graph --decorate"
  git config --global alias.st 'status'
  git config --global alias.unstage "reset HEAD --"
}

function config_git_completion() {
  local git_completion_file="git-completion.bash"
  local git_completion_place="${HOME}/.${git_completion_file}"

  if [[ -f ${git_completion_place} ]]; then
    echo -e "-- ${git_completion_place} existed [\e[32mTRUE\e[39m]"
  else
    echo -e "-- ${git_completion_place} existed [\e[31mFALSE\e[39m]"
  fi

  while :; do
    read -p "to (re-)config ${git_completion_place} [y/N]: " result
    case ${result} in
      y | Y)
        break ;;
      n | N)
        return ;;
      *) ;;
    esac
  done

  wget https://raw.githubusercontent.com/git/git/master/contrib/completion/${git_completion_file} -O ${git_completion_place}
  if [[ -f ${git_completion_place} ]]; then
    echo -e "-- ${git_completion_place} downloaded [\e[32mTRUE\e[39m]"
  else
    echo -e "-- ${git_completion_place} downloaded [\e[31mFALSE\e[39m]"
    return
  fi

  sed -i '$ a\source ${HOME}/.git-completion.bash' ${HOME}/.bashrc
  source ${HOME}/.bashrc
}


### main #######################################################################
# set -x
echo "- start to install git from source ..."
install_git_from_source
echo "- finished installing git from source ..."
exit
