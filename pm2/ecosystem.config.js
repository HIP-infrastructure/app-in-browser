const path = require("path");
const dotenv = require("dotenv");
const { execSync } = require("child_process");

const which = cmd => execSync(`which ${cmd}`).toString().trimEnd();
const relative = (...dir) => path.resolve(__dirname, ...dir);

const env = dotenv.config({ path: relative("../backend/backend.env") }).parsed;

const caddy = which("caddy");
const gunicorn = which("gunicorn");

module.exports = {
  apps : [{
    script: caddy,
    args: 'run',
    cwd: relative('../caddy'),
    watch: relative('../caddy'),
    env
  },
  {
    script: gunicorn,
    args: '--workers 40 --timeout 120 --bind 127.0.0.1:8060 --pythonpath backend backend:app',
    cwd: relative('..'),
    watch: relative('../backend'),
    interpreter: 'python3'	  
  }]
};
