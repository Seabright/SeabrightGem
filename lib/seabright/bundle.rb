module Seabright
  class Bundle
    
    @@base_path = "static/"
    @@cache_subdir = "cache/"
    
    def initialize(name,type=:file,&block)
      @name = name.to_sym
      $bundles ||= {}
      if slf=$bundles[@name]
        if type==:inline
          return slf.inline_html
        else
          return slf.html
        end
      end
      $bundles[@name] = self
      yield(self)
      if type==:inline
        return inline_html
      else
        save_files
      end
      return html
    end
    
    def javascript(file=nil,&block)
      @javascripts ||= []
      @javascripts.push file ? Javascript.from_file(file).to_s : Javascript.new(capture(&block)).to_s
    end
    
    def stylesheet(file=nil,&block)
      @stylesheets ||= []
      @stylesheets.push file ? Stylesheet.from_file(file) : Stylesheet.new(capture(&block))
    end
    
    def javascript_url
      url
    end
    
    def stylesheet_url
      url(:css)
    end
    
    def html
      return @html if @html
      @html = ""
      @html << "<link rel=\"stylesheet\" href=\"#{stylesheet_url}\" media=\"screen\"/>" if @stylesheets
      @html << "<script language=\"javascript\" href=\"#{javascript_url}\"></script>" if @javascripts
    end
    
    def inline_html
      return @inline if @inline
      @inline = ""
      @inline << "<style media=\"screen\">#{stylesheet_code}</style>" if @stylesheets
      @inline << "<script language=\"javascript\">#{javascript_code}</script>" if @javascripts
    end
    
    class << self
      
      def set_static_path(path)
        @@base_path = path
      end
      
      def set_cache_subdir(path)
        @@cache_subdir = path
      end
      
    end
    
    private

    def url(ext=:js)
      "#{@@cache_subdir}#{@name}.#{ext}"
    end
    
    def javascript_code
      @javascripts.join("\n")
    end
    
    def stylesheet_code
      @stylesheets.join("\n")
    end
    
    def javascript_file
      "#{@@base_path}#{javascript_url}"
    end
    
    def stylesheet_file
      "#{@@base_path}#{stylesheet_url}"
    end
    
    def save_files
      File.open(javascript_file, 'w') {|f| f.write(javascript_code) } if @javascripts
      File.open(stylesheet_file, 'w') {|f| f.write(stylesheet_code) } if @stylesheets
    end

  end
end