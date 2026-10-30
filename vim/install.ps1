# ============================================================================
#  vim 설정 설치 스크립트 (Windows / PowerShell)
#
#  사용법 (PowerShell에서 레포의 vim 폴더로 이동 후):
#    powershell -ExecutionPolicy Bypass -File .\install.ps1
#
#  - vim이 없으면 winget으로 설치합니다 (vim.vim).
#  - Windows의 vim은 ~/.vimrc 가 아니라 ~/_vimrc, ~/vimfiles 를 사용합니다.
#  - Git Bash 안의 vim을 쓴다면 이 스크립트 대신 Git Bash에서 ./install.sh 를 쓰세요.
# ============================================================================
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SrcVimrc  = Join-Path $ScriptDir 'vimrc'
$DstVimrc  = Join-Path $HOME '_vimrc'
$VimFiles  = Join-Path $HOME 'vimfiles'
$PlugVim   = Join-Path $VimFiles 'autoload\plug.vim'
$PlugUrl   = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

function Info($m) { Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "[ OK ] $m" -ForegroundColor Green }
function Warn($m) { Write-Host "[WARN] $m" -ForegroundColor Yellow }

if (-not (Test-Path $SrcVimrc)) { throw "vimrc를 찾을 수 없습니다: $SrcVimrc" }

# ---------------------------------------------------------------------------
#  1. git / vim 확인
# ---------------------------------------------------------------------------
function Find-Vim {
    $cmd = Get-Command vim -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    # winget으로 설치한 vim은 PATH에 없을 수 있음 → 기본 설치 경로 탐색
    $found = Get-ChildItem "$env:ProgramFiles\Vim\vim*\vim.exe" -ErrorAction SilentlyContinue |
             Sort-Object FullName -Descending | Select-Object -First 1
    if ($found) { return $found.FullName }
    return $null
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Info 'git 설치 (winget)...'
    winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
    Warn 'git 설치 후 새 PowerShell 창에서 이 스크립트를 다시 실행하세요.'
    exit 1
}

$Vim = Find-Vim
if (-not $Vim) {
    Info 'vim 설치 (winget)...'
    winget install --id vim.vim -e --accept-source-agreements --accept-package-agreements
    $Vim = Find-Vim
    if (-not $Vim) { throw 'vim 설치 경로를 찾지 못했습니다. 새 창에서 다시 실행해보세요.' }
}
Ok "vim: $Vim"

# ---------------------------------------------------------------------------
#  2. 기존 _vimrc 백업 후 복사
# ---------------------------------------------------------------------------
if (Test-Path $DstVimrc) {
    $backup = "$DstVimrc.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item $DstVimrc $backup
    Info "기존 _vimrc 백업 → $backup"
}
Copy-Item $SrcVimrc $DstVimrc
Ok "_vimrc 복사 완료 → $DstVimrc"

# ---------------------------------------------------------------------------
#  3. vim-plug + 플러그인 설치
# ---------------------------------------------------------------------------
if (-not (Test-Path $PlugVim)) {
    Info 'vim-plug 설치 중...'
    New-Item -ItemType Directory -Force -Path (Split-Path $PlugVim) | Out-Null
    Invoke-WebRequest -UseBasicParsing $PlugUrl -OutFile $PlugVim
}
Ok 'vim-plug 준비 완료'

Info '플러그인 설치 중... (1~2분 걸릴 수 있어요)'
& $Vim -E -s -u $DstVimrc -i NONE '+PlugInstall --sync' '+qall'

foreach ($p in 'nerdtree','gruvbox','vim-airline','vim-fugitive','vim-signify') {
    if (-not (Test-Path (Join-Path $VimFiles "plugged\$p"))) { Warn "플러그인 설치 실패: $p" }
}

Write-Host ''
Write-Host '설치 끝! 아이콘이 깨지면 Windows Terminal 글꼴을 Nerd Font(예: MesloLGS NF)로 바꾸세요.'
Write-Host 'Nerd Font를 안 쓸 거면: [Environment]::SetEnvironmentVariable("VIM_NO_NERD_FONT","1","User")'