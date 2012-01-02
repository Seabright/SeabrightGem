module Seabright
  class Image < Base

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
        require 'base64'
        "data:image/png;base64,#{Base64.encode64(self).gsub("\n",'')}"
      end
    end
    
  end
end