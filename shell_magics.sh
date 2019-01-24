#!/bin/bash

### VERSION 1.2

NETENTUSER=`whoami`
NC='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
CYAN_LIGHT='\033[0;36m'
WHITE='\033[1;37m'

SNAPSHOT_VERSION='mvn -q -Dexec.executable=echo -Dexec.args=${project.version} --non-recursive exec:exec'

usage (){
  echo "Usage: $0 ";
  echo "Flag/Option             Description"
  echo "-----------             -----------"
  echo "--help                  Shows this information."
  echo "--dry                   Does a dry run, cloning all repos, checking out correct versions but does not execute anything."
  echo "-v | --verbose          Prints every command to stdout as well as log."
  echo "-c | --create           Create database (if not, assumed existing.)"
  echo "-p | --pull             Pulls all the git repositories for latest master commits."
  exit 0
}

print_white(){
  echo -e "${WHITE}---- $1 ${NC}"
}

print_cyan(){
  echo -e "${CYAN}---- $1${NC}"
}
print_lcyan(){
  echo -e "${CYAN_LIGHT}---- $1${NC}"
}

print_green(){
  echo -e "${GREEN}---- $1${NC}"
}

mvn_err_check(){
  if [[ "$?" -ne 0 ]] ; then
    echo -e "${RED}Maven install failed${NC}"; exit $rc
  else
    print_green "Maven install: Successful."
  fi
}

mvn_clean_install_nargs(){
  mvn clean install 2>&1 | tee -a $TEMP_PATH/build.log >&3 $ERROR
  mvn_err_check
}


# Checks out repo.
# Parameter: master or release tag version
# Default: latest release tag
git_checkout(){
  if [[ $1 == "master" ]]; then
    git checkout master 2>&1 | tee -a $TEMP_PATH/build.log >&3
    ENDPATH=$(basename $(pwd))
    print_white "Checking out $ENDPATH-`$SNAPSHOT_VERSION`";
  elif [[ $1 ]]; then
    print_white "Checking out $1"
    git checkout $1 2>&1 | tee -a $TEMP_PATH/build.log >&3
  else
    TAG=`git describe --abbrev=0`
    print_white "Checking out $TAG"
    git checkout $TAG 2>&1 | tee -a $TEMP_PATH/build.log >&3
  fi
  if [[ "$?" -ne 0 ]] ; then
    echo -e "${RED}GIT checkout failed! Exiting... See log file.${NC}"; exit $rc
  fi
}


git_pull(){
  print_lcyan "Pulling latest git commit"
  git pull 2>&1 | tee -a $TEMP_PATH/build.log >&3
}

do_X(){
  read -p "Are you sure you want to do X? y/n " -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ $DRY_RUN == 0 ]]; then
      mvn_clean_install_nargs 
    fi
  fi
}

PARAMS=""
DRY_RUN=0
ERROR=0

#FD 3 for verbose
exec 3>/dev/null;

while (( "$#" )); do
  case "$1" in
    --database-name)
      DATABASE_NAME=$2;shift 2;;
    --dry|--DRY|-dry|-DRY)
      DRY_RUN=1;shift 1;;
    --DROP|--drop)
      DROP_DATABASE=1;shift 1;;
    -v|--verbose)
      exec 3>&1
      shift 1;;
    -p|-pull)
      GIT_PULL=1;shift 1;;
    --help)
      usage;;
    --) # end argument parsing
      shift;break;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2; usage;exit 1;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done


#echo "$HOSTNAME";echo "$DATABASE_NAME";echo "$SPP_VERSION";echo "$NQ_VERSION";echo "Tri8: $TRI8"; echo "DRY_RUN: $DRY_RUN";exit 1;


mkdir repos 2> /dev/null; cd repos;
TEMP_PATH=`pwd`
touch build.log




exec 3>&-
