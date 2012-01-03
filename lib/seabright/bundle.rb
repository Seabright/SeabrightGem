module Seabright
  class Bundle
    
    @@base_path = "static/"
    @@cache_subdir = "cache/"
    
    def initialize(name,type=:file,&block)
      @name = name.to_sym
      @type = type.to_sym
      $bundles ||= {}
      if $bundles[@name]
        return $bundles[@name]
      end
      $bundles[@name] = self
      self.instance_eval(&block)
      if @type!=:inline
        save_files
      end
    end
    
    def to_s
      if @type==:inline
        return inline_html
      end
      return html
    end
    
    def javascript(file=nil,&block)
      @javascripts ||= []
      @javascripts.push file ? Javascript.from_file(file).minified : Javascript.new(capture(&block)).minified
      puts "Loaded javascript: #{file || "Captured text"}" if Seabright.debug?
    end
    alias :js :javascript
    
    def stylesheet(file=nil,&block)
      @stylesheets ||= []
      @stylesheets.push file ? Stylesheet.from_file(file) : Stylesheet.new(capture(&block))
      puts "Loaded stylesheet: #{file || "Captured text"}" if Seabright.debug?
    end
    alias :css :stylesheet
    
    def javascript_url
      url
    end
    
    def stylesheet_url
      url(:css)
    end
    
    def html
      return @html if @html
      @html = ""
      @html << "<link rel=\"stylesheet\" href=\"#{stylesheet_url}\" media=\"screen\"/>\n" if @stylesheets
      @html << "<script language=\"javascript\" href=\"#{javascript_url}\"></script>\n" if @javascripts
    end
    
    def inline_html
      return @inline if @inline
      @inline = ""
      @inline << "<style media=\"screen\">\n#{stylesheet_code}\n</style>\n" if @stylesheets
      @inline << "<script language=\"javascript\">\n#{javascript_code}\n</script>\n" if @javascripts
    end
    
    class << self
      
      def [](name)
        $bundles[name.to_sym] || nil
      end
      
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
      @javascripts.join
    end
    
    def stylesheet_code
      @stylesheets.join
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