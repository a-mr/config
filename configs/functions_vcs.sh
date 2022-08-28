##############################################################################
# functions for working with version control repositories & others

# fetch & checkout Github PR
github () {
    git fetch origin pull/$1/head:pull/$1/head
    git co pull/$1/head
}

# Usage : hgdiff file -r rev
hgdiff () {
    hg cat $1 $2 $3 $4 $5 $6 $7 $8 $9| vim -g - -c  ":vert diffsplit $1" -c "map q :qa\!<CR>";
}

hgvim () {
    vim `hg sta -m -a -r -n $@`
}

hgfix () {
    hg commit -m "never-push work-in-progress `$DATE_COMMAND`. If you see this commit then please notify me about it."
}

hgsea () {
    hg log | gg -C10 $@
}

hgtagb () {
    hg log --rev="branch(`hg branch`) and tag()" --template="{tags}\n"
}

what_is_repo_type () {
    if git branch >/dev/null 2>/dev/null; then echo -n git
    elif hg root >/dev/null 2>/dev/null; then echo -n mercurial
    elif svn info >/dev/null 2>/dev/null; then echo -n svn
    else echo -n 'unknown'
    fi
}

report_repo_type () {
    echo 'repository here ' `pwd` :
    bold_echo `what_is_repo_type`
}


inf () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) 
          local branch="${1:-$(bra)}"
          git describe --all; git branch -vv | grep "$branch"; git remote -v
          dat "$branch"
          git diff --stat
          ;;
      mercurial) hg id; hg paths
          ;;
      svn) svn info
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

logmy () {
    git log --graph --all --tags --name-status --parents \
        --abbrev-commit --decorate=full \
        --author `git config --get user.email` $@ | pg
}

log () {
    REPO=`what_is_repo_type`
    case "$REPO" in
        git) git log --graph --all --tags --name-status \
            --parents --abbrev-commit --decorate=full $@ | pg
            ;;
        mercurial) hg log -v $@ | pg
            ;;
        svn) svn log $@ | pg
            ;;
        *) red_echo unknown repository: $REPO
  esac
}
# fix autocompletion
[[ $CURSHELL == zsh ]] && compdef '_dispatch ls ls' log

# print graph for all branches
gra () {
    REPO=`what_is_repo_type`
    case "$REPO" in
        git) git log --oneline --tags --all --graph --decorate=full $@ | pg
            ;;
        mercurial) hg log $@ | pg
            ;;
        svn) svn log $@ | pg
            ;;
        *) red_echo unknown repository: $REPO
  esac
}

# log with changes (-p)
lgf () {
    if [[ "$1" == "" ]]; then
        git log -p --decorate=full --parents $@ | pg
    else
        git log -p --decorate=full --follow --parents $@ | pg
    fi
}

# show all changes in the current (or specified in 1st argument) branch
difb () {
  REPO=`what_is_repo_type`
  local default=$(dbr)
  case "$REPO" in
      git) 
          if [ -z "$1" ] || [[ "$1" == "--" ]]; then
              branch=$(bra)
          else
              branch=$1
              shift 1
          fi
          if [[ "$branch" == "$default" ]]; then
              red_echo default branch was provided
          else
              git diff $(git merge-base $branch $default)..$branch $@ | less
          fi
          ;;
      mercurial)
          # see https://stackoverflow.com/questions/13991969/mercurial-see-changes-on-the-branch-ignoring-all-the-merge-commits
          hg export -r "branch('$(hg branch)') and not merge()" | less
          ;;
      svn) red_echo not implemented
          ;;
      *) red_echo unknown repository: $REPO

  esac
}

# show log for specified branch
lgb () {
  REPO=`what_is_repo_type`
  local default=$(dbr)
  case "$REPO" in
      git) 
          if [ -z "$1" ] || [[ "$1" == "--" ]]; then
              branch=$(bra)
          else
              branch=$1
              shift 1
          fi
          if [[ "$branch" == "$default" ]]; then
              git log --graph --name-status \
              --parents --decorate=full --abbrev-commit $default $@ | pg
          else
              git log --graph --name-status \
              --parents --decorate=full --abbrev-commit $(git merge-base $branch $default)..$branch $@ | pg
          fi
          ;;
      mercurial) hg log -b `hg branch`
          ;;
      svn) svn log --use-merge-history --verbose $@ # TODO: URL required
          ;;
      *) red_echo unknown repository: $REPO

  esac
}

