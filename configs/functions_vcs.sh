##############################################################################
# functions for working with version control repositories & others

# example:
# declare -a MY_REPOS=("path/to/repo1" "path/to/repo2")

lsr () {
    local show_branches=false
    if [[ "$1" == -l ]]; then
        show_branches=true
    fi
    local save_cwd=`command pwd`
    for repo in "${MY_REPOS[@]}"; do
        cd "$repo"
        local dirty=`git diff --quiet -r HEAD || echo \[M\]`
        echo ----------------- $(basename "$repo") "	" `bra -safe` $dirty
        $show_branches && lbr
    done
    cd "$save_cwd"
}

# force-fetch and checkout
gfcou () {
    git fetch origin --force "$1:$1"
    git co "$1"
}

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

app () {
    git apply -3 "$@"
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
          git describe --all; git branch -vv | grep "\\* $branch .*"; git remote -v
          dat "$branch"
          git diff --stat | cat
          ;;
      mercurial) hg id; hg paths
          ;;
      svn) svn info
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

git_log_common () {
    git log --graph --name-status --parents --abbrev-commit --decorate=full "$@"
}

logmy () {
    check_no_args "$@" || return
    git_log_common --author `git config --get user.email` `dbr` | pg
}

log () {
    REPO=`what_is_repo_type`
    case "$REPO" in
        git)
            if [ "$1" = "" ]; then
                git_log_common `bra` `dbr` | pg
            else
                git_log_common $@ | pg
            fi
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
hisb () {
  local default=$(dbr)
  local branch
  local follow=""
  if [ -z "$1" ]; then
      branch=$(bra)
  elif [[ "$1" == "--" ]]; then
      branch=$(bra)
      follow="--follow"
  else
      branch=$1
      shift 1
  fi
  if [[ "$branch" == "$default" ]]; then
      red_echo default branch was provided
  else
      local cmd="git log -p --decorate=full --parents $(git merge-base $branch $default)..$branch $follow $@"
      echo $cmd
      eval $cmd | pgd
  fi
}

# show all changes in the current (or specified in 1st argument) branch
difb () {
  REPO=`what_is_repo_type`
  local default=$(dbr)
  case "$REPO" in
      git)
          local branch
          local follow=""
          if [ -z "$1" ]; then
              branch=$(bra)
          elif [[ "$1" == "--" ]]; then
              branch=$(bra)
              follow="--follow"
          else
              branch=$1
              shift 1
          fi
          if [[ "$branch" == "$default" ]]; then
              red_echo default branch was provided
          else
              local branches="$(git merge-base $branch $default)..$branch"
              local cmd="git diff --patch-with-stat `_rel_prefixes` $branches $follow $@"
              echo "$branches"
              eval $cmd | pgd
              stab "$@"
          fi
          ;;
      mercurial)
          # see https://stackoverflow.com/questions/13991969/mercurial-see-changes-on-the-branch-ignoring-all-the-merge-commits
          hg export -r "branch('$(hg branch)') and not merge()" | pgd
          ;;
      svn) red_echo not implemented
          ;;
      *) red_echo unknown repository: $REPO

  esac
}

# diff patch for branch (on a given list of files)
difbp () {
  local default=$(dbr)
  local branch=$(bra)
  if [[ "$branch" == "$default" ]]; then
      red_echo default branch was provided
  else
      local branches="$(git merge-base $branch $default)..$branch"
      echo git diff --color=never $branches $@
      git diff --color=never $branches $@ | pgd
  fi
}

difbcp () {
  local default=$(dbr)
  local branch=$(bra)
  if [[ "$branch" == "$default" ]]; then
      red_echo default branch was provided
  else
      local commit="$(git merge-base $branch $default)"
      echo git diff --color=never $commit $@
      git diff --color=never $commit $@ | pgd
  fi
}


# show dif-branch including working copy changes
difbc () {
    local branch=$(bra)
    local default=$(dbr)
    local cmd="git diff --patch-with-stat `_rel_prefixes` $(git merge-base $branch $default) $@"
    echo $cmd
    eval $cmd | pgd
    # show helpful list of modified files in the end
    stabc
}

stabc () {
    # Options like --src-prefix don't work
    # git diff --name-status $rel_option $(git merge-base $branch $default) $@ | sed 's/\([A-Z]\+\)./ \1 : /' | pb
    local branch=$(bra)
    local default=$(dbr)
    git diff --name-status $(git merge-base $branch $default) $@ | sed 's/\([A-Z]\+\)./ \1 : /' | pb
}

