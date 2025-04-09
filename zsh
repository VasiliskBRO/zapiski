делать всё от рута
apt install zsh git curl
curl -L git.io/antigen > antigen.zsh
nano /root/.zshrc и /home/user/.zshrc

source /path-to-antigen/antigen.zsh

antigen use oh-my-zsh

antigen bundles <<EOBUNDLES
git
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-autosuggestions
history
sudo
EOBUNDLES

antigen theme random

antigen apply
chsh -s $(which zsh)
chsh -s $(which zsh) имя пользователя 
