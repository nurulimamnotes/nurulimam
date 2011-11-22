module Nesta
  class App
    use Rack::Static, :urls => ["/simple"], :root => "themes/simple/public"
    get '/robots.txt' do
      content_type 'text/plain', :charset => 'utf-8'
      <<-EOF
User-agent: *
Allow: /

Sitemap: http://www.nurulimam.com/articles.xml
EOF
    end
    
    get '/articles.xml' do
      content_type :xml, :charset => 'utf-8'
      set_from_config(:title, :subtitle, :author)
      @articles = Page.find_articles.select { |a| a.date }[0..9]
      cache haml(:atom, :format => :xhtml, :layout => false)
    end

    get '/sitemap.xml' do
      content_type :xml, :charset => 'utf-8'
      @pages = Page.find_all
      @last = @pages.map { |page| page.last_modified }.inject do |latest, page|
        (page > latest) ? page : latest
      end
      cache haml(:sitemap, :format => :xhtml, :layout => false)
    end

    get '*' do
      set_common_variables
      @heading = @title
      parts = params[:splat].map { |p| p.sub(/\/$/, '') }
      @page = Nesta::Page.find_by_path(File.join(parts))
      raise Sinatra::NotFound if @page.nil?
      @title = @page.title
      @body_class = @page.date.nil ? 'page' : 'article'
      @body_class = "foo"
      set_from_page(:description, :keywords)
      cache haml(@page.template, :layout => @page.layout)
    end
  end
end
