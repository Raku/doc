Highlights = require 'highlights'
fs = require 'fs'
path = require 'path'
highlighter = new Highlights()
modPath = require.resolve('./atom-language-perl6/package.json')
highlighter.requireGrammarsSync
  modulePath: modPath)

rakuGrammarPath = path.join(path.dirname(modPath), 'grammars', 'raku.cson')
if fs.existsSync(rakuGrammarPath)
    rakuScopeName = 'source.raku'
else
    rakuScopeName = 'source.perl6fe'

TestFolder = path.resolve('TestFolder')
files = fs.readdirSync(TestFolder)

for file in files
  foo = ->
    fs.readFileSync path.resolve(TestFolder, file), 'utf8'
  html = highlighter.highlightSync
    fileContents: foo()
    scopeName: rakuScopeName

  console.log html
