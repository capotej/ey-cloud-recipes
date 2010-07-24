#
# Cookbook Name:: redis
# Recipe:: default
#

if node[:instance_role] == 'db_master'

remote_file "/tmp/redis2.tar.gz" do
  source "http://redis.googlecode.com/files/redis-2.0.0-rc3.tar.gz"
  mode "0644"
  action :create_if_missing
end

Chef::Log.info("File downloaded")

bash "untar-redis" do
  code "(cd /tmp; tar zxvf /tmp/redis2.tar.gz)"
end

bash "compile-redis" do
  code "(cd /tmp/redis2; make)"
end


bash "install-redis" do
  code "mv /tmp/redis2/bin/redis-server /usr/local/bin/redis-server"
  code "mv /tmp/redis2/bin/redis-cli /usr/local/bin/redis-cli"
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
end
