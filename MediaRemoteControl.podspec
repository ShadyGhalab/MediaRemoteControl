Pod::Spec.new do |s|
  s.name             = 'MediaRemoteControl'
  s.version          = '0.1.0'
  s.summary          = 'MediaRemoteControl is a framework that can handle any media using the external controls '
 
  s.description      = <<-DESC
MediaRemoteControl is a framework that can handle the media using the external controls 
                       DESC
 
  s.homepage         = 'https://github.com/ShadyGhalab/MediaRemoteControl'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ShadyGhalab' => 'shadyghalab@gmail.com' }
  s.source           = { :git => 'https://github.com/ShadyGhalab/MediaRemoteControl.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '8.0'
  s.source_files = 'MediaRemoteControl/*.{swift,plist}'
 
end