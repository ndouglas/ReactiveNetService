Pod::Spec.new do |s|
  s.name         		= "ReactiveNetService"
  s.version      		= "1.0.4"
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
  s.source       		= { :git => "https://github.com/ndouglas/ReactiveNetService.git", :tag => "1.0.4" }
  s.source_files  		= "*.{h,m}"
  s.exclude_files 		= "*.Tests.m"
  s.framework			= "Foundation"
  s.dependency			"ReactiveCocoa"
  s.dependency			"YOLOKit"
  s.xcconfig 			= { 
				'GCC_PREPROCESSOR_DEFINITIONS' => 'YOLO_ALL=1 YOLO_ANY=1 YOLO_ARRAY=1 YOLO_CHUNK=1 YOLO_CONCAT=1 YOLO_DICT=1 YOLO_EACH=1 YOLO_EXTEND=1 YOLO_FIND=1 YOLO_FIRST=1 YOLO_FLATMAP=1 YOLO_FLATTEN=1 YOLO_FMAP=1 YOLO_GET=1 YOLO_GROUPBY=1 YOLO_HAS=1 YOLO_INDEXOF=1 YOLO_INJECT=1 YOLO_JOIN=1 YOLO_LAST=1 YOLO_MAP=1 YOLO_MAX=1 YOLO_MIN=1 YOLO_NONE=1 YOLO_PARTITION=1 YOLO_PICK=1 YOLO_PLUCK=1 YOLO_PMAP=1 YOLO_POP=1 YOLO_PUSH=1 YOLO_REDUCE=1 YOLO_REVERSE=1 YOLO_ROTATE=1 YOLO_SAMPLE=1 YOLO_SELECT=1 YOLO_SHIFT=1 YOLO_SHUFFLE=1 YOLO_SKIP=1 YOLO_SLICE=1 YOLO_SNIP=1 YOLO_SORT=1 YOLO_SPLIT=1 YOLO_TRANSPOSE=1 YOLO_UNIQ=1 YOLO_UNSHIFT=1 YOLO_UPTO=1 YOLO_WITHOUT=1' 
				}
end
