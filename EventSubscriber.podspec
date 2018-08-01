#
# Be sure to run `pod lib lint EventSubscriber.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EventSubscriber'
  s.version          = '0.1'
  s.summary          = 'A wrapper around NotificationCenter..'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Stateless event subscribing tool.
Based on Apple NSNotificationCenter.

Allows to create event types with strong structure of parameters.

You can create event based on enums and structs, subscribe and handle it at different places of your application.

Use Event protocol to deeclare an event type.
Conform EventSubscriber protocol to allow object subscribe for events
Pass event type into a subscribe() function block as parameter type to subscribe for specific event.
Not forget to call unsubscribeAll() method on deinit.

Please look at EventSubscriberTests for more clear understanding.

                       DESC
  s.homepage = 'https://github.com/utiko/EventSubscriber'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'uTiko' => 'tiko@utiko.net' }
  s.source = { :git => 'https://github.com/utiko/EventSubscriber.git', :tag => '0.1' }
  s.ios.deployment_target = '9.0'
  s.swift_version = '4.0'
  s.source_files = 'EventSubscriber/**/*'
#  s.dependency 'Alamofire', '~> 4.7.2'

end
