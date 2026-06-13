# Requirement
## neovim
nvim-0.10.4 or later is required. I suggest to use latest version.

### Dependency
Update dependencies. (needs sudo)
```bash
sudo apt-get install ninja-build gettext cmake curl build-essential git
```

### Install
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

## Node
Node.js v20.19.0 or later is required. I suggest to use latest version.

### Install
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

## Tree-sitter
Tree-sitter 0.26.1 or later is required.
Tree-sitter needs cargo tool.
Install cargo
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#Follow the script to install. If you can edit .profile, just use default setting. If you cannot, use customer build and set PATH by your self
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Install Tree-sitter
```bash
cargo install tree-sitter-cli
#if dependencies error report, try
cargo install tree-sitter-cli --no-default-features
```

Install Tree-sitter in nvim
```vim
:TSInstall markdown markdown_inline yaml lua
```

# Icon (Nerd Font)
nvim-web-devicons is used for icon shown, we need to install a front from nerd-fonts, if not some icon pared as unknow symbol.

## When useing termianl tool on Windows access Linux
I use mobaxterm, I need to insatll front in Windows, then set mobaxterm use this front
```bat
download JetBrainsMono.zip from https://github.com/ryanoasis/nerd-fonts/releases/tag/v3.4.0
unzip JetBrainsMono.zip
move all *ttf/*otf to C:\Windows\Fonts
```

## Linux
Here I install JetBrainsMono
```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
tar -xf JetBrainsMono.tar.xz
```

Set terminal to use this front

# LSP
## bear
If you use purely make to compile code, you can use bear to generate LSP db.
bear 3.0.18 or later is required. I suggest to use latest version.
Download src first
```bash
git clone https://github.com/rizsotto/Bear.git
```

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
export CLAUDE_CLI_CMD='your bin'
```

Set claude setting in ~/.claude/settings.json. Note: please remove '/v1/chat/completions' in URL setting
```
{
  "env": {
    "ANTHROPIC_BASE_URL": "xxxxxxxxxxxxxx",
    "ANTHROPIC_AUTH_TOKEN": "your key",
    "ANTHROPIC_MODEL": "your llm"
  },
  "theme": "dark"
}
```

