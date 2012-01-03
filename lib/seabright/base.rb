module Seabright
  class Base
    def initialize(content=nil)
      @content = content.nil? ? nil : minify(content)
      puts content if Seabright.verbose?
    end
    
    def minified; @content; end

    def minify(content)
      content.strip
    end
    
    def to_s
      minified
    end
    
    class << self
      def from_file(path)
        if verify_path(path)
          puts "Loading file: #{path}" if Seabright.debug?
          new(IO.read(path))
        else
          puts "File not found: #{path}"
        end
      end
      def from_files(files)
        files = files.split(",") if files.class == String
        files.collect do |path|
          from_file path.strip
        end.join("\n")
      end
      def verify_path(path)
        File.exists?(path)
      end
    end
  end
end