# show stashed changes
sho () {
    git stash show -p $@
}

# squash commits
squ () {
  local default=$(dbr)
  local branch=$(bra)
  git rebase -i $(git merge-base $branch $default)
}

# graph for feature branch
grb () {
  REPO=`what_is_repo_type`
  local default=$(dbr)
  case "$REPO" in
      git) 
          if [ -z "$1" ] || [[ "$1" == "--" ]]; then
              branch=$(bra)
          else
              branch=$1
              shift 1
          fi
          if [[ "$branch" == "$default" ]]; then
              git log --decorate=full --oneline --graph $default $@ | pg
          else
              git log --decorate=full --oneline --graph \
                  $(git merge-base $branch $default)..$branch $@ | pg
          fi
          ;;
      mercurial) hg log $@ | pg
          ;;
      svn) svn log $@ | pg
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# show only branch log in git (approximately, using --first-parent)
gitlogb () {
    if [ "$1" -eq "" ]; then
        local branch="$(bra)"
    else
        local branch="$1"
    fi
    git log --decorate=full --graph --tags --name-status --first-parent "$branch" | pg
}

gitgrb () {
    if [ "$1" -eq "" ]; then
        local branch="$(bra)"
    else
        local branch="$1"
    fi
    git log --decorate=full --graph --oneline --first-parent "$branch" | pg
}

# `has revision branch` check that branch contains revision
function has {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git merge-base --is-ancestor $1 ${2:-$(bra)}
           if [ $? -eq 0 ]; then
              echo Yes
           else
              echo No
           fi
          ;;
      mercurial) hg log -r $1 -b $2
          ;;
      svn) echo not implemented for svn
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

cnt () {
    git rebase --continue
}

# history of all changes to file(s)
his () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git log --decorate=full --follow -p -- $@|p
          ;;
      mercurial) hg record $@|p
          ;;
      svn) svn log --diff $@|p
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

ann () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git blame --date=short $@ | less -S
          ;;
      mercurial) hg ann -b $@ | less -S
          ;;
      svn) svn ann $@ | less -S
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# whether to print version info in PS1
if [ "$SCREEN_WORK_SESSION" = "true" ]; then
    wrepo="any"
else
    wrepo="none"
fi
wrepo () {
    if [ "$wrepo" = "none" ]; then
        wrepo="any"
    else
        wrepo="none"
    fi
}

bra () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git branch | grep \^\* | cut -d ' ' -f2-
          ;;
      mercurial) hg branch
          ;;
      svn) svn info | grep '^URL:' | egrep -o '(tags|branches)/[^/]+|trunk' | egrep -o '[^/]+$'
          ;;
      *) echo -n $REPO
  esac
}

# list branches
lsb () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git branch
          ;;
      mercurial) hg branches --active
          ;;
      svn) svn info | grep '^URL:'
          ;;
      *) echo -n $REPO
  esac
}

# default branch
dbr () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git)
          local remote_head
          remote_head="`git symbolic-ref refs/remotes/origin/HEAD`" 2>/dev/null
          if [ $? -eq 0 ]; then
              echo $remote_head | sed 's@^refs/remotes/origin/@@'
          else  # go long way
              git remote show origin | awk '/HEAD branch/ {print $NF}'
          fi
          ;;
      mercurial) echo default
          ;;
      svn) echo trunk
          ;;
      *) echo -n $REPO
  esac
}

# print the date of commit id $1
dat () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) 
          if [[ "$1" != "" ]]; then
              local id="$1"
          else
              local id="HEAD"
          fi
          git log -1 --format="%at" $id | xargs -I{} $DATE_COMMAND -d @{} +%y-%b-%d\ %H:%M
          ;;
      mercurial) echo "d:hg"
          ;;
      svn) echo "d:svn"
          ;;
      *) echo -n $REPO
  esac
}

# print the date of commit id $1
datshort () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) 
          if [[ "$1" != "" ]]; then
              local id="$1"
          else
              local id="HEAD"
          fi
          git log -1 --format="%at" $id | xargs -I{} $DATE_COMMAND -d @{} +%b%d
          ;;
      mercurial) echo "d:hg"
          ;;
      svn) echo "d:svn"
          ;;
      *) echo -n $REPO
  esac
}

# show files that are in repository
lsf () {
    git ls-files --error-unmatch $@
}

