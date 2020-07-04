platform :osx, '10.14'

source 'https://github.com/CocoaPods/Specs.git'
project 'Beardie'

def commons
pod 'CocoaLumberjack', :modular_headers => true
end
def commons_swift
pod 'CocoaLumberjack/Swift', :modular_headers => true
end

target 'Beardie' do
    commons_swift
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
target 'beardie-nm-connector' do
  commons_swift
end

abstract_target "Commons" do
  commons
  target 'BS-Extension'
  target 'BeardieControllers' do
      pod 'MASShortcut', '~> 2.4.0'
  end
end
