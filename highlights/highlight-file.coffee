#!highlights/node_modules/coffee-script/bin/coffee

Highlights = require 'highlights'
fs = require 'fs'
path = require 'path'
highlighter = new Highlights()
modPath = require.resolve('./atom-language-perl6/package.json')
highlighter.requireGrammarsSync
  modulePath: modPath

rakuGrammarPath = path.join(path.dirname(modPath), 'grammars', 'raku.cson')
if fs.existsSync(rakuGrammarPath)
    rakuScopeName = 'source.raku'
else
    rakuScopeName = 'source.perl6fe'

file_to_hl = path.resolve(process.argv[2])
foo = ->
  fs.readFileSync file_to_hl, 'utf8'

html = highlighter.highlightSync
  fileContents: foo()
  scopeName: rakuScopeName

console.log html