sta () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git status -s $@ | sed 's/\(.\{2\}\)./ \1 : /' | pb
          ;;
      mercurial) hg status $@ | pb
          ;;
      svn) svn status $@ | pb
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# colored diff
dif () {
  REPO=`what_is_repo_type`
  if [ ! -f "$1" -a ! -d "$1" ]; then
      red_echo file/dir $1 not found
  fi
  case "$REPO" in
      git)
          git diff -r HEAD -- $@|less
          ;;
      mercurial) hg diff $@|less
          ;;
      svn) svn diff $@|less
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# VCS diff for specific file without colors (for patch)
difp () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git)
          if [ ! -f $1 ]; then
              red_echo file $1 not found
          fi
          git diff --color=never -r HEAD -- $@|less
          ;;
      mercurial) hg diff --color=never $@|less
          ;;
      svn) svn diff --color=never $@|less
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# print file contents at given revision
pri () {
  local rev="$1"
  local file="$2"
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git show "$rev:$file" | less -X
          ;;
      mercurial) hg cat -r $rev "$file" | less -X
          ;;
      svn) svn cat -r $rev "$file" | less -X
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# print history for given line: `lin <number> <file>`
lin () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git log -L $1,$1:"$2"
          ;;
      mercurial) red_echo not implemented
          ;;
      svn) red_echo not implemented
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# show patch for a given revision
pat () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git show --parents $@ | less
          ;;
      mercurial) hg diff -c $@ | less
          ;;
      svn) svn diff -c $@ | less
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# the same but with full files contents (1000 lines of context)
patf () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git show --parents -U1000 $@ | less -X
          ;;
      mercurial) hg diff -c $@ | less -X
          ;;
      svn) svn diff -c $@ | less -X
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

add () {
  for i in "$@"; do
    echo adding $i
    if [ -d "`dirname $i`" ]; then
        cd "`dirname $i`"
    else
        red_echo no such directory
        return 2
    fi
    local file="`basename $i`"
    REPO=`what_is_repo_type`
    case "$REPO" in
        git) git add $file
            ;;
        mercurial) hg add $file
            ;;
        svn) svn add $file
            ;;
        *) red_echo unknown repository: $REPO
    esac
    local exit_code=$?
    cd -
    if [ $exit_code -ne 0 ]; then
        return $exit_code
    fi
  done
}

roo () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git rev-parse --show-toplevel
          ;;
      mercurial) hg root
          ;;
      *) red_echo unknown repository: $REPO
  esac
}
    
com () {
  REPO=`what_is_repo_type`
  if [ "`dbr`" = "`bra`" ]; then
      bold_echo "Commit to default branch? [n|y]"
      local answer
      read answer
      if [ "$answer" != "y" ]; then
          return
      fi
  fi
  local msg=""
  if [ "$1" != "" ]; then
      msg="-m \"$1\""
  fi
  case "$REPO" in
      git) #git add -u :/ && 
          eval git commit $msg && \
               mydialog "push?[n|y|f]" "n green_echo Done" \
               "y git push origin \"$(bra)\"" "f git push origin -f \"$(bra)\""
          ;;
      mercurial) eval hg commit $msg && (
          if grep default `hg root`/.hg/hgrc > /dev/null 2>&1; then
              mydialog "push?" "y hg push" "n green_echo Done"
          else
              yellow_echo no default repository to push
          fi)
          ;;
      svn) eval svn commit $msg
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# save changes
sav () {
    git stash save $@
}

# restore changes
res () {
    git stash pop --index $@
}

pus () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git push origin "$(bra)" $@
          ;;
      mercurial) hg push $@
          ;;
      svn) svn commit $@
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

reb () {
    local def_br=$(dbr)
    local cur_br=$(bra)
    [[ $def_br = $cur_br ]] && red_echo On default branch && return 1
    git fetch origin "$def_br:$def_br" && git rebase "$def_br" &&
        mydialog "push?[n|y|f]" "n green_echo Done" \
        "y git push origin \"$cur_br\"" "f git push origin -f \"$cur_br\""
}

gitlfspur () {
    git lfs ls-files -n | xargs -d '\n' rm
    rvr "${1:-.}"
}

