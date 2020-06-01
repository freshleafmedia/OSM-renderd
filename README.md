# Open Street Map Render Daemon

## Build

```
docker build .
```

## Run

```
docker run -d -p 7653:7653 -v /path/to/map/cache:/tileCache freshleafmedia/osm-renderd
```

### Environment Variables

There are a couple of environment variables used to configure where the Postgis DB is and how to authenticate

- `DB_HOSTNAME` (default is `localhost`)
- `DB_PORT` (default is 5432)
- `DB_USER` (default is `renderer`)
- `DB_PASSWORD`

### Volumes

- `/tileCache` The tile cache
- `/var/run/renderd/renderd.stats` The daemon statistics file
