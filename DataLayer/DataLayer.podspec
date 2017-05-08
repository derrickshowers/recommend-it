Pod::Spec.new do |s|
  s.name         = 'DataLayer'
  s.version      = '0.0.1'
  s.summary      = 'Data layer for Recommend-It'
  s.homepage     = 'https://derrickshowers.com'
  s.license      = 'MIT'
  s.author       = { 'Derrick Showers' => 'derrick@derrickshowers.com' }
  s.platform     = :ios, '10.0'
  s.source       = { :path => '.' }
  s.source_files  = 'DataLayer', 'DataLayer/**/*.{h,m,swift}'
  s.dependency 'Alamofire', '~> 4.0.0'
end
