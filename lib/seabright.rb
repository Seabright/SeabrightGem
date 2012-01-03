module Seabright
  DEBUG = false
  def self.debug?
    DEBUG
  end
  def self.debug!
    DEBUG = true
  end
  autoload :Base, "seabright/base"
  autoload :ClassFactory, "seabright/class_factory"
  autoload :Stylesheet, "seabright/stylesheet"
  autoload :Javascript, "seabright/javascript"
  autoload :Image, "seabright/image"
  autoload :Bundle, "seabright/bundle"
end