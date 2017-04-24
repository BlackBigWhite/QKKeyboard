

Pod::Spec.new do |spec|
spec.name             = 'QBPwdModule'
spec.version          = '2.5'
spec.summary          = 'Guide for private pods :'
spec.description      = <<-DESC
Guide for private pods
DESC
spec.homepage         = 'http://git.qianbaoqm.com/mobileios/'
spec.license          = { :type => 'MIT', :file => 'LICENSE' }
spec.author           = { 'qiaokai' => 'jinqiucheng1006@live.cn' }
spec.source           = { :git => 'http://git.qianbaoqm.com/mobileios/QBPwdModule.git', :tag => spec.version.to_s }
spec.ios.deployment_target = '8.0'
spec.source_files = 'QBPwdModule/Classes/*.{h,m}'

spec.resources = "QBPwdModule/Assets/*.png"
end


