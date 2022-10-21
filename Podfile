platform :macos, '11.0'
use_frameworks!

target 'Dash' do
  pod 'RTTrPSwift', '~> 0.6'
  pod 'SwiftOSC', '~> 1.3', :inhibit_warnings => true
  pod 'CocoaAsyncSocket', '~> 7.6.3', :inhibit_warnings => true

  target 'DashTests' do
    inherit! :search_paths
  end
end
