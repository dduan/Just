
Pod::Spec.new do |s|

  s.name         = "Just"
  s.version      = "0.0.1"
  s.summary      = "Swift HTTP for Humans"

  s.description  = <<-DESC
                   Just is a HTTP library with an elegant interface inspired by (python-request)[http://python-request.org]

                   Features includes:

                   -   URL queries
                   -   custom headers
                   -   form (`x-www-form-encoded`) / JSON HTTP body
                   -   redirect control
                   -   multpart file upload along with form values.
                   -   basic/digest authentication
                   -   cookies
                   -   timeouts
                   -   synchrounous / asyncrounous requests
                   -   friendly accessible results
                   DESC

  s.homepage     = "http://justhttp.net"

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniel Duan" => "daniel@duan.org" }
  s.social_media_url   = "https://twitter.com/Daniel_Duan"

   s.ios.deployment_target = "8.0"
   s.osx.deployment_target = "10.10"

  s.source       = { :git => "https://github.com/JustHTTP/Just.git", :tag => "v#{s.version}" }


  s.source_files  = "Just", "Just/**/*.{swift}"

end
