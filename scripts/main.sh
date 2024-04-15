# bat - syntax highlight
# https://github.com/sharkdp/bat
wget -O bat.zip https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-x86_64-unknown-linux-musl.tar.gz
tar -xvzf bat.zip -C /usr/local
mv /usr/local/bat-v0.24.0-x86_64-unknown-linux-musl /usr/local/bat
alias bat='/usr/local/bat/bat'
# manf - man flag
# Example usage "manf grep -s"
function manf () { man $1 | less -p "^ +$2"; }
