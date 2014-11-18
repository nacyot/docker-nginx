FROM dockerfile/nginx

RUN \
  touch /var/log/nginx/access.log /var/log/nginx/error.log &&\
  ln -sf /dev/stdout /var/log/nginx/access.log &&\
  ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /root
ADD ./files/*.sh /root/
ADD ./files/generate_nginx_conf.pl /root/generate_nginx_conf.pl
RUN chmod +x /root/*.sh

CMD ./setup_configs.sh && ./run.sh
