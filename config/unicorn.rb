worker_processes 4
timeout 30
listen 3000
pid "./tmp/unicorn.pid"
preload_app true