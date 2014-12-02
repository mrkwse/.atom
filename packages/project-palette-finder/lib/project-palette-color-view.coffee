path = require 'path'
{View} = require 'atom'

module.exports =
class ProjectPaletteColorView extends View
  @content: ->
    @div class: 'color inset-panel padded', =>
      @div outlet: 'colorPreview', class: 'color-preview'
      @div class: 'color-details', =>
        @span outlet: 'colorName', class: 'color-name'
        @span outlet: 'colorPath', class: 'color-path'
      @div outlet: 'colorLine', class: 'color-line editor editor-colors', =>

  constructor: (paletteItem) ->
    super

    @colorPreview.css backgroundColor: paletteItem.color.toCSS()
    @colorPreview.setTooltip(paletteItem.name)
    @colorName.text paletteItem.name
    @colorPath.text path.relative(atom.project.getPath(), paletteItem.filePath) + ':' + (paletteItem.row + 1)

    grammar = atom.syntax.selectGrammar("hello.#{paletteItem.extension}", paletteItem.lineText)

    # Highlights = require 'highlights'
    # highlighter = new Highlights(includePath: grammar.path)
    # html = highlighter.highlightSync
    #   fileContents: paletteItem.lineText
    #   scopeName: grammar.scopeName

    @colorLine.empty()
    @colorLine.append(paletteItem.lineText)

    @colorPath.on 'click', ->
      atom.workspaceView.open(paletteItem.filePath, split: 'left').then (editor) ->
        editor.setSelectedBufferRange(paletteItem.getRange(), autoscroll: true)
