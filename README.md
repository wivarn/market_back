# Setup steps

## Github

Generate key: https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
Add key: https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
Alternatly copy key from another (old) machine

```
ssh-keygen -t ed25519 -C EMAIL@skwirl.io
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh -T git@github.com
# add your key
# mkdir and cd
git clone git@github.com:skwirl-io/market_back.git
```

## rbenv

https://github.com/rbenv/ruby-build#installation

```
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
~/.rbenv/bin/rbenv init
# reset bash session
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-doctor | bash
# if rbenv install isn't availible
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```

## postgresql

```
# if on EC2 instance
sudo amazon-linux-extras install postgresql10
yum install -y postgresql10 postgresql-devel
# may need more if running PSQL server locally
```

## bundle

```
gem install bundler
bundle
bundle exec jets c # or s
```
