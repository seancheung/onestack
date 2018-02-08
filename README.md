# onestack
A docker image with node, mysql, redis, mongodb, elk, nginx, phpmyadmin, redis-commander, mongo-express

# Run

```bash
docker run -d -p 3306:3306 -p 6379:6379 -p 9200:9200 -p 27017:27017 -p 8080:8080 -p 8081:8081 -p 8082:8082 -p 8083:8083 -e "MYSQL_ROOT_PASSWORD=password" -e "MYSQL_DATABASE=database1;database2" -e "KIBANA_AUTH=username:password" seancheung/onestack:staging
```