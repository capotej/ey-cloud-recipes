#
# Cookbook Name:: redis
# Recipe:: default
#

if ['solo', 'db'].include?(node[:instance_role])


remote_file "/tmp/redis2rc4.tar.gz" do
  source "http://redis.googlecode.com/files/redis-2.0.0-rc4.tar.gz"
  mode "0644"
  action :create_if_missing
end

Chef::Log.info("File downloaded")

bash "untar-redis" do
  code "(cd /tmp; tar zxvf /tmp/redis2rc4.tar.gz)"
end

bash "compile-redis" do
  code "(cd /tmp/redis-2.0.0-rc4; make)"
end

files = %w{ redis-server redis-benchmark redis-cli redis-check-dump redis-check-aof }
files.each do |f|
  bash "install-#{f}" do
    code "mv /tmp/redis-2.0.0-rc4/#{f} /usr/bin/#{f}"
  end
end

directory "/data/redis" do
  owner node[:owner_name]
  group node[:owner_name]
  mode 0755
  recursive true
end

template "/etc/redis/redis.conf" do
  owner 'root'
  group 'root'
  mode 0644
  source "redis.conf.erb"
  variables({
              :pidfile => '/var/run/redis_util.pid',
              :basedir => '/data/redis/',
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
              :logfile => '/data/redis/',
              :port => '6380',
  })
end

execute "monit reload" do
  action :run
end

