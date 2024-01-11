
Pod::Spec.new do |s|
  s.name             = 'ZLPhotosSelectViewController'
  
  s.version          = '3.1.2'
  
  s.summary          = '定制照片选择器、图片压缩功能'

  s.homepage         = 'https://github.com/ZLPublicLibrary/ZLPhotosSelectViewController'
  
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  
  s.author           = { 'itzhaolei' => 'itzhaolei@foxmail.com' }
  
  s.source           = { :git => 'https://github.com/ZLPublicLibrary/ZLPhotosSelectViewController.git', :tag => s.version }

  s.ios.deployment_target = '9.0'
  s.requires_arc = true
  s.license  = 'MIT'
  s.framework  = "UIKit"
  
  s.source_files = 'ZLPhotosSelectViewController/Classes/ZLPhotosSelectHeader.h'
  s.public_header_files = 'ZLPhotosSelectViewController/Classes/ZLPhotosSelectHeader.h'
  
  s.subspec 'Album' do |ss|
      ss.source_files = 'ZLPhotosSelectViewController/Classes/Album/*.{h,m}'
      ss.resource_bundles = {
          'ZLPhotosSelectViewController' => ['ZLPhotosSelectViewController/Assets/**/*']
      }
  end
  
  s.subspec 'Compression' do |ss|
      ss.source_files = 'ZLPhotosSelectViewController/Classes/Compression/*.{h,m}'
  end
  
  s.subspec 'OperationQueue' do |ss|
      ss.source_files = 'ZLPhotosSelectViewController/Classes/OperationQueue/*.{h,m}'
  end
  
end
