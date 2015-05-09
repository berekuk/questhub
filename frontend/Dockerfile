FROM nginx

RUN apt-get update && apt-get install -y ruby

COPY nginx.conf /etc/nginx/nginx.conf
RUN rm /etc/nginx/conf.d/default.conf

COPY . /frontend-conf

VOLUME /data
# expect to be mounted: /www

CMD /frontend-conf/run.sh
