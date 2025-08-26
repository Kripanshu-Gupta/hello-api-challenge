module.exports = {
  apps: [
    {
      name: "hello-api",
      script: "index.js",   // your entry file
      instances: "max",     // run one per CPU core
      exec_mode: "cluster",
      env: {
        NODE_ENV: "production",
        PORT: 80
      }
    }
  ]
};