pur () {
  REPO=`what_is_repo_type`
  if [ -z $1 ]; then
      local arg=.
  else
      local arg="$1"
      shift 1
  fi
  local msg="purge $arg $@ ?[n|y]"

  case "$REPO" in
      git) mydialog $msg "n green_echo skipped" "y git clean  -d  -f -x $arg $@"
          # (-d untracked directories, -f untracked files, -x also ignored files)
          gitlfspur .
          ;;
      mercurial) mydialog $msg "n green_echo skipped" "y hg purge $arg $@"
          ;;
      svn) mydialog $msg "n green_echo skipped" "y svn cleanup --remove-unversioned $arg $@"
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# uncommit latest commit
uncom () {
    git reset --soft HEAD~1
}

unstage () {
    if [ "$1" = "" ]; then
        git reset HEAD
    elif [ -f "$1" ]; then
        git reset HEAD "$1"
    else
        red_echo unknown type of argument $1
        return 1
    fi
}

gitmerges () {
    git log $1.."`dbr`" --ancestry-path --merges | less +G
}

rvr () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git reset -- $@ # remove file from staging area
          git checkout -- $@
          #git reset --hard $@
          ;;
      mercurial) hg revert $@
          ;;
      svn) svn revert -R $@
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# undo add file
uad () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git reset -- $@
          ;;
      mercurial) hg revert $@
          ;;
      svn) svn revert -R $@
          ;;
  esac
}

export PREFERRED_REPO_TYPE=git

clo () {
  case "$PREFERRED_REPO_TYPE" in
      git) git clone --recursive $@
          ;;
      mercurial) hg clone $@
          ;;
      svn) svn clone $@
          ;;
  esac
}

# clone specific branch:
# clb <repo> <branch>
clb () {
  local repo=$1
  local branch=$2
  shift 2
  case "$PREFERRED_REPO_TYPE" in
      git) git clone --recursive -b $branch --single-branch $repo $@
          ;;
      mercurial) hg clone $repo -b $branch $@
          ;;
      svn) svn clone $repo/branches/$branch $@
          ;;
  esac
}

check-git-lfs () {
  local file=`roo`/.gitattributes
  [ -f "$file" ] && grep -q filter=lfs "$file"
}

# download & update
pul () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git pull --ff-only --recurse-submodules origin "$(bra)"
          local exit_code=$?
          [ $exit_code -ne 0 ] && return $exit_code
          git submodule update
          if check-git-lfs; then
              mydialog "Pull git lfs? [n|y]" "n green_echo skipped" "y git lfs pull"
          fi
          ;;
      mercurial) hg pull -u $@
          ;;
      svn) svn up $@
          ;;
  esac
}

# get #download remote changes
# get branch #download remote changes from branch
get () {
  REPO=`what_is_repo_type`
  local default=$(dbr)
  case "$REPO" in
      git) 
          if [[ "$1" != "" ]]; then
              local branch="$1"
              echo git fetch --recurse-submodules origin $branch:$branch
              git fetch --recurse-submodules origin $branch:$branch
          else
              local branch="$(bra)"
              echo git fetch --recurse-submodules origin $branch
              git fetch --recurse-submodules origin $branch
              # try fetching also default branch (master)
              if [[ "$branch" != "$default" ]]; then
                  echo git fetch --recurse-submodules origin $default:$default
                  git fetch --recurse-submodules origin $default:$default
              fi
          fi
          ;;
      mercurial) hg pull $@
          ;;
      svn) echo not applicable
          ;;
  esac
}

upd () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git merge --ff-only
          if check-git-lfs; then
              git lfs pull
          fi
          ;;
      mercurial) hg co $@
          ;;
      svn) svn up $@
          ;;
  esac
}

# list branches
lbr () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git)
          git for-each-ref --sort=committerdate refs/heads/ \
              --format='%(committerdate:short): %(refname:short)' | pb
          ;;
      mercurial) red_echo not implemented
          ;;
      svn) red_echo not implemented
          ;;
  esac
}

# checkout specified revision
cou () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git checkout $@
          ;;
      mercurial) hg co $@
          ;;
      svn) svn up $@
          ;;
  esac
}

# switch to default branch
cod () {
  REPO=`what_is_repo_type`
  local default=$(dbr)
  case "$REPO" in
      git)
          echo git checkout "$default"
          git checkout "$default"
          ;;
      mercurial) hg co "$default"
          ;;
      svn) svn up "$default" # TODO
          ;;
      *) red_echo unknown repository: $REPO

  esac
}

# restore master to origin/master
upd_master () {
    git checkout -B master origin/master
}

mov () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git mv $@
          ;;
      mercurial) hg mv $@
          ;;
      svn) svn mv $@
          ;;
  esac
}

# End VCS commands
#############################################################################
