FROM nginx

RUN apt-get update && apt-get install -y ruby

COPY nginx.conf /etc/nginx/nginx.conf
RUN rm /etc/nginx/conf.d/default.conf

COPY conf/old.conf /etc/nginx/conf.d/old.conf

VOLUME /data
# expect to be mounted: /www

COPY docker-entrypoint.sh /entrypoint.sh
CMD /entrypoint.sh
