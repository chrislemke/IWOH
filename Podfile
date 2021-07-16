platform :ios, '13.0'
#inhibit_all_warnings!
use_frameworks!

def shared
  pod 'GoogleUtilities/AppDelegateSwizzler'
  pod 'GoogleUtilities/Environment'
  pod 'GoogleUtilities/ISASwizzler'
  pod 'GoogleUtilities/Logger'
  pod 'GoogleUtilities/MethodSwizzler'
  pod 'GoogleUtilities/NSData+zlib'
  pod 'GoogleUtilities/Network'
  pod 'GoogleUtilities/Reachability'
  pod 'GoogleUtilities/UserDefaults'
  pod 'FirebaseCore'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'Firebase/Auth'
  pod 'Firebase/MLNaturalLanguage'
  pod 'Firebase/MLNLLanguageID'
  pod 'SwiftLint'
end

target 'IWOH' do
  shared
  pod 'Firebase/Messaging'
  pod 'Firebase/InAppMessaging'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Performance'
  pod 'FLEX', :configurations => ['Debug']
end

target 'IWOHTests' do
  inherit! :search_paths
end

target 'IWOHIntents' do
  shared
end

target 'IWOHIntentsUI' do
  shared
end

target 'IWOHInteractionKit' do
  shared
end

target 'IWOHInteractionKitTests' do
  inherit! :search_paths
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
  end
end
