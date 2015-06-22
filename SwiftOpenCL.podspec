Pod::Spec.new do |s|
  s.name         = "SwiftOpenCL"
  s.version      = "0.0.1"
  s.summary      = "Swift OpenCL wrapper"

  s.description  = <<-DESC
                   Object Oriented wrapper around the OpenCL API. Inspired
                   by the C++ implementation and developed to avoid the 
                   pain of interfacing the C style structure of the library
                   to Swift equivalents
                   DESC

  s.homepage     = "http://github.com/damienpontifex/SwiftOpenCL"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Damien Pontifex" => "damien.pontifex@gmail.com" }
  s.social_media_url   = "http://twitter.com/DamienPontifex"
  s.platform     = :osx, "10.9"
  s.source       = { :git => "https://github.com/damienpontifex/SwiftOpenCL.git", :tag => s.version }
  s.source_files  = "SwiftOpenCL.playground/Sources/**/*.swift"
  s.framework  = "OpenCL"
end
