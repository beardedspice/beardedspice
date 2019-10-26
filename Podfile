platform :osx, '10.14'
project 'Beardie'

source 'https://github.com/CocoaPods/Specs.git'

target 'BeardieControllers' do
    pod 'MASShortcut', '~> 2.3.3'

    target 'Beardie' do
        pod 'MASPreferences', '= 1.1.4'
        pod 'FMDB', '~> 2.6.2'

        # all pods for tests should ONLY go here
        target 'BeardieTests' do
            pod 'Kiwi'
            # pod 'OCMock'
            pod 'VCRURLConnection'
        end
    end
end
