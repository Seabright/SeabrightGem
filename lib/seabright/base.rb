module Seabright
  class Base
    def initialize(content=nil)
      @content = content.nil? ? nil : minify(content)
    end
    
    def minified; @content; end

    def minify(content)
      class << content; include Minifier; end
      content.compress.strip
    end
    
    module Minifier
      def compress
        self
      end
    end
    
    class << self
      def from_file(path)
        self.new(IO.read(path)) if verify_path(path)
      end
      def verify_path(path)
        File.exists?(path)
      end
    end
  end
end