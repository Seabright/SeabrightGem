module Seabright
	class Stylesheet < Base
		
		def initialize(content=nil,file=nil,sass=false)
			@file = file
			@content = content.nil? ? nil : minify(content)
			@sass = sass
			puts content if Seabright.verbose?
		end
		
		class << self
			def from_file(path)
				if verify_path(path)
					puts "Loading file: #{path}" if Seabright.debug?
					new(IO.read(path),path)
				elsif verify_path(spath = scss_path(path))
					puts "Loading file: #{spath}" if Seabright.debug?
					@sass = true
					new(IO.read(spath),spath,true)
				else
					puts "\e[33m" << "File not found: #{path}" << "\e[0m"
				end
			end
			def scss_path(path)
				File.dirname(path) + "/sass/" + File.basename(path).split(".")[0] + ".scss"
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
		
		def self.minifies?(paths) !paths.grep(%r[\.css(\?\d+)?$]).empty?; end
		
		def minify(content)
			if @sass
				class << content; include SASSifier; end
				content.sassify!
			end
			class << content; include CSSMinifier; end
			content.compress_whitespace.remove_comments.remove_spaces_outside_block.remove_spaces_inside_block.trim_last_semicolon
			encode_images(content).strip
		end
		
		def encode_images(c)
			$encoded ||= []
			c.compress!(/\{(.*?)(?=\})/) do |m|
				m.gsub(/\burl\(\"?\'?([^\)]+(\.[^\)|\?|\#|\"|\']+))([\?|\#][^\)|\"|\']+)?\"?\'?\)/) do |n| # $1 = filename, $2 = extension
					return m if $1[0..4] == "data:"
					case $2
					when ".png",".jpg",".jpeg",".gif"
						img = $1
						fl = !@file || /^\//.match(img) ? "#{Seabright::Bundle.static_path}#{img[1..-1]}" : "#{File.expand_path(File.dirname(@file))}#{img}"
						file = Seabright::Image.from_file(fl)
						if $encoded.include?(fl)
							# puts "\e[31m" << "Duplicate image: #{fl} (in #{@file})" << "\e[0m" if DEBUG
							$return = 1
						end
						$encoded << fl
					when ".eot",".woff",".ttf"
						file = $1
					else
						file = $1
					end
					"url(#{file})"
				end.strip
			end
		end
		
		module SASSifier
			require 'sass'
		  require "seabright/bourbon"
			def sassify!
				engine = Sass::Engine.new(self, :syntax => :scss, :load_paths => ["Interface/static/stylesheets/sass"])
				replace engine.render
			end
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
			def compress!(*args, &block) gsub!(*args, &block) || self; end
		end
	end
end