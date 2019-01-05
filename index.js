'use strict';

const { startCluster } = require('egg');

startCluster({
  baseDir: __dirname,
  port: process.env.EGG_SERVER_ENV !== 'dev' ? 7002 : 7001,
});






