module Seabright
	
	class BaseFile
		
		def initialize(content,type = :file)
			@type = type.to_sym
			send("#{@type}=".to_sym,content)
		end
		
		def file=(filename)
			@file = filename
		end
		
		def file
			"#{Bundle.static_path}#{@file}"
		end
		
		# def blob(content)
		# 	
		# end
		
		def signature
			Proc.new { |file|
				sig = file
				File.open(file) do |f|
					sig << f.mtime.to_i.to_s
				end
				require 'digest'
				Digest::MD5.hexdigest(sig)
			}.call(file)
		end
		
		def compressed
			raise "No compressor configured"
		end
		
		def tag
			"<file src=\"/#{@file}\"></file>\n"
		end
		
	end
	
	class JSFile < BaseFile
		
		def compressed
			if @type == :file 
				return Javascript.from_file(file)
			end
		end
		
		def tag
			"<script language=\"javascript\" src=\"/#{@file}\"></script>\n"
		end
		
	end
	
	class CSSFile < BaseFile
		
		def signature
			Proc.new { |file|
				sig = get_file(file)
				File.open(sig) do |f|
					sig << f.mtime.to_i.to_s
				end
				require 'digest'
				Digest::MD5.hexdigest(sig)
			}.call(file)
		end
		
		def scss_path(path)
			File.dirname(path) + "/sass/" + File.basename(path).split(".")[0] + ".scss"
		end
		
		def verify_path(path)
			File.exists?(path)
		end
		
		def get_file(path)
			if verify_path(path)
				return path
			elsif verify_path(spath = scss_path(path))
				return spath
			end
			return path
		end
		
		def compressed
			if @type == :file 
				return Stylesheet.from_file(file)
			end
		end
		
		def tag
			"<link rel=\"stylesheet\" href=\"/#{@file}\" media=\"screen\"/>\n"
		end
		
	end
	
	class Bundle
		
		@@base_path = "static/"
		@@cache_subdir = "/cache/"
		
		def initialize(name, type = :file, compress = true, &block)
			raise "Nothing to bundle" unless block
			@name = name.to_sym
			@type = type.to_sym
			@compress = compress
			$bundles ||= {}
			if $bundles[@name]
				return $bundles[@name]
			end
			$bundles[@name] = self
			self.instance_eval(&block)
			# if @type!=:inline
			# 	save_files
			# end
		end
		
		def to_s(compressed=compressed?)
			unless @last_sig_time && @last_sig_time > (Time.now - 60)
				expire_sigs
			end
			if compressed?
				@type==:inline ? inline_html : html
			else
				out = ""
				files.each do |file|
					out << file.tag
				end
				out
			end
		end
		
		def compressed?
			(js_compressed? && css_compressed?)
		end
		
		def compress!
			expire_sigs
			@compressed = (compress_js! && compress_css!)
		end
		
		def expire_sigs
			@sig = @js_sig = @css_sig = @html = @inline = nil
			@last_sig_time = Time.now
		end
		
		def js_compressed?
			File.exists?(javascript_file) || !has_javascript?
		end
		
		def compress_js!
			return true if js_compressed?
			code = javascript_code
			File.open(javascript_file, 'w') do |f|
				f.write(code)
			end
			code = nil
			true
		end
		
		def css_compressed?
			File.exists?(stylesheet_file) || !has_stylesheet?
		end
		
		def compress_css!
			return true if css_compressed?
			code = stylesheet_code
			File.open(stylesheet_file, 'w') do |f|
				f.write(code)
			end
			code = nil
			true
		end
		
		def signature(f)
			sig = Proc.new { |files|
				sig = files.inject("") {|a,v| a << v.signature; a}
				require 'digest'
				Digest::MD5.hexdigest(sig)
			}.call(f)
			sig
		end
		
		def js_signature
			@js_sig ||= signature(javascripts)
		end
		
		def css_signature
			@css_sig ||= signature(stylesheets)
		end
		
		def files
			@files ||= []
		end
		
		def javascript(file=nil,&block)
			javascript_files.push file
			fl = JSFile.new(file)
			files.push fl
			javascripts.push fl
		end
		alias :js :javascript
		
		def javascripts
			@javascripts ||= []
		end
		
		def has_javascript?
			!!javascripts.length
		end
		
		def javascript_files
			@javascript_files ||= []
		end
		
		def stylesheet(file=nil,&block)
			stylesheet_files.push file
			fl = CSSFile.new(file)
			files.push fl
			stylesheets.push fl
		end
		alias :css :stylesheet
		
		def stylesheets
			@stylesheets ||= []
		end
		
		def has_stylesheet?
			!!stylesheets.length
		end
		
		def stylesheet_files
			@stylesheet_files ||= []
		end
		
		def javascript_url
			url
		end
		
		def stylesheet_url
			url(:css)
		end
		
		def html
			return @html if @html
			@html = ""
			@html << "<link rel=\"stylesheet\" href=\"#{stylesheet_url}\" media=\"screen\"/>\n" if has_stylesheet?
			@html << "<script language=\"javascript\" src=\"#{javascript_url}\"></script>\n" if has_javascript?
		end
		
		def inline_html
			return @inline if @inline
			@inline = ""
			@inline << "<style media=\"screen\">\n#{stylesheet_code}\n</style>\n" if has_stylesheet?
			@inline << "<script language=\"javascript\">\n#{javascript_code}\n</script>\n" if has_javascript?
		end
		
		class << self
			
			def [](name)
				$bundles[name.to_sym] || nil
			end
			
			def set_static_path(path)
				@@base_path = path + "/"
			end
			
			def static_path
				@@base_path
			end
			
			def set_cache_subdir(path)
				@@cache_subdir = path
			end
			
			def compress_all
				$bundles.each do |k,v|
					v.compress!
				end
			end
			
		end
		
		private
		
		def url(ext=:js)
			"#{@@cache_subdir}#{@name}-#{send("#{ext}_signature".to_sym)}.#{ext}"
		end
		
		def javascript_code
			javascripts.collect do |fl|
				fl.compressed
			end.join
		end
		
		def stylesheet_code
			stylesheets.collect do |fl|
				fl.compressed
			end.join
		end
		
		def javascript_file
			"#{@@base_path}#{javascript_url}"
		end
		
		def stylesheet_file
			"#{@@base_path}#{stylesheet_url}"
		end
		
		def file_from_base(file)
			"#{@@base_path}#{file}"
		end
		
	end
end