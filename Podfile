platform :osx, '10.8'
xcodeproj 'BeardedSpice'

link_with 'BeardedSpice', 'BeardedSpiceTests'

source 'https://github.com/CocoaPods/Specs.git'

target 'BeardedSpiceControllers' do
    pod 'MASShortcut', '~> 2.3.3'

    target 'BeardedSpice' do
        pod 'MASPreferences', '~> 1.1.2'
    end
end

# all pods for tests should ONLY go here
target :BeardedSpiceTests, exclusive: true do
  pod 'Kiwi'
  pod 'OCMock'
  pod 'VCRURLConnection'
end
