#
# Cookbook Name:: redis
# Recipe:: default
#

#if ['util'].include?(node[:instance_role])
#if ['solo', 'app', 'app_master'].include?(node[:instance_role])

enable_package "dev-db/redis" do
  version "2.0.0rc3"
end

#package "dev-db/redis" do
#  version "2.0.0rc3"
#  action :install
#end

remote_file "redis" do
  path "/tmp/redis"
  source "http://redis.googlecode.com/files/redis-2.0.0-rc3.tar.gz"
  mode "0644"
  #checksum "08da002l" # A SHA256 (or portion thereof) of the file.
  action :install
end



directory "/data/redis" do
  owner 'redis'
  group 'redis'
  mode 0755
  recursive true
end

template "/etc/redis_util.conf" do
  owner 'root'
  group 'root'
  mode 0644
  source "redis.conf.erb"
  variables({
    :pidfile => '/var/run/redis_util.pid',
    :basedir => '/data/redis',
    :logfile => '/data/redis/redis.log',
    :port  => '6380',
    :loglevel => 'notice',
    :timeout => 300000,
  })
end

template "/data/monit.d/redis_util.monitrc" do
  owner 'root'
  group 'root'
  mode 0644
  source "redis.monitrc.erb"
  variables({
    :profile => '1',
    :configfile => '/etc/redis_util.conf',
    :pidfile => '/var/run/redis_util.pid',
    :logfile => '/data/redis',
    :port => '6380',
  })
end

execute "monit reload" do
  action :run
end
#end
