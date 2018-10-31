# Docker-nginx
[Dockerfile Link](https://github.com/index-js/docker-nginx.git)

# Features
1. Base Alpine, less RAM
2. No GPG verification
3. Remove "Server: nginx" and server_tokens

# Run
$ docker run -p 80:80 -d dotcloudid/nginx
`# Expose 80 443`

# Re-edit
`# Link to container layer`
$ docker exec -it some-nginx /bin/sh
`# So that, you can add_module or edit nginx.conf file`
