Pod::Spec.new do |spec|
  spec.name         = 'UseCaseKit'
  spec.version      = '0.3.0'
  spec.license      = 'crexista'
  spec.homepage     = 'https://github.com/crexista/UseCaseKit.git'
  spec.source       = { :git => 'https://github.com/crexista/UseCaseKit.git', :tag => '0.3.0' }
  spec.authors      = { 'crexista' => 'crexista@gmail.com' }
  spec.summary      = 'Improved MVVM architecture with unidirectional data flow like a Flux.'
  spec.source_files = 'Sources/UseCaseKit/*.{swift}'
end
