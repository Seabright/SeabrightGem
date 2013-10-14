module Seabright
  class Image < Base

    def initialize(content=nil,path=nil,type="image/png")
			@file = path
			@type = type
      @content = content.nil? ? nil : minify(content)
    end
    
    def minified; @content; end

    def minify(content)
      class << content; include Minifier; end
			"data:#{@type};base64,#{content.compress.strip}"
    end
    
    module Minifier
      def compress
        require 'base64'
        replace Base64.encode64(self).gsub("\n",'')
      end
    end
    
  end
end