########################### Vim related ########################
# open all files modified in branch
vbr () {
  REPO=`what_is_repo_type`
  local default=$(dbr)
  case "$REPO" in
      git)
          local branch
          if [ -z "$1" ]; then
              branch=$(bra)
          else
              branch=$1
          fi
          if [[ "$branch" == "$default" ]]; then
              red_echo not showing default branch
          else
              local cmd="git diff --name-only $(git merge-base $branch $default)..$branch"
              echo vr \`$cmd\`
              vr `eval $cmd`
          fi
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# open currently modified files
vac () {
    # using `-r HEAD` includes already staged files
    vr `git diff --name-only -r HEAD` "$@"
}

# like vbr but only for current branch + additional files
vab () {
  local default=$(dbr)
  local branch=$(bra)
  if [[ "$branch" == "$default" ]]; then
      red_echo "default branch"
      return 1
  else
      echo vr $(git diff --name-only $(git merge-base $branch $default)..$branch) "$@"
      vr $(git diff --name-only $(git merge-base $branch $default)..$branch) "$@"
  fi
}

# like vab but including currently modified files
vabc () {
  local default=$(dbr)
  local branch=$(bra)
  if [[ "$branch" == "$default" ]]; then
      red_echo "default branch"
      return 1
  else
      echo vr $(git diff --name-only $(git merge-base $branch $default)) "$@"
      vr $(git diff --name-only $(git merge-base $branch $default)) "$@"
  fi
}

#############################################################################

# show changed files for specified branch
stab () {
  REPO=`what_is_repo_type`
  local default=$(dbr)
  case "$REPO" in
      git) 
          local branch
          local follow=""
          if [ -z "$1" ]; then
              branch=$(bra)
          elif [[ "$1" == "--" ]]; then
              branch=$(bra)
              follow="--follow"
          else
              branch=$1
              shift 1
          fi
          if [[ "$branch" == "$default" ]]; then
              git diff --stat $default $@ | pb
          else
              local cmd="git diff --name-status $(git merge-base $branch $default)..$branch $follow $@ | sed -e 's/	/:\t/g'"
              eval $cmd | pb
          fi
          ;;
      mercurial) red_echo not implemented
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
          local branch
          local follow=""
          if [ -z "$1" ]; then
              branch=$(bra)
          elif [[ "$1" == "--" || -f "$1" ]]; then
              branch=$(bra)
              follow="--follow"
          else
              branch=$1
              shift 1
          fi
          if [[ "$branch" == "$default" ]]; then
              git_log_common $default $follow $@ | pg
          else
              local cmd="git_log_common $(git merge-base $branch $default)..$branch $follow $@"
              echo $cmd
              eval $cmd | pg
          fi
          ;;
      mercurial) hg log -b `hg branch`
          ;;
      svn) svn log --use-merge-history --verbose $@ # TODO: URL required
          ;;
      *) red_echo unknown repository: $REPO

  esac
}

# show stashed change (last by default)
sho () {
    git stash show --patch-with-stat $@ | pg
}

# show all the stashed change
shoa () {
    check_no_args "$@" || return
    git stash list -p --stat | hgrep "stash@{.*" --color=always | pg
}

cdr () {
    cd "`roo`/$1"
}

# Flexible cd: go to directory if it exists, otherwise use VCS-relative `cdr`
cdf () {
    if [ -d "$1" ]; then
        cd "$1"
    else
        cdr "$1"
    fi
}

# squash commits
squ () {
    check_no_args "$@" || return
  local default=$(dbr)
  local branch=$(bra)
  echo git rebase -i $(git merge-base $branch $default)
  git rebase -i $(git merge-base $branch $default)
}

# graph for feature branch
grb () {
  REPO=`what_is_repo_type`
  local default=$(dbr)
  case "$REPO" in
      git) 
          local branch
          local follow=""
          if [ -z "$1" ]; then
              branch=$(bra)
          elif [[ "$1" == "--" ]]; then
              branch=$(bra)
              follow="--follow"
          else
              branch=$1
              shift 1
          fi
          if [[ "$branch" == "$default" ]]; then
              git log --decorate=full --oneline --graph $default $follow $@ | pg
          else
              local cmd="git log --decorate=full --oneline --graph \
                  $(git merge-base $branch $default)..$branch $follow $@"
              echo $cmd
              eval $cmd | pg
          fi
          ;;
      mercurial) hg log $@ | pg
          ;;
      svn) svn log $@ | pg
          ;;
      *) red_echo unknown repository: $REPO
  esac
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
    check_no_args "$@" || return
    git rebase --continue
}

# history of all changes to file(s)
his () {
  if [ -z "$1" ]; then
      red_echo "file name was not provided"
      return 1
  fi
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
      git) local br=`git branch | grep \^\* | cut -d ' ' -f2-`
          if echo $br | grep -q 'HEAD detached'; then
              br=`git branch --contains HEAD | grep -v "HEAD detached" | tail -n1 | trim_spaces`
              if [ "$1" = "-safe" ]; then
                  br="!! $br !!"
              fi
          fi
          echo $br
          ;;
      mercurial) hg branch
          ;;
      svn) svn info | grep '^URL:' | egrep -o '(tags|branches)/[^/]+|trunk' | egrep -o '[^/]+$'
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
      git)
          if [ "$1" = "" ]; then
              # if given without directory, don't show too much non-tracked files:
              git status -s --untracked-files=no $@ | sed 's/\(.\{2\}\)./ \1 : /' | pb
          elif [ -e "$1" ]; then
              # ensure always printing something. If given root directory
              # it will print all the untracked file in the repo
              git status -s --ignored $@ | sed 's/\(.\{2\}\)./ \1 : /' | pb
          else
              red_echo file \"$1\" does not exist
          fi
          ;;
      mercurial) hg status $@ | pb
          ;;
      svn) svn status $@ | pb
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

_rel_prefixes () {
  local rel="`roo_rel`"
  echo --src-prefix="$rel/" --dst-prefix="$rel/"
}

# colored diff
dif () {
  REPO=`what_is_repo_type`
  if [ ! "$1" = "" -a ! -e "$1" ]; then
      red_echo file/dir $1 not found
      return
  fi
  case "$REPO" in
      git)
          # prefixes don't really work at the moment for --stat:
          git diff --patch-with-stat `_rel_prefixes` -r HEAD -- $@|pgd
          sta "$@"
          ;;
      mercurial) hg diff $@|pgd
          ;;
      svn) svn diff $@|pgd
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
          git diff --color=never -r HEAD -- $@|pgd
          ;;
      mercurial) hg diff --color=never $@|pgd
          ;;
      svn) svn diff --color=never $@|pgd
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
      git) git show "$rev:$file" | pgd -X
          ;;
      mercurial) hg cat -r $rev "$file" | pgd -X
          ;;
      svn) svn cat -r $rev "$file" | pgd -X
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
      git)
          local rel="`roo_rel`"
          git show --parents --patch-with-stat `_rel_prefixes` $@ | pgd
          ;;
      mercurial) hg diff -c $@ | pgd
          ;;
      svn) svn diff -c $@ | pgd
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# show files changed in a given revision
pats () {
    git show --stat ${1:-HEAD}
}

# the same but with full files contents (1000 lines of context)
patf () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git show --parents -U1000 $@ | pgd -X
          ;;
      mercurial) hg diff -c $@ | pgd -X
          ;;
      svn) svn diff -c $@ | pgd -X
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

addr () {
  for i in "$@"; do
    git add `roo`/"$i"
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
roo_rel () {
    realpath --relative-to=. $(git rev-parse --show-toplevel)
}

git_check_all_staged () {
    echo Checking presence of unstaged files...
    git diff --quiet
    if [ $? -ne 0 ]; then
        # show only unstaged changes
        git --no-pager diff --name-status
        mydialog "Stage changes?[n|y]" "n green_echo Done" \
            "y git add -u"
    fi
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
      git)
          git_check_all_staged
          eval git commit $msg && \
               mydialog "push?[n|y|f]" "n green_echo Done" \
               "y git push origin \"$(bra)\"" \
               "f git push origin --force-with-lease \"$(bra)\""
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

# git commit --amend
coma () {
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
  git_check_all_staged
  eval git commit --amend $msg && \
      mydialog "push?[n|f]" "n green_echo Done" \
      "f git push origin --force-with-lease \"$(bra)\""
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

pusf () {
    git push origin --force-with-lease "$(bra)" $@
}

rebd () {
    check_no_args "$@" || return
    local def_br=$(dbr)
    local cur_br=$(bra)
    [[ $def_br = $cur_br ]] && red_echo On default branch && return 1
    git fetch origin "$def_br:$def_br" && git rebase "$def_br" && \
        mydialog "push?[n|f]" "n green_echo Done" \
        "f git push origin --force-with-lease \"$cur_br\""
}

gitlfspur () {
    git lfs ls-files -n | xargs -d '\n' rm
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
          # gitlfspur
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
    check_no_args "$@" || return
    git reset --soft HEAD~1
}

unstage () {
    if [ "$1" = "" ]; then
        git reset HEAD
    elif [ -f "$1" ]; then
        git reset HEAD -- "$@"
    else
        red_echo unknown type of argument $1
        return 1
    fi
}

gitmerges () {
    git log $1.."`dbr`" --ancestry-path --merges | less +G
}

rvrr () {
  for i in "$@"; do
    git reset --quiet -- "`roo`/$i" # remove file from staging area
    git checkout -- "`roo`/$i"
  done
}

rvr () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git reset --quiet -- $@ # remove file from staging area
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
      git) git pull --tags --ff-only --recurse-submodules origin "$(bra)"
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

# get default branch
getd () {
    get `dbr`
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
          # not using pager to use in `lsr`
          git for-each-ref --sort=committerdate refs/heads/ \
              --format='%(committerdate:short): %(refname:short)'
          ;;
      mercurial) hg branches --active
          ;;
      svn) svn info | grep '^URL:'
          ;;
  esac
}

# return ancestor of current branch from default branch
anc () {
  local default=$(dbr)
  local branch=$(bra)
  git merge-base $branch $default
}

# restore the version of ancestor (commit from default branch)
coa () {
    git checkout `anc` -- "$@"
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
          git checkout "$default" "$@"
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

grp () {
    git --no-pager grep $@ -- :/
}

# End VCS commands
#############################################################################
