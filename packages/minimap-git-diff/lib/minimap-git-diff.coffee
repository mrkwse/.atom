{CompositeDisposable, Disposable} = require 'event-kit'
{requirePackages} = require 'atom-utils'

MinimapGitDiffBinding = null

class MinimapGitDiff

  bindings: {}
  pluginActive: false
  constructor: ->
    @subscriptions = new CompositeDisposable

  isActive: -> @pluginActive
  activate: (state) ->
    requirePackages('minimap', 'git-diff').then ([@minimap, @gitDiff]) =>
      return @deactivate() unless @minimap.versionMatch('>= 3.5.0')
      @minimap.registerPlugin 'git-diff', this

  deactivate: ->
    binding.destroy() for id,binding of @bindings
    @bindings = {}
    @gitDiff = null
    @minimap = null

  activatePlugin: ->
    return if @pluginActive

    try
      @activateBinding()
      @pluginActive = true

      @subscriptions.add @minimap.onDidActivate @activateBinding
      @subscriptions.add @minimap.onDidDeactivate @destroyBindings
    catch e
      console.log e

  deactivatePlugin: ->
    return unless @pluginActive

    @pluginActive = false
    @subscriptions.dispose()
    @destroyBindings()

  activateBinding: =>
    @createBindings() if atom.project.getRepositories().length > 0

    @subscriptions.add atom.project.onDidChangePaths =>
      if atom.project.getRepositories().length > 0
        @createBindings()
      else
        @destroyBindings()

  createBindings: =>
    MinimapGitDiffBinding ||= require './minimap-git-diff-binding'

    @subscriptions.add @minimap.observeMinimaps (o) =>
      minimap = o.view ? o
      editor = minimap.getTextEditor()

      return unless editor?

      id = editor.id
      binding = new MinimapGitDiffBinding @gitDiff, minimap
      @bindings[id] = binding

  destroyBindings: =>
    binding.destroy() for id,binding of @bindings
    @bindings = {}

  asDisposable: (subscription) -> new Disposable -> subscription.off()

module.exports = new MinimapGitDiff
