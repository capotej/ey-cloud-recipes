#
# Cookbook Name:: redis
# Recipe:: default
#

if ['solo', 'db_master'].include?(node[:instance_role])


remote_file "/tmp/redis-2.0.1.tar.gz" do
  source "http://redis.googlecode.com/files/redis-2.0.1.tar.gz"
  mode "0644"
  action :create_if_missing
end

Chef::Log.info("File downloaded")

bash "untar-redis" do
  code "(cd /tmp; tar zxvf /tmp/redis-2.0.1.tar.gz)"
end

bash "compile-redis" do
  code "(cd /tmp/redis-2.0.1; make)"
end

files = %w{ redis-server redis-benchmark redis-cli redis-check-dump redis-check-aof }
files.each do |f|
  bash "install-#{f}" do
    code "mv /tmp/redis-2.0.1/#{f} /usr/local/bin/#{f}"
  end
end

directory "/db/redis2" do
  owner node[:owner_name]
  group node[:owner_name]
  mode 0755
  recursive true
end

template "/etc/redis2.conf" do
  owner 'root'
  group 'root'
  mode 0644
  source "redis.conf.erb"
  variables({
              :pidfile => '/var/run/redis_util.pid',
              :basedir => '/db/redis2/',
              :logfile => '/db/redis2/redis.log',
              :port  => '7777',
              :loglevel => 'notice',
              :timeout => 300000,
  }) 
end

template "/data/monit.d/redis.monitrc" do
  owner 'root'
  group 'root'
  mode 0644
  source "redis.monitrc.erb"
  variables({
              :profile => '1',
              :configfile => '/etc/redis2.conf',
              :pidfile => '/var/run/redis_util.pid',
              :logfile => '/db/redis2/',
              :port => '7777',
  })
end

execute "monit reload" do
  action :run
end

end
