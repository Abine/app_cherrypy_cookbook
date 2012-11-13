#
# Cookbook Name:: app_cherrypy
# Recipe:: default
#
# Copyright 2012, Abine, Inc.
#
# All rights reserved - Do Not Redistribute
#
rightscale_marker :begin

# Set up the LWRP resources
node[:app][:provider] = 'app_cherrypy'

# Install the packages
aptpkgs = ['phantomjs']
pypis = ['distribute', 'mysql-python', 'beautifulsoup4', 'cherrypy', 'html5lib']
aptpkgs.each do |p|
	log "apt #{p}"
	package p do
		action :install
	end
end

pypis.each do |p|
	log "pip #{p}"
	python_pip p do
		action :install
	end
end

node[:app][:destination] = node[:repo][:default][:destination]

rightscale_marker :end
