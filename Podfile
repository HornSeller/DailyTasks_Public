# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'DailyTasks' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DailyTasks

pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'IQKeyboardManagerSwift'
pod 'KDCircularProgress'
pod 'CVCalendar', '~> 1.7.0'

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.4'
            end
        end
    end
end

end
