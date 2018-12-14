#!/bin/bash

PIP_USER=${PIP_USER:-1}

if type gem 1>/dev/null 2>&1; then
  gem install asciidoctor mdl
else
  "ruby 'gem' not found"
fi

if type pip 1>/dev/null 2>&1; then
  if [[ $PIP_USER -eq 1 ]]; then
    user="--user"
  else
    user=""
  fi
  pip install ${user} yamllint
  pip install ${user} mkdocs
else
  "python 'pip' not found"
fi
