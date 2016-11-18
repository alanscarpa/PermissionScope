Pod::Spec.new do |s|
  s.name = 'PermissionScope'
  s.version = '1.1.1'
  s.license = 'MIT'
  s.summary = 'A Periscope-inspired way to ask for iOS permissions'
  s.homepage = 'https://github.com/nickoneill/PermissionScope'
  s.social_media_url = 'https://twitter.com/objctoswift'
  s.authors = { "Nick O'Neill" => 'nick.oneill@gmail.com' }
  s.source = { :git => 'https://github.com/nickoneill/PermissionScope.git', :tag => s.version }

  s.ios.deployment_target = '8.0'

  s.source_files = 'PermissionScope/*.swift'

  s.requires_arc = true

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files         = 'PermissionScope/*.{swift,h}'
  end

  s.subspec 'Motion' do |motion|
    motion.dependency 'PermissionScope/Core'
    motion.source_files         = 'PermissionScope/Motion/*.swift'
    motion.weak_framework       = 'CoreMotion'
    motion.pod_target_xcconfig  = feature_flags
    motion.user_target_xcconfig = feature_flags
  end

end
