Pod::Spec.new do |spec|
  spec.name         = 'zlCache'
  spec.version      = '1.0.1'
  spec.license      = { :type => 'Personal', :text => 'zilong.li' }
  spec.summary      = 'A Lib For cache.'
  spec.homepage     = 'https://github.com/lizilong1989/zlCache.git'
  spec.author       = {'zilong.li' => '15131968@qq.com'}
  spec.source       =  {:git => 'https://github.com/lizilong1989/zlCache.git', :tag => spec.version.to_s }
  spec.source_files = "zlCache/**/*.{h,m,mm,cpp,hpp}"
  spec.public_header_files = 'zlCache/**/*.{h}'
  spec.platform     = :ios, '8.0'
  spec.requires_arc = true
  spec.xcconfig     = {'OTHER_LDFLAGS' => '-ObjC'}
end
