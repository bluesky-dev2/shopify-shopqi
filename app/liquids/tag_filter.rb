# encoding: utf-8
module TagFilter

  def stylesheet_tag(input)
    "<link href='#{input}' rel='stylesheet' type='text/css' media='all' />"
  end

  def script_tag(input)
    "<script src='#{input}' type='text/javascript'></script>"
  end

  def img_tag(input, alt = nil)
    "<img src='#{input}' alt='#{alt}' />"
  end

  def link_to(input, url)
    "<a href='#{url}'>#{input}</a>"
  end

  def link_to_type(input)
    "<a title=#{input} href='/collections/types?q=#{input}'>#{input}</a>"
  end

  def link_to_vendor(input)
    "<a title=#{input} href='/collections/vendors?q=#{input}'>#{input}</a>"
  end

  def default_errors(errors) # 错误提示(暂不支持顾客登录失败提示)
    text = ''
    if errors and !errors.empty?
      text += '<div class="errors"><ul>'
      errors.each do |attribute, errors_array|
        text += "<li> #{attribute}#{errors_array} </li>"
      end
      text += "</ul></div>"
    end
    text
  end

end
