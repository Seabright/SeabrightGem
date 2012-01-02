module Seabright
  class Javascript < Base
    def minify(content)
      class << content; include JSMinifier; end
      content.compress.strip
    end
    
    module JSMinifier
      def compress
        require 'closure-compiler'
        self.replace Closure::Compiler.new.compile(self)
      end
    end
  end
end