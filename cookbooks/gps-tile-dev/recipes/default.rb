#
# Cookbook:: gps-tile-dev
# Recipe:: default
#
# Wraps the gps-tile cookbook for a standalone server:
# - Let's Encrypt certificate for our own domain
# - Web viewer pointing at our own tile endpoint
#

include_recipe "gps-tile"

domain = node[:gps_tile_dev][:domain]
live_dir = "/etc/letsencrypt/live/#{domain}"

package "certbot"

# Apache holds port 80 and redirects acme-challenge to OSM, so use the
# standalone plugin and stop apache for the few seconds the challenge takes.
execute "certbot-#{domain}" do
  command "certbot certonly --standalone --non-interactive --agree-tos " \
          "-m #{node[:gps_tile_dev][:email]} -d #{domain} " \
          "--pre-hook 'systemctl stop apache2' --post-hook 'systemctl start apache2'"
  creates "#{live_dir}/fullchain.pem"
end

# gps-tile creates a self-signed cert at these paths and apache.erb reads them.
# Overwrite with the Let's Encrypt one. The ssl_certificate resource only
# creates the files when missing, so it does not put the self-signed one back.
file "/etc/ssl/certs/gps-tile.openstreetmap.org.pem" do
  content lazy { File.read("#{live_dir}/fullchain.pem") }
  owner "root"
  group "root"
  mode "444"
  notifies :reload, "service[apache2]"
end

file "/etc/ssl/private/gps-tile.openstreetmap.org.key" do
  content lazy { File.read("#{live_dir}/privkey.pem") }
  owner "root"
  group "ssl-cert"
  mode "440"
  notifies :reload, "service[apache2]"
end

# Viewer requests tiles from this server instead of gps-tile.openstreetmap.org
template "/srv/gps-tile.openstreetmap.org/html/map.js" do
  source "map.js.erb"
  owner "gpstile"
  group "gpstile"
  mode "644"
  variables :domain => domain
end
