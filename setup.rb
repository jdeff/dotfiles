#!/usr/bin/env ruby -w

require 'pathname'

ROOT = Pathname.new(__FILE__).dirname.expand_path
HOME = Pathname.new(Dir.home)

files = (ROOT + 'dotfiles').children

files.each do |file|
  dotfile = HOME + ".#{file.basename}"
  puts "Linking #{dotfile.basename}"
  dotfile.unlink if dotfile.exist? || dotfile.symlink?
  dotfile.make_symlink(file)
end

oh_my_zsh = HOME + '.oh-my-zsh'
if oh_my_zsh.exist?
  puts 'Updating oh-my-zsh!'
  Dir.chdir(oh_my_zsh)
  `git pull --rebase origin master`
else
  puts 'Cloning oh-my-zsh!'
  `git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh`
end
