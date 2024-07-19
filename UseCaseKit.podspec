Pod::Spec.new do |spec|
  spec.name         = 'UseCaseKit'
  spec.version      = '0.4.2'
  spec.license      = 'crexista'
  spec.homepage     = 'https://github.com/crexista/UseCaseKit.git'
  spec.source       = { :git => 'https://github.com/crexista/UseCaseKit.git', :tag => '0.4.2' }
  spec.authors      = { 'crexista' => 'crexista@gmail.com' }
  spec.summary      = 'Improved MVVM architecture with unidirectional data flow like a Flux.'
  spec.source_files = 'Sources/UseCaseKit/*.{swift}'
  spec.ios.deployment_target = '14.0'
  spec.osx.deployment_target = '12.0'
  spec.watchos.deployment_target = '7.0'
end
