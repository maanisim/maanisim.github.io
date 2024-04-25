sudo yum install python-pygments -y
alias ccat="pygmentize -g"
sudo yum install htop -y
pip install thefuck
eval $(thefuck --alias)
function manf () { man $1 | less -p "^ +$2"; }
