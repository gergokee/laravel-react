# Devops Setup
The project is supposed to run on Node.js server which is managed by [pm2](https://pm2.keymetrics.io/) process manager.

## 1. pm2

### 1.1. Installation and setup 
**Important:** The service must be run as root and the pm2 daemon is recommended to run as user!

1. Run `npm install pm2@latest -g` as root user.
2. Run `pm2 startup` to add pm2 to add it to system startup as the user ( `${user}` = bamboo ) which runs pm2.
3. If you wish to change default setup, modify the startup script `/etc/systemd/system/pm2-${user}.service`
For example if you wish to change the logging directory, add the following line under `[Service]` block:
`Environment=PM2_LOG_FILE_PATH=/var/log/pm2/pm2.log`.\
**Important:** The log directory and everything in it must be owned by `${user}`!
4. Add pm2 to logrotate service: `/etc/logrotate.d/pm2-${user}`. See [section 3.3.](#33-pm2-logrotate-setup) for an example.
5. Create file `/home/${user}/.pm2/ecosystem.config.js` and add your site configuration to it. See [section 3.2.](#32-pm2-ecosystemconfigjs-setup) for an example.

### 1.2. Add a new site to pm2
1. `sudo` to `${user}`
2. Edit pm2 sites config file: `/home/${user}/.pm2/ecosystem.config.js`
3. Add necessary site related config. See [section 3.2.](#32-pm2-ecosystemconfigjs-setup) for an example.
4. Run `pm2 restart ecosystem.config.js` to restart pm2 with new config.
If you don't want to restart the whole pm2, i recommend you **only** restart the added site:
 `pm2 restart ecosystem.config.js --only ${appName}`.
5. Run `pm2 save` to make sure our config is saved if between server restarts.

ecosystem.config.js
* Main files location: `/home/${user}/.pm2`
* Logs
  * Main log: `/var/log/pm2/`
  * Site related logs: `/var/log/pm2/sites/`
* pm2 sites config file: `/home/${user}/.pm2/ecosystem.config.js`

### 1.3. pm2 file locations
* Main files location: `/home/${user}/.pm2`
* Logs
  * Main log: `/var/log/pm2/`
  * Site related logs: `/var/log/pm2/sites/`
* pm2 sites config file: `/home/${user}/.pm2/ecosystem.config.js`

## 2. Useful commands and their functionality
* Handle pm2 service: `service pm2-bamboo start/stop/restart` (easiest to run it as root)
* Handle pm2 daemons running by `${user}`: `pm2 start/stop/restart/reload/delete ecosystem.config.js`
* Handle only one pm2 daemon running by `${user}`: `pm2 start/stop/restart/reload/delete ecosystem.config.js --only ${appName}`
* Get apps running by `${user}` `pm2 status`
* Get summary of an app running by `${user}` `pm2 show [name|id]`
* Monitor CPU and memory usage by apps running by `${user}` `pm2 monitor`
* Monitor CPU and memory usage by apps running by `${user}` `pm2 monitor`

## 3. Sample example of config files

### 3.1. Apache virtualhost setup
```
<VirtualHost *:80>
    ServerAdmin webmaster@example.org
    DocumentRoot /var/www/example.org/public
    ServerName example.org
    ErrorLog /var/log/httpd/example.org-error.log
    CustomLog /var/log/httpd/example.org-access.log common

    ProxyRequests Off
    ProxyPreserveHost On
    ProxyVia Full

    <Proxy *>
        Require all granted
    </Proxy>

    ProxyPass / http://127.0.0.1:3000/
    ProxyPassReverse / http://127.0.0.1:3000/
</VirtualHost>
```

### 3.2. pm2 `ecosystem.config.js` setup
```
module.exports = {
    apps : [
        {
            name            : "`${appName}`",
            script          : "/bin/npx",
            args            : "next start -p 3000",
            cwd             : "/var/www/example.org",
            exec_mode       : "cluster_mode",
            instances       : 1,
            error           : "/var/log/pm2/sites/example.org/error.log",
            output          : "/var/log/pm2/sites/example.org/out.log",
        }
    ]
}
```

### 3.3. pm2 logrotate setup
```
/var/log/pm2/pm2.log /var/log/pm2/sites/*/*.log {
    rotate 12
    daily
    missingok
    notifempty
    compress
    delaycompress
    copytruncate
    dateext
  	dateformat -%Y-%m-%d
	create 0640 `${user}` `${user}`
}
```
