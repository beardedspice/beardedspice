platform :osx, '10.14'
project 'Beardie'

source 'https://github.com/CocoaPods/Specs.git'

target 'BeardieControllers' do
    pod 'MASShortcut', '~> 2.4.0'

    target 'Beardie' do
        pod 'MASPreferences', '~> 1.3'
        pod 'FMDB'

        # all pods for tests should ONLY go here
        target 'BeardieTests' do
            pod 'Kiwi', '~> 3.0.0'
            # pod 'OCMock'
            pod 'VCRURLConnection', '~> 0.2.5'
        end
    end
end
