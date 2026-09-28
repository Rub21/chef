# Domain where this tile server is reachable (needs an A record to this host)
default[:gps_tile_dev][:domain] = "gps-tile.rub21.com"
default[:gps_tile_dev][:email] = "ruben@rub21.com"

# openstreetmap-website instance to fetch traces from
default[:gps_tile_dev][:site_url] = "https://gpx-tracks.rub21.com"

# Traces with an id lower than this are never fetched
default[:gps_tile_dev][:min_trace] = 0


# Fork of openstreetmap/gpx-updater that reads GPX_SITE and GPX_MIN_TRACE
default[:gps_tile_dev][:updater_repo] = "https://github.com/Rub21/gpx-updater.git"
default[:gps_tile_dev][:updater_revision] = "dev"
