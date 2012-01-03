module Seabright
  @@debug = false
  def self.debug?
    @@debug
  end
  def self.verbose?
    @@debug == 3
  end
  def self.debug!
    @@debug = true
  end
  def self.verbose!
    @@debug = 3
  end
  autoload :Base, "seabright/base"
  autoload :ClassFactory, "seabright/class_factory"
  autoload :Stylesheet, "seabright/stylesheet"
  autoload :Javascript, "seabright/javascript"
  autoload :Image, "seabright/image"
  autoload :Bundle, "seabright/bundle"
end