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
process_file = (full_path) ->
  fs.readFile full_path, 'utf8', (read_err, file_str) ->
    if read_err
      console.error read_err
    else
      highlighter.highlight (fileContents: file_str, scopeName: 'source.perl6fe'), (hl_err, html) ->
        if hl_err
          console.error hl_err
        else
          mystdout.write(html + '\n')


stdin.on 'data', (input) ->
    process_file path.resolve input.trim()
