Pod::Spec.new do |s|
  s.name                        = "ReactiveNetService"
  s.version                     = "1.0.8"
  s.summary                     = "Additions to the NSNetService/NSNetServiceBrowser ecosystem for greater interoperability with ReactiveCocoa."
  s.description                 = <<-DESC
                                Additions to the NSNetService/NSNetServiceBrowser ecosystem for greater
                                interoperability with ReactiveCocoa.

                                This is largely based on Chris Devereux's ReactiveNetService, but adds 
                                some more convenience methods, handles TXT record updates, and so forth. 
                                I started with Chris' work but spent enough time hacking around issues 
                                with my (admittedly strange) usage scenarios that I wanted to create a 
                                distinct project rather than pollute his project with my weird edge cases :)
                                DESC
  s.homepage                    = "https://github.com/ndouglas/ReactiveNetService"
  s.license                     = { :type => "Public Domain", :file => "LICENSE" }
  s.author                      = { "Nathan Douglas" => "ndouglas@devontechnologies.com" }
  s.ios.deployment_target       = "7.0"
  s.osx.deployment_target       = "10.8"
  s.source                      = { :git => "https://github.com/ndouglas/ReactiveNetService.git", :tag => "1.0.8" }
  s.subspec 'Core' do |cs|
	cs.exclude_files            = "*.Tests.m"
	cs.source_files             = "*.{h,m}"
	cs.framework                = "Foundation"
	cs.dependency               "ReactiveCocoa"
	cs.dependency               "YOLOKit"
  end
  s.subspec 'Tests' do |ts|
	ts.source_files             = "*.Tests.m"
	ts.frameworks               = "Foundation", "XCTest"
	ts.dependency               "ReactiveNetService/Core"
  end
  s.default_subspec             = "Core"
end
