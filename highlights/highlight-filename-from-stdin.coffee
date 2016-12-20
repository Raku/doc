#!highlights/node_modules/coffee-script/bin/coffee

Highlights = require 'highlights'
fs = require 'fs'
path = require 'path'
highlighter = new Highlights()
highlighter.requireGrammarsSync
  modulePath: require.resolve('./atom-language-perl6/package.json')

stdin = process.openStdin()
stdin.setEncoding 'utf8'
mystderr = process.stderr
mystdout = process.stdout
foo = (full_path) ->
  fs.readFile full_path, 'utf8', (err, file_str) ->
    if err
      console.error err
    else
      mystdout.write highlighter.highlightSync(
        fileContents: file_str
        scopeName: 'source.perl6fe'
      ) + '\n'

stdin.on 'data', (input) ->
    foo path.resolve input.trim()
