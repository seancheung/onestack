# onestack
A docker image with node, mysql, redis, mongodb and nginx, controlled by supervisor.


# Run

```bash
docker run -d -p 3306:3306 -p 6379:6379 -p 27017:27017 -e "MYSQL_ROOT_PASSWORD=password" -e "MYSQL_DATABASE=database1;database2" seancheung/onestack:slim
```