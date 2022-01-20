# Devops Setup
The project is supposed to run on Node.js server which is managed by [pm2](https://pm2.keymetrics.io/) process manager.

## 1. pm2

### 1.1. Installation and setup 
**Important:** The service must be run as root and the pm2 daemon is recommended to run as user. 

1. Run `npm install pm2@latest -g` as root user.
2. Run `pm2 startup` to add pm2 to add it to system startup as the user ( ${user} = bamboo ) who runs pm2
3. If you wish to change default setup, modify the startup script `/etc/systemd/system/pm2-${user}.service`
For example if you wish to change the logging directory, add the following line under `[Service]` block:
`Environment=PM2_LOG_FILE_PATH=/var/log/pm2/pm2.log`
4. Create file `/home/${user}/.pm2/ecosystem.config.js` and add your site configuration to it. See 

### 1.2. pm2 file locations
* Main files location: `/home/${user}/.pm2`
* Logs
  * Main log: `/var/log/pm2/`
  * Site related logs: `/var/log/pm2/sites/`
* pm2 sites config file: `/home/${user}/.pm2/ecosystem.config.js`

## 2. Useful commands and their functionality 


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
            name            : "example.org",
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
