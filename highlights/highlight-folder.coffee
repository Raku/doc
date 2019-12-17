Highlights = require 'highlights'
fs = require 'fs'
path = require 'path'
highlighter = new Highlights()
highlighter.requireGrammarsSync
  modulePath: require.resolve('./atom-language-raku/package.json')

TestFolder = path.resolve('TestFolder')
files = fs.readdirSync(TestFolder)

for file in files
  foo = ->
    fs.readFileSync path.resolve(TestFolder, file), 'utf8'
  html = highlighter.highlightSync
    fileContents: foo()
    scopeName: 'source.rakufe'

  console.log html
