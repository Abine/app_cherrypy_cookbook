#
# Cookbook Name:: app_cherrypy
# Recipe:: default
#
# Copyright 2012, Abine, Inc.
#
# All rights reserved - Do Not Redistribute
#

# nop and unsupported actions
action :reload do
	raise "Action not available: reload"
end
action :setup_monitoring do
	raise "Monitoring not supported by CherryPy"
end
action :setup_vhost do
	raise "VHOSTs not supported by CherryPy"
end
action :setup_db_connection do
  raise "DB connection setup not supported by CherryPy"
end

# Stop cherrypy
action :stop do
	log "  Running stop sequence"
	pid = `cat /var/run/cherrypy.pid`
	execute 'send signal to cherrypy' do
		command "kill -TERM #{pid}"
		not_if {pid.empty?}
	end
end

# Start cherrypy
action :start do
	log "  Running start sequence"
	execute "python #{node[:app_cherrypy][:script]}" do
		cwd node[:app][:destination]
	end
end

# Restart
action :restart do
  log "  Running restart sequence"
  action_stop
  sleep 5
  action_start
end

# Installing required packages to system
action :install do
	log "Nothing to do here"
end


# Download/Update application repository
action :code_update do
  deploy_dir = new_resource.destination

  log "  Starting code update sequence"
  log "  Current project doc root is set to #{deploy_dir}"

  log "  Starting source code download sequence..."
  # Calling "repo" LWRP to download remote project repository
  repo "default" do
    destination deploy_dir
    action node[:repo][:default][:perform_action].to_sym
    app_user node[:app][:user]
    repository node[:repo][:default][:repository]
    persist false
  end

  # Moving rails application log directory to ephemeral

  # Removing log directory, preparing to symlink
  directory "#{deploy_dir}/log" do
    action :delete
    recursive true
  end

  # Creating new rails application log  directory on ephemeral volume
  directory "/mnt/ephemeral/log/cherrypy" do
    owner node[:app][:user]
    mode "0755"
    action :create
    recursive true
  end

  # Symlinking application log directory to ephemeral volume
  link "#{deploy_dir}/log" do
    to "/mnt/ephemeral/log/cherrypy"
  end

  log "  Generating new logrotate config for rails application"
  rightscale_logrotate_app "app_cherrypy" do
    cookbook "rightscale"
    template "logrotate.erb"
    path ["#{deploy_dir}/log/*.log"]
    frequency "size 10M"
    rotate 4
    create "660 #{node[:app][:user]} #{node[:app][:group]}"
  end
  
  # Restart the server
  action_restart

end
