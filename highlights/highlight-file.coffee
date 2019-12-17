#!highlights/node_modules/coffee-script/bin/coffee

Highlights = require 'highlights'
fs = require 'fs'
path = require 'path'
highlighter = new Highlights()
highlighter.requireGrammarsSync
  modulePath: require.resolve('./atom-language-raku/package.json')

file_to_hl = path.resolve(process.argv[2])
foo = ->
  fs.readFileSync file_to_hl, 'utf8'

html = highlighter.highlightSync
  fileContents: foo()
  scopeName: 'source.rakufe'

console.log html
