# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'sabusuku' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for prg
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'
pod 'Firebase/Database'
pod 'Charts'
pod 'FSCalendar'
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.4'
               end
          end
   end
end
