use strict;

die if $ENV{'PROXY_DOMAIN_1'} eq '';

my $header = <<'EOF';
user www-data;
worker_processes 4;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format ltsv "time:$time_local"
                    "\thost:$remote_addr"
                    "\tforwardedfor:$http_x_forwarded_for"
                    "\treqest:$request"
                    "\tstatus:$status"
                    "\tsize:$body_bytes_sent"
                    "\treferer:$http_referer"
                    "\tagent:$http_user_agent"
                    "\treqtime:$request_time"
                    "\tcache:$upstream_http_x_cache"
                    "\tupsttime:$upstream_response_time"
                    "\truntime:$upstream_http_x_runtime"
                    "\tvhost:$host";

    include /etc/nginx/mime.types;
    include /etc/nginx/conf.d/*.conf;

    access_log /var/log/nginx/access.log ltsv;
    error_log /var/log/nginx/error.log;

    # For ELB
    set_real_ip_from   10.0.0.0/8;
    set_real_ip_from   12.0.0.0/8;
    real_ip_header     X-Forwarded-For;

    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Authorization $http_authorization;
    server_tokens off;
EOF

my $body = <<"EOS";
    upstream %s {
        server %s:%s;
    }
    
    server{
        listen 80;
        server_name %s;
        location / {
            proxy_pass http://%s;
        }

        location = /health.html {
            empty_gif;
            access_log off;
            break;
        }
    }
EOS

my $footer = <<"EOS";

    server{
        listen 80;

        location = /health.html {
            empty_gif;
            access_log off;
            break;
        }
    }

}

daemon off;
EOS

my $num = 1;
my $target = 'PROXY_DOMAIN_'.$num;
my $filename = 'nginx.conf';
open(my $fh, '>', $filename) or die "Could not open file";
print $fh $header;
while($ENV{$target} ne ''){
    printf($fh $body."\n", 
           $ENV{'PROXY_NAME_'.$num}, 
           $ENV{'PROXY_HOST_'.$num}, 
           $ENV{'PROXY_PORT_'.$num}, 
           $ENV{'PROXY_DOMAIN_'.$num}, 
           $ENV{'PROXY_NAME_'.$num});
    
    $num += 1;
    $target = 'PROXY_DOMAIN_'.$num;
}
print $fh $footer;
close $fh;



