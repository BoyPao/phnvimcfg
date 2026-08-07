# phnvimcfg
This is a nvim configuration git.

## Install
After neovim installed, you can install this configuration file by following below cmd
```bash
cd ~
mkdir -p .config/nvim
mkdir -p .local/share
cd .local/share
git clone https://github.com/BoyPao/phnvimcfg.git
cd ~/.config/nvim
rm init.lua coc-settings.json
ls -s ~/.local/share/phnvimcfg/init.lua
ls -s ~/.local/share/phnvimcfg/coc-settings.json
nvim ./
```

## Requirement
### neovim
nvim-0.10.4 or later is required. I suggest to use latest version.

#### Dependency
Update dependencies. (needs sudo)
```bash
sudo apt-get install ninja-build gettext cmake curl build-essential git
```

#### Install
```bash
git clone https://github.com/neovim/neovim.git
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=Release
sudo make install

or

make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/xxx/xxx/xx/xx
make install
```

### Node
Node.js v20.19.0 or later is required. I suggest to use latest version.

#### Install
Install nvm, it is node manager.
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

Set nvm path: add below code into your .bashrc
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```

Then source .bashrc and install Node
```bash
source ~/.bashrc
nvm install --lts
```

nvm usefull method
```bash
nvm ls                  #list node version installed
nvm use 18              #switch node version
nvm alias default 18    #set default node version
```

### Tree-sitter
Tree-sitter 0.26.1 or later is required.
Tree-sitter needs cargo tool.
Install cargo
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#Follow the script to install. If you can edit .profile, just use default setting. If you cannot, use customer build and set PATH by your self
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### Install Tree-sitter
```bash
cargo install tree-sitter-cli
#if dependencies error report, try
cargo install tree-sitter-cli --no-default-features
```

#### Install Tree-sitter in nvim
```vim
:TSInstall markdown markdown_inline yaml lua
```

# Icon (Nerd Font)
nvim-web-devicons is used for icon shown. If some icon show as unknow symbol, then we need to install a front from nerd-fonts.

## When useing termianl tool on Windows access Linux
For using use mobaxterm from wondows, need to insatll front in Windows, then set mobaxterm use this front
```bat
download JetBrainsMono.zip from https://github.com/ryanoasis/nerd-fonts/releases/tag/v3.4.0
unzip JetBrainsMono.zip
move all *ttf/*otf to C:\Windows\Fonts
```

## Linux
For linux, install JetBrainsMono dirrectlly
```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
tar -xf JetBrainsMono.tar.xz
```
Set terminal to use this front

# LSP
## Language server
clangd is used as language server. clangd-11(support syntax highlight) or later is required.
Install it from apt, or download releated package install manually.

## bear
If you use purely make to compile code, you can use bear to generate LSP db.
bear 3.0.18 or later is required. I suggest to use latest version.
Download src first
```bash
git clone https://github.com/rizsotto/Bear.git
```

## Cmake
If your project use Cmake, use Cmake to generate LSP db.

# AI
Set your AI config in .bashrc and source .bashrc
## OpenAI
```bash
export OPENAI_URL='xxxxxxxxxxxxxxxxxxxx/v1/chat/completions'
export OPENAI_API_KEY='your api key'
export OPENAI_MODEL_CHAT='your llm'
```

## Claude CLI
Install claude CLI and set claude cli bin path into .bashrc
```bash
# Note: please remove '/v1/chat/completions' in URL setting
export ANTHROPIC_BASE_URL="xxxxxxxxxxxxxxxxxxxxllm"
export ANTHROPIC_AUTH_TOKEN="your api key"
export ANTHROPIC_MODEL="your llm"
```

