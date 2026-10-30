# SHELL SETTINGS

```
.
├── vim/
│   ├── vimrc          # Linux / macOS / Windows 공용 설정
│   ├── install.sh     # Linux, macOS 설치 스크립트
│   └── install.ps1    # Windows 설치 스크립트
├── zshrc
└── zsh_setting_start.sh
```

## VIM

### 설치

#### Linux (Raspberry Pi OS, Ubuntu, Debian, Rocky Linux, RHEL, Fedora)

```sh
git clone https://github.com/delusidiot/my_shell_settings.git
cd my_shell_settings/vim
./install.sh            # vimrc 복사 + 플러그인 설치
./install.sh --link     # 복사 대신 심볼릭 링크 (git pull 하면 바로 반영)
```

- vim, git, curl이 없으면 자동으로 설치합니다 (`sudo` 필요, 원치 않으면 `--no-packages`).
- 배포판 기본 vi는 플러그인을 못 쓰는 축소판이라 정식 vim을 설치합니다.

| 배포판 | 기본 vi | 설치되는 패키지 |
|---|---|---|
| Raspberry Pi OS / Debian / Ubuntu | `vim-tiny` | `vim` |
| Rocky / RHEL / AlmaLinux / Fedora | `vim-minimal` | `vim-enhanced` |

#### macOS

```sh
cd my_shell_settings/vim
./install.sh
```

기본 내장 vim으로 동작합니다. 최신 vim을 원하면 먼저 `brew install vim`.

#### Windows

PowerShell에서:

```powershell
cd my_shell_settings\vim
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

- vim이 없으면 `winget`으로 설치합니다.
- Windows용 vim은 `~/.vimrc` 대신 `~\_vimrc`, `~\vimfiles\` 를 사용합니다.
- Git Bash 안의 vim을 쓴다면 Git Bash에서 `./install.sh` 를 실행하세요.

#### 스크립트 없이 (어느 OS든)

`vimrc`를 `~/.vimrc` (Windows는 `~\_vimrc`)로 복사하고 vim을 실행하면,
vim-plug와 플러그인이 **첫 실행 때 자동으로 설치**됩니다 (curl 필요).

### Nerd Font

airline 화살표와 devicons 아이콘은 Nerd Font가 있어야 깨지지 않습니다.
SSH로 접속할 때는 **접속하는 쪽 터미널**(예: Windows Terminal)에 폰트가 있어야 합니다.

- 폰트: [MesloLGS NF](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k)
- [Windows Terminal 글꼴 바꾸기](https://www.thewindowsclub.com/change-font-size-for-a-windows-terminal)

폰트 없이 쓸 기계라면 아이콘을 끄세요.

```sh
echo 'export VIM_NO_NERD_FONT=1' >> ~/.zshrc   # bash라면 ~/.bashrc
```

### 단축키

`<leader>` 는 스페이스바입니다.

| 키 | 동작 |
|---|---|
| `F9` | NERDTree 열기/닫기 |
| `<leader>n` | NERDTree에서 현재 파일 위치 찾기 |
| `<C-b>` + `h/j/k/l` | 창 이동 (`<C-w>` 대신) |
| `<leader>]` / `<leader>[` | 다음 / 이전 버퍼 |
| `<leader>q` | 현재 버퍼 닫기 |
| `<leader>h` | 검색 하이라이트 끄기 |
| `<leader>r` | 상대 줄 번호 켜기/끄기 |

### 파일 타입별 들여쓰기

| 파일 | 들여쓰기 |
|---|---|
| 기본, Rust, Python, Java | 공백 4칸 |
| YAML, JSON, HTML/CSS, JS/TS, Vue, Terraform | 공백 2칸 |
| C, C++ | 탭 (42 norminette 스타일) |
| Makefile, Go | 탭 |

### 기계별 개인 설정

이 레포의 vimrc를 고치지 않고 `~/.vimrc.local` (Windows: `~\_vimrc.local`)에
추가 설정을 넣으면 마지막에 읽힙니다.

### 플러그인

- [vim-plug](https://github.com/junegunn/vim-plug) - 플러그인 매니저 (`:PlugUpdate` 로 업데이트)
- [nerdtree](https://github.com/preservim/nerdtree) + [nerdtree-git-plugin](https://github.com/Xuyuanp/nerdtree-git-plugin)
- [gruvbox](https://github.com/morhetz/gruvbox)
- [vim-airline](https://github.com/vim-airline/vim-airline) + [vim-airline-themes](https://github.com/vim-airline/vim-airline-themes)
- [vim-fugitive](https://github.com/tpope/vim-fugitive) - `:Git` 명령
- [vim-signify](https://github.com/mhinz/vim-signify) - 변경된 줄 표시
- [vim-devicons](https://github.com/ryanoasis/vim-devicons) - 파일 아이콘 (Nerd Font 필요)

## ZSH

- [ohmyzsh](https://ohmyz.sh/)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [powerlevel10k](https://github.com/romkatv/powerlevel10k)