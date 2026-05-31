#
# Ruby / Bundler aliases (from prezto's ruby module).
#
# Prezto's original init.zsh also bootstraps rbenv/rvm/chruby; that's omitted
# here because runtime versions are managed by asdf (see ~/.tool-versions).
# Only the aliases are kept, verbatim.
#

# General
alias rb='ruby'

# Bundler
if (( $+commands[bundle] )); then
  alias rbb='bundle'
  alias rbbc='bundle clean'
  alias rbbe='bundle exec'
  alias rbbi='bundle install --path vendor/bundle'
  alias rbbl='bundle list'
  alias rbbo='bundle open'
  alias rbbp='bundle package'
  alias rbbu='bundle update'
  alias rbbI='rbbi \
    && bundle package \
    && print .bundle       >>! .gitignore \
    && print vendor/assets >>! .gitignore \
    && print vendor/bundle >>! .gitignore \
    && print vendor/cache  >>! .gitignore'
fi
