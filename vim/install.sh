#!/usr/bin/env bash
# ============================================================================
#  vim 설정 설치 스크립트 (Linux / macOS)
#
#  지원: Debian / Ubuntu / Raspberry Pi OS (apt)
#        Rocky / RHEL / AlmaLinux / Fedora (dnf, yum)
#        macOS (Homebrew)
#  Windows는 install.ps1 을 사용하세요.
#
#  사용법:
#    ./install.sh               vimrc 복사 + 플러그인 설치
#    ./install.sh --link        복사 대신 심볼릭 링크 (git pull 하면 바로 반영)
#    ./install.sh --no-packages sudo로 패키지(vim/git/curl) 설치하지 않기
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_VIMRC="$SCRIPT_DIR/vimrc"
DST_VIMRC="$HOME/.vimrc"
PLUG_VIM="$HOME/.vim/autoload/plug.vim"
PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

USE_LINK=0
INSTALL_PACKAGES=1

info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m[ OK ]\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$*" >&2; }
die()   { printf '\033[1;31m[FAIL]\033[0m %s\n' "$*" >&2; exit 1; }

usage() { sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

for arg in "$@"; do
  case "$arg" in
    --link)        USE_LINK=1 ;;
    --no-packages) INSTALL_PACKAGES=0 ;;
    -h|--help)     usage ;;
    *)             die "알 수 없는 옵션: $arg  (--help 참고)" ;;
  esac
done

[ -f "$SRC_VIMRC" ] || die "vimrc를 찾을 수 없습니다: $SRC_VIMRC"

# ---------------------------------------------------------------------------
#  1. OS / 패키지 매니저 판별
# ---------------------------------------------------------------------------
OS="$(uname -s)"
PKG=""
case "$OS" in
  Linux)
    if   command -v apt-get >/dev/null 2>&1; then PKG=apt
    elif command -v dnf     >/dev/null 2>&1; then PKG=dnf
    elif command -v yum     >/dev/null 2>&1; then PKG=yum
    fi
    ;;
  Darwin)
    command -v brew >/dev/null 2>&1 && PKG=brew
    ;;
  *)
    die "지원하지 않는 OS입니다: $OS (Windows는 install.ps1 사용)"
    ;;
esac
info "OS: $OS / 패키지 매니저: ${PKG:-없음} / 아키텍처: $(uname -m)"

SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

# 배포판마다 다른 패키지 이름
#   - Debian 계열: 기본 vi는 기능이 빠진 vim-tiny → 'vim' 패키지 필요
#   - RHEL 계열 : 기본 vi는 vim-minimal       → 'vim-enhanced' 필요
pkg_name() {
  case "$1:$PKG" in
    vim:dnf|vim:yum) echo vim-enhanced ;;
    *)               echo "$1" ;;
  esac
}

install_pkgs() {
  [ "$#" -eq 0 ] && return 0
  if [ "$INSTALL_PACKAGES" -eq 0 ] || [ -z "$PKG" ]; then
    die "다음 패키지를 먼저 설치하세요: $*"
  fi
  info "패키지 설치: $*"
  case "$PKG" in
    apt)  $SUDO apt-get update -qq && $SUDO apt-get install -y "$@" ;;
    dnf)  $SUDO dnf install -y "$@" ;;
    yum)  $SUDO yum install -y "$@" ;;
    brew) brew install "$@" ;;
  esac
}

# ---------------------------------------------------------------------------
#  2. 필요한 프로그램 확인 (vim, git, curl)
# ---------------------------------------------------------------------------
need=()
command -v git  >/dev/null 2>&1 || need+=("$(pkg_name git)")
command -v curl >/dev/null 2>&1 || need+=("$(pkg_name curl)")

# vim이 없거나, vim-tiny/vim-minimal처럼 스크립트(+eval)를 못 돌리는 버전이면 설치
if ! command -v vim >/dev/null 2>&1 || ! vim --version 2>/dev/null | grep -q '+eval'; then
  need+=("$(pkg_name vim)")
fi
if [ "${#need[@]}" -gt 0 ]; then
  install_pkgs "${need[@]}"
fi

vim --version | grep -q '+eval' || die "플러그인을 지원하는 vim(+eval)이 필요합니다."
ok "$(vim --version | head -1)"

# ---------------------------------------------------------------------------
#  3. 기존 ~/.vimrc 백업 후 설치
# ---------------------------------------------------------------------------
if [ -e "$DST_VIMRC" ] || [ -L "$DST_VIMRC" ]; then
  if [ -L "$DST_VIMRC" ] && [ "$(readlink "$DST_VIMRC")" = "$SRC_VIMRC" ]; then
    info "~/.vimrc 가 이미 이 레포를 가리키고 있습니다."
  else
    backup="$DST_VIMRC.bak.$(date +%Y%m%d-%H%M%S)"
    mv "$DST_VIMRC" "$backup"
    info "기존 ~/.vimrc 백업 → $backup"
  fi
fi

if [ "$USE_LINK" -eq 1 ]; then
  ln -sfn "$SRC_VIMRC" "$DST_VIMRC"
  ok "~/.vimrc → $SRC_VIMRC (심볼릭 링크)"
else
  cp "$SRC_VIMRC" "$DST_VIMRC"
  ok "~/.vimrc 복사 완료"
fi

# ---------------------------------------------------------------------------
#  4. vim-plug + 플러그인 설치
# ---------------------------------------------------------------------------
if [ ! -f "$PLUG_VIM" ]; then
  info "vim-plug 설치 중..."
  curl -fsSLo "$PLUG_VIM" --create-dirs "$PLUG_URL" || die "vim-plug 다운로드 실패"
fi
ok "vim-plug 준비 완료"

info "플러그인 설치 중... (처음엔 1~2분 걸릴 수 있어요)"
# -E -s : 화면 없이 실행 (스크립트/SSH에서도 멈추지 않음)
vim -E -s -u "$DST_VIMRC" -i NONE +'PlugInstall --sync' +qall </dev/null || true

missing=0
for p in nerdtree gruvbox vim-airline vim-fugitive vim-signify; do
  [ -d "$HOME/.vim/plugged/$p" ] || { warn "플러그인 설치 실패: $p"; missing=1; }
done
[ "$missing" -eq 0 ] && ok "플러그인 설치 완료" \
  || warn "vim을 열고 :PlugInstall 을 다시 실행해보세요."

cat <<'EOF'

----------------------------------------------------------------
 설치 끝! 확인할 것
  - 아이콘/화살표가 깨지면: 접속하는 쪽(Windows Terminal 등)에
    Nerd Font를 설치하거나, ~/.bashrc 또는 ~/.zshrc 에
      export VIM_NO_NERD_FONT=1
    을 추가하세요.
  - 플러그인 업데이트: vim 안에서 :PlugUpdate
----------------------------------------------------------------
EOF