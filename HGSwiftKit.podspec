#
# Be sure to run `pod lib lint HGSwiftKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HGSwiftKit'
  s.version          = '1.0.0'
  s.summary          = 'my swift tool'

  s.homepage         = 'https://hg_hupfei.coding.net/p/HGSwiftKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hupfei' => '573586346@qq.com' }
  s.source           = { :git => 'https://hg_hupfei.coding.net/p/HGSwiftKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_versions = ['5']

  s.requires_arc = true
  # 依赖的第三方库
  s.dependency 'SwifterSwift'
  s.dependency 'SnapKit'

  # 文件夹里面的文件路径
  s.source_files = 'HGSwiftKit/*.swift'
end
