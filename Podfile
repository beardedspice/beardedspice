platform :osx, '10.14'

source 'https://github.com/CocoaPods/Specs.git'
project 'Beardie'

target 'Beardie' do
    pod 'CocoaLumberjack/Swift', :modular_headers => true
    pod 'MASPreferences', '~> 1.3'
    pod 'MASShortcut', '~> 2.4.0'
    pod 'FMDB'

    # all pods for tests should ONLY go here
    target 'BeardieTests' do
        pod 'Kiwi', '~> 3.0.0'
        # pod 'OCMock'
        pod 'VCRURLConnection', '~> 0.2.5'
    end
end

abstract_target "Commons" do
  pod 'CocoaLumberjack/Swift', :modular_headers => true
  target 'beardie-nm-connector'
  target 'BS-Extension'
  target 'BeardieControllers' do
      pod 'MASShortcut', '~> 2.4.0'
  end
end
