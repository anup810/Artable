platform :ios, '13.0'

def shared_pods
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Functions'
  pod 'IQKeyboardManagerSwift', '~> 7.1.1'
  pod 'Kingfisher', '~> 7.12.0'
  pod 'Stripe', '~> 23.4.0'
end

target 'Artable' do
  use_frameworks!
  shared_pods
  
end

target 'ArtableAdmin' do
  use_frameworks!
  shared_pods
end
