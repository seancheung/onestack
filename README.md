# onestack
A docker image with node, mysql, redis, mongodb, nginx and elk, controlled by supervisor.


# Run

```bash
docker run -d -p 3306:3306 -p 6379:6379 -p 27017:27017 -p 9200:9200 -p 5000:5000/udp -p 80:80 -e "MYSQL_ROOT_PASSWORD=password" -e "MYSQL_DATABASE=database1;database2" seancheung/onestack:elk
```