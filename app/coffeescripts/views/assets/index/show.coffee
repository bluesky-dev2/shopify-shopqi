App.Views.Asset.Index.Show = Backbone.View.extend
  tagName: 'li'
  className: 'file'

  events:
    "click a": 'show'

  initialize: ->
    _.bindAll this, 'change'
    self = this
    this.render()

  render: ->
    template = Handlebars.compile $("#theme-item").html()
    attrs = @model.attributes
    attrs['type'] = @model.extension()
    $(@el).html template attrs
    $("#theme-#{@options.name}").append @el

  show: ->
    self = this
    $('#theme-editor-sidebar-top .current-file').removeClass('current-file')
    $(@el).addClass('current-file')
    $('#asset-title').text(@model.get('name'))
    $('#asset-buttons, #asset-info, #asset-title').show()
    $('#asset-links').css('visibility', 'visible')
    $('#asset-hint, #asset-hint-liquid').toggle(this.is_liquid_asset())
    $('#asset-rollback-form, #asset-link-rename, #asset-rename-form, #asset-link-destroy, #asset-hint-noselect').hide()
    if this.is_text_asset() # 文本
      $('#template-editor').show()
      $("#preview-image").hide()
      unless TemplateEditor.editor?
        editor = ace.edit("template-editor")
        editor.setTheme 'ace/theme/clouds'
        TemplateEditor.editor = editor
      if @session
        TemplateEditor.editor.setSession @session
      else
        $.get "/admin/themes/asset/#{@model.get('id')}", (data) ->
          editor = TemplateEditor.editor
          session = new TemplateEditor.EditSession('')
          editor.setSession session
          self.session = session
          extension = self.model.extension()
          mode = if extension in ['css', 'js'] then "#{extension}_mode" else 'html_mode'
          session.setUndoManager new TemplateEditor.UndoManager()
          session.setMode new TemplateEditor[mode]
          session.setValue data
          session.setUseSoftTabs true
          session.on 'change', self.change
          editor.moveCursorTo(0,0)
    else # 图片
      $('#template-editor').hide()
      if this.is_image_asset()
        $("#preview-image").show()
        url = @model.get('url')
        $("#preview-image-asset").attr 'src', url
        $("#preview-image-asset").parent('a').attr('href', url) if url?
    false

  is_text_asset: ->
    @model.extension() in TemplateEditor.text_extensions

  is_image_asset: ->
    @model.extension() in TemplateEditor.image_extensions

  is_liquid_asset: ->
    ends = '.liquid'
    str = @model.get('name')
    str.substring(str.length - ends.length) is ends

  change: ->
    log 'ca'
    self = this
    setTimeout ->
      session = TemplateEditor.editor.getSession()
      $(self.el).toggleClass 'modified', !_.isEmpty(session.$undoManager.$undoStack)
    , 0
