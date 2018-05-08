Highlights = require 'highlights'
fs = require 'fs'
path = require 'path'
highlighter = new Highlights()
highlighter.requireGrammarsSync
  modulePath: require.resolve('./atom-language-perl6/package.json')

TestFolder = path.resolve('TestFolder')
files = fs.readdirSync(TestFolder)

for file in files
  foo = ->
    fs.readFileSync path.resolve(TestFolder, file), 'utf8'
  html = highlighter.highlightSync
    fileContents: foo()
    scopeName: 'source.perl6fe'

  console.log html
