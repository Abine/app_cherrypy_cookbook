maintainer       "Abine, Inc."
maintainer_email "cloud@abine.com"
license          "All rights reserved"
description      "Installs/Configures app_cherrypy"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

depends "rightscale"
depends "python"
depends "repo"
depends "app"

recipe "app_cherrypy::default", "Installs the files for the DM scraper."

attribute "app_cherrypy/script",
  :display_name => "Python script to start the daemon.",
  :description => "Relative path for the CherryPy daemon. Should be relative to the application directory",
  :required => "recommended",
  :default => "ScraperApp.py",
  :recipes => ["app_cherrypy::default"]
