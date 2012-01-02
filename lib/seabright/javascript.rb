module Seabright
  class Javascript < Base
    module Minifier
      def compress
        require 'closure-compiler'
        self.replace Closure::Compiler.new.compile(self)
      end
    end
  end
end