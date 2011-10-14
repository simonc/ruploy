# Ruploy

If you are managing Rack applications on your server and use RVM to work with
several versions of Ruby, that you use either Passenger-Standalone or Thin, Ruploy can help you.

Ruploy can generate init.d scripts to start/restart/stop your Rack applications like any services.

## Installation

    gem install ruploy

## Usage

Ruploy comes with two commands, `generate` and `deploy`.

### Generate

The `generate` command is the one in charge of generating init.d scripts. It
take one parameter which is the name of the script you want to create. All other
parameters will be given to the server script as options.

You can pass several options to `generate`. If an option is missing, ruploy will
enter interactive mode to ask you what it needs. If you want to use the default
values for the options you didn't provided, use the `--use-defaults` option.

* `--name NAME`           Name of your application (default: current directory name)
* `--directory PATH`      Root path of the application (default: current directory)
* `--address HOST`        Bind to HOST address (default: 127.0.0.1)
* `--port NUMBER`         Use the given port number (default: 3000)
* `--environment ENV`     Framework environment (default: production)
* `--user USERNAME`       User to run as. Ignored unless running as root (default: www-data)
* `--log-file FILENAME`   Where to write log messages (default: /var/log/rack-$PROCNAME-$PORT.log)
* `--pid-file FILENAME`   Where to store the PID file (default: /var/lock/rack-$PROCNAME-$PORT)
* `--server-type SERVER`  Server type, can be "thin" or "passenger" (default: thin)
* `--dependencies DEPS`   Dependencies of the init script (default: apache2)
* `--independent`         Print the generic code in the file instead of including it
* `--use-defaults`        Do not ask for missing informations and use default values

Here is an example of `ruploy generate` usage :

    $ ruploy generate my-scrip                 \
        --name              MyApp              \
        --directory         /path/to/my/app    \
        --address           0.0.0.0            \
        --port              4242               \
        --environment       development        \
        --user              some-user          \
        --log-file          /var/log/myapp.log \
        --pid-file          /var/lock/myapp    \
        --server-type       passenger          \
        --dependencies      "apache2 mysql"

We could do exactly the same thing with the interactive mode (hitting `<return>`
will  use the default value) :

    $ ruploy generate my-script
    name |ruploy| MyApp
    address |127.0.0.1| 0.0.0.0
    port |3000| 4242
    directory |/home/simonc/ruby/ruploy| /path/to/my/app
    environment |production| development
    log_file |/var/log/rack-$PROCNAME-$PORT.log| /var/log/myapp.log
    pid_file |/var/lock/rack-$PROCNAME-$PORT| /var/lock/myapp
    user |www-data| some-user
    dependencies |apache2| apache2 mysql
    server_type |thin| passenger
    options |--daemonize|

You may have notice the `options` question. You can pass here any additionnal
option, it will be passed to the server commande (passenger or thin). Any
argument on the command-line (except for the first one) will be added to this
list.

The two previous examples would generate the following init.d script :

    #! /bin/sh
    ### BEGIN INIT INFO
    # Provides:          myapp
    # Required-Start:    $remote_fs $syslog
    # Required-Stop:     $remote_fs $syslog
    # Should-Start:      apache2 mysql
    # Should-Stop:       apache2 mysql
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: Start/Stop MyApp
    # Description:       Manage the actions related to the passenger instance of MyApp
    #                    you can use start, stop, restart and status
    ### END INIT INFO
    
    NAME="MyApp"
    PROCNAME="myapp"
    
    DIRECTORY="/path/to/my/app"
    ADDRESS="0.0.0.0"
    PORT="4242"
    ENVIRONMENT="development"
    USER="some-user"
    LOGFILE="/var/log/myapp.log"
    PIDFILE="/var/lock/myapp"
    OPTIONS="--daemonize"
    SERVER="passenger"
    
    . "/Users/happynoff/.rvm/gems/ruby-1.9.2-p290@ruploy/gems/ruploy-0.0.1/data/ruploy-base.sh"

If you just want to change some variables but not all, use the `--use-defaults`
option :

    $ ruploy --name HelloWorld --directory /some/path --use-defaults

### Deploy

The `deploy` command links your script in `/etc/init.d` and then calls
`update-rc.d`.

It takes two parameters. The first one is the script name, the second is the
service name you want to use :

    $ ruploy deploy my-script service-name
    Deploying service-name... [OK]

## Contribution

Feel free to fork Ruploy and make pull requests !

Raise issues if you have any problem or feature requests.