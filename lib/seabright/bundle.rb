module Seabright
  class Bundle
    
    @@base_path = "static/"
    @@cache_subdir = "cache/"
    
    def initialize(name,type=:file,compress=true,&block)
      @name = name.to_sym
      @type = type.to_sym
      @compress = compress
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
    
    def to_s(compressed=true)
      if compressed
        @type==:inline ? inline_html : html
      else
        out = ""
        @javascript_files.each do |file|
          out << script_tag_for(file)
        end if @javascript_files
        @stylesheet_files.each do |file|
          out << link_tag_for(file)
        end if @stylesheet_files
        out
      end
    end
    
    def script_tag_for(file)
      "<script language=\"javascript\" src=\"/#{file}\"></script>\n"
    end
    
    def link_tag_for(file)
      "<link rel=\"stylesheet\" href=\"/#{file}\" media=\"screen\"/>\n"
    end
    
    def javascript(file=nil,&block)
      @javascripts ||= []
      if file && @compress
        @javascripts.push Javascript.from_file(file_from_base(file))
        puts "Compressed javascript: #{file}" if Seabright.debug?
      elsif @compress
        Javascript.new(capture(&block)).minified
        puts "Compressed javascript: Captured text" if Seabright.debug?
      end
      @javascript_files ||= []
      @javascript_files.push file
    end
    alias :js :javascript
    
    def stylesheet(file=nil,&block)
      @stylesheets ||= []
      if file && @compress
        @stylesheets.push Stylesheet.from_file(file_from_base(file))
        puts "Compressed stylesheet: #{file}" if Seabright.debug?
      elsif @compress
        Stylesheet.new(capture(&block))
        puts "Compressed stylesheet: Captured text" if Seabright.debug?
      end
      @stylesheet_files ||= []
      @stylesheet_files.push file
    end
    alias :css :stylesheet
    
    def file_from_base(file)
      "#{@@base_path}#{file}"
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
      @html << "<link rel=\"stylesheet\" href=\"#{stylesheet_url}\" media=\"screen\"/>\n" if @stylesheets
      @html << "<script language=\"javascript\" src=\"#{javascript_url}\"></script>\n" if @javascripts
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