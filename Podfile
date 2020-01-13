platform :macos, '10.14'
use_frameworks!

target 'Dash' do
  pod 'RTTrPSwift'
  pod 'SwiftOSC', '~> 1.3', :inhibit_warnings => true
  pod 'CocoaAsyncSocket', '~> 7.6.3', :inhibit_warnings => true

  target 'DashTests' do
    inherit! :search_paths
  end
end
