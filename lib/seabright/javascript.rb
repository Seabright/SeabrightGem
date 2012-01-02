module Seabright
  class Javascript < Base
    module Minifier
      def compress
        require 'closure-compiler'
        puts Closure::Compiler.new.compile(self)
        self.replace Closure::Compiler.new.compile(self)
      end
    end
  end
end