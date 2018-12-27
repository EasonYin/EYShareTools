#
# Be sure to run `pod lib lint EYShareTools.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EYShareTools'
  s.version          = '0.0.1'
  s.summary          = '（微信/QQ/微博）分享集合'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/EasonYin/EYShareTools'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'huadong2593@163.com' => 'EasonYin' }
  s.source           = { :git => 'https://github.com/EasonYin/EYShareTools.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.static_framework = true
  s.pod_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }

  #
  s.source_files = 'EYShareTools/EYShareToolsConfigure.h','EYShareTools/Classes/**/*.{h,m}'
  s.resources = 'EYShareTools/Assets/*.xcassets'

  #依赖基础库
  s.frameworks = 'UIKit', 'Foundation', 'Security', 'CoreGraphics', 'ImageIO', 'SystemConfiguration', 'CoreTelephony', 'QuartzCore', 'CoreText', 'Photos'
  s.libraries = 'z', 'sqlite3', 'c++', 'stdc++'
  
  #依赖第三方
  s.dependency 'Masonry'
  
  s.preserve_path = 'EY_vendored_libs/**/*.*'
  s.subspec 'EY_vendored_libs' do |sb|
    #微博
    sb.subspec 'libWeiboSDK_3.2.3' do |submain|
        submain.source_files = "EY_vendored_libs/libWeiboSDK_3.2.3/*.h"
        submain.vendored_library = "EY_vendored_libs/libWeiboSDK_3.2.3/*.a"
        submain.resource = "EY_vendored_libs/libWeiboSDK_3.2.3/*.bundle"
    end
    #微信
    sb.subspec 'WechatSDK_1.8.2' do |submain|
        submain.vendored_library = "EY_vendored_libs/WechatSDK_1.8.2/*.a"
        submain.source_files = "EY_vendored_libs/WechatSDK_1.8.2/*.{h,txt}"
    end
    #QQ
    sb.subspec 'TencentOpenAPI_3.3.3' do |submain|
        submain.vendored_frameworks = "EY_vendored_libs/TencentOpenAPI_3.3.3/*.framework"
    end
    
  end

end
