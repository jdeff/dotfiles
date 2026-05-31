#
# Ruby on Rails aliases (from prezto's rails module), verbatim.
#
# `rorl` uses the vendored ruby-app-root helper (see ../functions/).
# Requires bundler; the module no-ops if `bundle` isn't installed.
#

if (( ! $+commands[bundle] )); then
  return 0
fi

alias ror='bundle exec rails'
alias rorc='bundle exec rails console'
alias rordc='bundle exec rails dbconsole'
alias rordm='bundle exec rake db:migrate'
alias rordM='bundle exec rake db:migrate db:test:clone'
alias rordr='bundle exec rake db:rollback'
alias rorg='bundle exec rails generate'
alias rorl='tail -f "$(ruby-app-root)/log/development.log"'
alias rorlc='bundle exec rake log:clear'
alias rorp='bundle exec rails plugin'
alias rorr='bundle exec rails runner'
alias rors='bundle exec rails server'
alias rorsd='bundle exec rails server --debugger'
alias rorx='bundle exec rails destroy'
