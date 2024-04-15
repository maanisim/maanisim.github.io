wget -O bat.zip https://github.com/sharkdp/bat/releases/download/v0.8.0/bat-v0.8.0-x86_64-unknown-linux-musl.tar.gz
tar -xvzf bat.zip -C /usr/local
mv /usr/local/bat-v0.8.0-x86_64-unknown-linux-musl /usr/local/bat
alias bat='/usr/local/bat/bat'
