/**
 * pm2 configuration for the QuickInfo API.
 *
 *   pm2 start ecosystem.config.cjs
 *   pm2 save && pm2 startup        # survive a reboot
 *
 * ONE instance: the rate limiter keeps its counters in process memory, so
 * cluster mode would give every worker its own limit and multiply it.
 *
 * .env is read by the app itself (dotenv), so no credentials live here.
 */
module.exports = {
  apps: [
    {
      name: 'quickinfo-api',
      script: 'src/app.js',
      cwd: __dirname,
      instances: 1,
      exec_mode: 'fork',

      autorestart: true,
      // Stop retrying after ten quick failures so the real boot error stays readable.
      max_restarts: 10,
      restart_delay: 4000,
      min_uptime: '30s',
      max_memory_restart: '300M',

      env: {
        NODE_ENV: 'production',
      },

      time: true,
      merge_logs: true,
      out_file: 'logs/out.log',
      error_file: 'logs/error.log',
    },
  ],
};
