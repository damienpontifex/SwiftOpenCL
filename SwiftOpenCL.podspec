Pod::Spec.new do |s|
  s.name         = "SwiftOpenCL"
  s.version      = "0.0.1"
  s.summary      = "A short description of SwiftOpenCL."

  s.description  = <<-DESC
                   A longer description of SwiftOpenCL in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://EXAMPLE/SwiftOpenCL"
  s.license      = "MIT (example)"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Damien Pontifex" => "damien.pontifex@gmail.com" }
  s.social_media_url   = "http://twitter.com/DamienPontifex"
  s.platform     = :osx
  s.source       = { :git => "http://github.com/damienpontifex/SwiftOpenCL.git", :tag => "0.0.1" }
  s.source_files  = "SwiftOpenCL.playground/Sources/**/*.swift"
  s.framework  = "OpenCL"
end
