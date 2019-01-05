'use strict';

const path = require('path');
const fs = require('fs');

module.exports = appInfo => ({
  tokenRadio: 2000,
  tokenAddress: '0xf9527dcA3b70E72600cE884E605616e3073c4445',
  keys: 'system_pixel',
  notfound: {
    pageUrl: '/',
  },
  static: {
    maxAge: 31536000,
    gzip: true,
  },
  siteFile: {
    '/favicon.ico': fs.readFileSync(path.join(appInfo.baseDir, 'app/assets/favicon.ico'))
  },
  assets: {
    publicPath: '/dist/',
  },
  middleware: [
    // 'loginCheck',
  ],
  view: {
    defaultViewEngine: 'nunjucks',
    // root: path.join(appInfo.baseDir, 'app/view/'),
    mapping: {
      '.nj': 'nunjucks',
    },
  },
  session: {
    key: 'key',
    maxAge: 2 * 3600 * 1000, // 2 hours
    httpOnly: true,
    encrypt: true,
  },

  security: {
    domainWhiteList: [ '' ],
    csrf: {
      queryName: '', // 通过 query 传递 CSRF token 的默认字段为 _csrf
      bodyName: '', // 通过 body 传递 CSRF token 的默认字段为 _csrf
    },
  },
});
