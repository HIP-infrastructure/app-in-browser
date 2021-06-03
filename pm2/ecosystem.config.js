const path = require("path");

const relative = (...dir) => path.resolve(__dirname, ...dir)

module.exports = {
  apps : [{
    script: '/usr/bin/caddy',
    args: 'run',
    cwd: relative('../caddy'),
    watch: relative('../caddy')
  },
  {
    script: '/usr/local/bin/gunicorn',
    args: '--workers 2 --timeout 120 --bind 127.0.0.1:8060 --pythonpath backend backend:app',
    cwd: relative('..'),
    watch: relative('../backend'),
    interpreter: 'python3'	  
  }]
};
