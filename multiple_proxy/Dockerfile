FROM dockerfile/nginx

WORKDIR /root
ADD ./files/generate_nginx_conf.pl /root/generate_nginx_conf.pl
CMD perl ./generate_nginx_conf.pl && nginx -c /root/nginx.conf
