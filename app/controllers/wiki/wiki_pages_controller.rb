#encoding: utf-8
class Wiki::WikiPagesController < Wiki::AppController
  layout 'wiki'
  expose(:wiki){ WikiPage.wiki }

  def index
    @page = wiki.page('home')
    if @page
      render text: @page.formatted_data, layout: true
    else
      render text: "请创建<a href='/home'>wiki首页</a>", layout: true
    end
  end

  def create
    begin
      WikiPage.create params[:name],params[:format], params[:content],commit_message
      redirect_to "/#{CGI.escape(params[:name])}"
    rescue Gollum::DuplicatePageError => e
      @message = "页面重名了: #{e.message}"
      render text: @message, layout: true
    end
  end

  def show
    name = params[:name]
    sha = params[:sha]
    show_page_or_file(name,sha)
  end

  def edit
    @name = params[:name]
    if page = wiki.page(@name)
      @format = page.format
      @content = page.raw_data
    else
      render text: '没有找到对应的页面',layout: true
    end
  end

  def compare
    @versions = params[:versions] || []
    if @versions.size < 2
      redirect_to "/history/#{CGI.escape(params[:name])}"
    else
      redirect_to "/compare/%s/%s/%s" % [ CGI.escape(params[:name]), @versions.last, @versions.first]
    end

  end

  def compare_versions
    @name     = params[:name]
    @page     = wiki.page(@name)
    diffs     = wiki.repo.diff(params[:sha1], params[:sha2], @page.path)
    @diff     = diffs.first
    @lines = []
    @diff.diff.split("\n")[2..-1].each_with_index do |line, line_index|
      @lines << { :line  => line,
                 :class => line_class(line),
                 :ldln  => left_diff_line_number(0, line),
                 :rdln  => right_diff_line_number(0, line) }
    end if @diff
    render action: 'compare'
  end

  def preview
    @name = "Preview"
    @page = wiki.preview_page(@name, params[:content], params[:format])
    @content  = @page.formatted_data
    render :show
  end

  def update
    name   = params[:name]
    page   = wiki.page(name)
    format = params[:format] || :textile
    wiki.update_page(page, name, format.intern, params[:content], commit_message)
    redirect_to "/#{Gollum::Page.cname name}"
  end

  def destroy
    page   = wiki.page(params[:name])
    wiki.delete_page(page, commit_message)
    redirect_to '/'
  end

  def pages
    @results = wiki.pages
  end

  def search
    @results = wiki.search params[:q]
  end

  def history
    @name     = params[:name]
    @page     = wiki.page(@name)
    @page_num = [params[:page].to_i, 1].max
    @versions = @page.versions :page => @page_num
    i = @versions.size + 1
    @versions = @versions.map do |v|
      i -= 1
      { :id       => v.id,
        :id7      => v.id[0..6],
        :num      => i,
        :selected => @page.version.id == v.id,
        :author   => v.author.name,
        :message  => v.message,
        :date     => v.committed_date.strftime("%B %d, %Y"),
        :gravatar => Digest::MD5.hexdigest(v.author.email) }
    end
  end

  protected
  def show_page_or_file(name,sha)
    if sha
      if page = wiki.page(name,sha)
        @page = page
        @name = name
        @content = page.formatted_data
        render :show
      else
        render text: '未找到该页面',layout: true
      end
    else
      if page = wiki.page(name)
        @page = page
        @name = name
        @content = page.formatted_data
        render :show
      else
        @name = params[:name]
        render :new
      end
    end
  end

  private

  def commit_message
    { :message => params[:message] , :name => "liwh" , :email => "liwh87@gmail.com"}
  end

  def line_class(line)
    if line =~ /^@@/
      'gc'
    elsif line =~ /^\+/
      'gi'
    elsif line =~ /^\-/
      'gd'
    else
      ''
    end
  end

  def left_diff_line_number(id, line)
    if line =~ /^@@/
      m, li = *line.match(/\-(\d+)/)
      @left_diff_line_number = li.to_i
      @current_line_number = @left_diff_line_number
      ret = '...'
    elsif line[0] == ?-
      ret = @left_diff_line_number.to_s
      @left_diff_line_number += 1
      @current_line_number = @left_diff_line_number - 1
    elsif line[0] == ?+
      ret = ' '
    else
      ret = @left_diff_line_number.to_s
      @left_diff_line_number += 1
      @current_line_number = @left_diff_line_number - 1
    end
    ret
  end

  def right_diff_line_number(id, line)
    if line =~ /^@@/
      m, ri = *line.match(/\+(\d+)/)
      @right_diff_line_number = ri.to_i
      @current_line_number = @right_diff_line_number
      ret = '...'
    elsif line[0] == ?-
      ret = ' '
    elsif line[0] == ?+
      ret = @right_diff_line_number.to_s
      @right_diff_line_number += 1
      @current_line_number = @right_diff_line_number - 1
    else
      ret = @right_diff_line_number.to_s
      @right_diff_line_number += 1
      @current_line_number = @right_diff_line_number - 1
    end
    ret
  end
end
