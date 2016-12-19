#!highlights/node_modules/coffee-script/bin/coffee

Highlights = require 'highlights'
fs = require 'fs'
path = require 'path'
highlighter = new Highlights()
highlighter.requireGrammarsSync
  modulePath: require.resolve('./atom-language-perl6/package.json')


stdin = process.openStdin()
stdin.setEncoding 'utf8'

stdin.on 'data', (input) ->
    name = input.trim()
    process.exit() if name == 'exit'
    file_to_hl = path.resolve(name)
    console.error "Highlights is reading #{file_to_hl}"
    foo = ->
      fs.readFileSync file_to_hl, 'utf8'

    html = highlighter.highlightSync
      fileContents: foo()
      scopeName: 'source.perl6fe'

    console.log html
