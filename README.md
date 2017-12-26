# onestack
A docker image with node, mysql, redis, mongodb, elk and nginx

# Run

```bash
docker run -d -p 80:80 -p 3306:3306 -p 5601:5601 -p 6379:6379 -p 9200:9200 -p 27017:27017 -e "MYSQL_ROOT_PASSWORD=password" -e "MYSQL_DATABASE=database1;database2" -e "KIBANA_AUTH=username:password" seancheung/onestack:latest
```