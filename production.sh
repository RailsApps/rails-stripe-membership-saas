#!/bin/bash

if [ $# -eq 0 ]
then
	echo "production.sh [options] start|stop|restart|permissions|rebuild|migrate|resque"
elif [ $1 == 'start' ]; then
	echo "Starting..."
	bundle exec unicorn -c ./config/unicorn.rb -E production -D
	echo "Done."
elif [ $1 == "stop" ]; then
	if [ -f 'tmp/unicorn.pid' ]; then
		echo "Stopping..."
		kill `cat tmp/unicorn.pid`
	else
		echo 'Server not running.'
	fi
elif [ $1 == 'restart' ]; then
	echo "Stopping..."
	kill `cat tmp/unicorn.pid`
	sleep 1
	echo "Starting..."
	bundle exec unicorn -c ./config/unicorn.rb -E production -D
	echo "Done."
elif [ $1 == 'permissions' ]; then
	echo "Setting Permissions..."
	find . -type d -exec chmod 755 {} \;
    find . -type f -exec chmod 644 {} \;
    chmod 755 production.sh
	echo "Done."
elif [ $1 == 'rebuild' ]; then
        echo "Rebuilding Database..."
        # psql rails-saas -U postgres -c "drop schema public cascade; create schema public; ALTER SCHEMA public OWNER TO rails-saas_development;"
        export RAILS_ENV=production 
	    rake db:drop
	    rake db:create
	    rake db:migrate
	    rake db:seed
        echo "Done."
elif [ $1 == 'migrate' ]; then
        echo "Migrating Database..."
        export RAILS_ENV=production
        rake db:migrate
        echo "Done."
elif [ $1 == 'resque' ]; then
	screen -dmS insert bundle exec rake resque:workers COUNT=1 QUEUE='*' RAILS_ENV=production VERBOSE=1 PIDFILE=./tmp/resque.pid INTERVAL=5
fi
