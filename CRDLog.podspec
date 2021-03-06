#
#  Be sure to run `pod spec lint CRDLog.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

# ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#

s.swift_version = '5.0'
s.name         = "CRDLog"
s.version      = "1.0.4"
s.summary      = "Simple and quick logging for your iOS, macOS, watchOS, and tvOS apps."
s.description  = <<-DESC
Simple straightforward Swift-based logging facility for iOS, macOS, watchOS, and tvOS apps.
DESC

s.homepage     = "https://github.com/cdisdero/CRDLog"

# ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#

s.license      = "Apache License, Version 2.0"

# ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#

s.author             = { "Christopher Disdero" => "info@code.chrisdisdero.com" }

# ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#

s.ios.deployment_target = "9.0"
s.osx.deployment_target = "10.12"
s.watchos.deployment_target = "3.0"
s.tvos.deployment_target = "9.0"

# ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#

s.source       = { :git => "https://github.com/cdisdero/CRDLog.git", :tag => "#{s.version}" }

# ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#

s.source_files  = "Shared/*.swift"
s.ios.source_files   = 'CRDLogMobile/*.h'
s.osx.source_files   = 'CRDLogMac/*.h'
s.watchos.source_files = 'CRDLogWatch/*.h'
s.tvos.source_files  = 'CRDLogTV/*.h'

end
