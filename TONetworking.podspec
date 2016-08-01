Pod::Spec.new do |s|
s.name             = "TONetworking"
s.version          = "1.1.2"
s.summary          = "Make HTTP request works as a task. "
s.description      = <<-DESC
TONetworking will help you to manage your HTTP request.
concurrency , queue , mutex ... so easy.
DESC
s.homepage         = "https://github.com/TonyJR/TONetworking"
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { "Tony.JR" => "show_3@163.com" }
s.source           = { :git => "https://github.com/TonyJR/TONetworking.git", :tag => "#{s.version}" }
s.platform         = :ios, '7.0'           
s.requires_arc     = true  
             
s.source_files     = 'TONetworking/sourceCode/*.{h,m}'


s.frameworks       = 'Foundation'

s.dependency        'AFNetworking'
s.dependency        'Reachability'


end