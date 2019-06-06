#!/bin/bash


### DEPENDENCIES ###############################################################
  # bison texlive-epstopdf latex dvips graphviz?


### BUGLIST ####################################################################
  # dependent on epstopdf, latex and dvips, but build failed with texlive-dvips(svn29585.0-38.el7)
  # texlive-latex(svn27907.0-38.el7), so disable docs
  # >>> doxygen, build doxygen docs failed
  #
  # 不确定是否需要安装 graphviz


### operating parameters #######################################################
readonly WORKSPACE="/tmp/workspace_config_centos"


### package variables ##########################################################
readonly DOXYGEN_VERSION="1.8.14"  # must update version in DOXYGEN_SOURCE_PACKAGE_LINK     👇
readonly DOXYGEN_SOURCE_PACKAGE_NAME="doxygen-${DOXYGEN_VERSION}.tar.gz"  # 👇
readonly DOXYGEN_SOURCE_PACKAGE_LINK="https://github.com/doxygen/doxygen/archive/Release_1_8_14.tar.gz"


### utility function ###########################################################
function version_ge() { # ">="; arguments: version1, version2; return true/false
  test "$(echo -e "$@" | tr " " "\n" | sort -rV | head -n 1)" = "$1"
}


### package block ##############################################################
function install_doxygen_from_source() {
  if [[ ! -d ${WORKSPACE} ]]; then mkdir ${WORKSPACE}; fi

  if ! command -v doxygen >/dev/null 2>&1; then
    echo -e "-- doxygen ${DOXYGEN_VERSION} installed [\e[31mFALSE\e[39m]"
  else
    if version_ge $(doxygen --version | head -n 1 | gawk '{ print $1 }') ${DOXYGEN_VERSION}; then
      echo -e "-- doxygen $(doxygen --version | head -n 1 | gawk '{ print $1 }') (>= ${DOXYGEN_VERSION}) installed [\e[32mTRUE\e[39m]"
      exit
    else
      echo -e "-- doxygen ${DOXYGEN_VERSION} installed [\e[31mFALSE\e[39m]"
    fi
  fi

  local package_install_from_yum="
      bison"
  yum install -y ${package_install_from_yum}

  cd ${WORKSPACE}

  test -f ${DOXYGEN_SOURCE_PACKAGE_NAME} || wget ${DOXYGEN_SOURCE_PACKAGE_LINK} -O ${DOXYGEN_SOURCE_PACKAGE_NAME}
  local source_dir="doxygen-${DOXYGEN_VERSION}"
  test -d ${source_dir} && rm -rf ${source_dir}
  mkdir ${source_dir}
  tar -xzf ${DOXYGEN_SOURCE_PACKAGE_NAME} --directory ${source_dir} --strip-components=1
  cd ${source_dir}

  mkdir build; cd build; cmake ..; make -j $(nproc); make install
  # mkdir build; cd build; cmake .. -Dbuild_doc=YES; make -j $(nproc) all docs; make install all docs

  if ! command -v doxygen >/dev/null 2>&1; then
    echo -e "-- doxygen installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- doxygen installed [\e[32mTRUE\e[39m] $(which doxygen) $(doxygen --version | head -n 1 | gawk '{ print $1 }')"
  fi
}


### main #######################################################################
# set -x
echo "- start to install doxygen from source ..."
install_doxygen_from_source
echo "- finished installing doxygen from source ..."
exit
