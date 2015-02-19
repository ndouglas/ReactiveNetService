Pod::Spec.new do |s|
  s.name         		= "ReactiveNetService"
  s.version      		= "1.0.0"
  s.summary      		= "Additions to the NSNetService/NSNetServiceBrowser ecosystem for greater interoperability with ReactiveCocoa."
  s.description  		= <<-DESC
					Additions to the NSNetService/NSNetServiceBrowser ecosystem for greater 
					interoperability with ReactiveCocoa.

					This is largely based on Chris Devereux's ReactiveNetService, but adds 
					some more convenience methods, handles TXT record updates, and so forth. 
					I started with Chris' work but spent enough time hacking around issues 
					with my (admittedly strange) usage scenarios that I wanted to create a 
					distinct project rather than pollute his project with my weird edge cases :)
		                   DESC
  s.homepage     		= "https://github.com/ndouglas/ReactiveNetService"
  s.license      		= { :type => "Public Domain", :file => "LICENSE" }
  s.author             		= { "Nathan Douglas" => "ndouglas@devontechnologies.com" }
  s.ios.deployment_target 	= "7.0"
  s.osx.deployment_target 	= "10.8"
  s.source       		= { :git => "https://github.com/ndouglas/ReactiveNetService.git", :tag => "1.0.0" }
  s.source_files  		= "*.{h,m}"
  s.exclude_files 		= "*.Tests.m""
  s.framework			= "Foundation"
  s.dependency			"ReactiveCocoa"
end
