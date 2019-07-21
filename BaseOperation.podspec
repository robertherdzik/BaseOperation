Pod::Spec.new do |s|
s.name         = "BaseOperation"
s.version      = "0.0.4"
s.summary      = "Easy to use base class for Operation"
s.description  = "Easy to use base class for Operation"
s.homepage     = "https://github.com/robertherdzik/BaseOperation"

# ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.license = { :type => "MIT", :file => "LICENSE" }

# ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.author             = { "Robert Herdzik" => "robert.herdzik@yahoo.com" }

# ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.source = {
:git => "https://github.com/robertherdzik/BaseOperation.git",
:tag => s.version.to_s
}

s.ios.deployment_target = '10.0'
s.requires_arc = true

# ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.ios.source_files  = "BaseOperation/**/*.{swift}"

end
