# Docker-nginx

[Dockerfile Is Here.](https://github.com/index-js/docker-nginx.git)
You can edit both nginx version and timezone.

# Features
1. Base Alpine, less RAM
2. No GPG verification
3. Remove "Server: nginx" and server_tokens
4. Add timezone
5. Add crontab

# Run
Expose 80 443
```
$ docker run --name some-nginx -p 80:80 -v /data/backup/nginx:/etc/nginx -d dotcloudid/nginx
```

# Re-edit
Link to container layer, and you can add_module or edit nginx.conf file
```
$ docker exec -it some-nginx sh
```

# Reference
- [Docker Practice](https://docs.docker.com/develop/develop-images/dockerfile_best-practices)
- [Nginx Official Dockerfile](https://github.com/nginxinc/docker-nginx/tree/master/mainline/alpine)
- [Author](http://yanglin.me)
