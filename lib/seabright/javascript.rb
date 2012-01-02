module Seabright
  class Javascript < Base
    def minify(content)
      class << content; include JSMinifier; end
      content.compress.strip
    end
    
    module JSMinifier
      def compress
        require 'closure-compiler'
        puts Closure::Compiler.new.compile(self)
        self.replace Closure::Compiler.new.compile(self)
      end
    end
  end
end