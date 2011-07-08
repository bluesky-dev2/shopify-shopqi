App.Views.Theme.Settings.Index = Backbone.View.extend
  el: '#main'

  events:
    "submit form": 'save'

  initialize: ->
    self = this
    this.render()

  render: ->
    template = Handlebars.compile $('#section-header-item').html()
    $('fieldset').each ->
      title = $('legend', this).text()
      $(this).hide().before template title: title
    $('.section-header').addClass('collapsed').click ->
      $(this).toggleClass 'collapsed'
      $(this).next().toggle()
    $('.section-header:first').click()
    $('.color').miniColors()

  save: ->
    attrs = _.reduce $('form').serializeArray(), (result, obj) ->
      result[obj.name] = obj.value
      result
    , {_method: 'put'}
    $.post "/admin/themes/settings", attrs, (data) ->
