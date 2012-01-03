module Seabright
  class Stylesheet < Base
    def self.minifies?(paths) !paths.grep(%r[\.css(\?\d+)?$]).empty?; end

    def minify(content)
      class << content; include CSSMinifier; end
      content.compress_whitespace.remove_comments.remove_spaces_outside_block.
        remove_spaces_inside_block.trim_last_semicolon.encode_images.strip
    end
    
    module CSSMinifier
      def compress_whitespace; compress!(/\s+/, ' '); end
      def remove_comments; compress!(/\/\*.*?\*\/\s?/, ''); end
      def remove_spaces_outside_block
        compress!(/(\A|\})(.*?)\{/) { |m| m.gsub(/\s?([}{,])\s?/, '\1') }
      end
      def remove_spaces_inside_block
        compress!(/\{(.*?)(?=\})/) do |m|
          m.gsub(/(?:\A|\s*;)(.*?)(?::\s*|\z)/) { |n| n.gsub(/\s/, '') }.strip
        end
      end
      def trim_last_semicolon; compress!(/;(?=\})/, ''); end
      def encode_images
        compress!(/\{(.*?)(?=\})/) do |m|
          m.gsub(/\burl\(([^\)]+)\)/) { |n| "url(#{Seabright::Image.from_file("static"+$1)})" }.strip
        end
      end
    private
      def compress!(*args, &block) gsub!(*args, &block) || self; end
    end
  end
end