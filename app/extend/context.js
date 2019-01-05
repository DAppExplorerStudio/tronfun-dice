'use strict';
const moment = require('moment');
const md5 = require('md5');

module.exports = {
  /*
   * 透传返回
   */
  pass(data) {
    this.body = data;
    return this.body;
  },
  /*
   * {
     status: 业务状态码, 默认200表示成功
     message: 业务处理结果信息, 默认 OK，与 message 对应
     data: {} 附带信息
   }
   * 针对 http 状态码，默认使用200，catch 的错误 500，其他业务需要再自行设置
   */

  done(err = null, data = {}) {
    const body = {
      status: 200,
      message: 'OK',
    };

    if (err) {
      const e = this.capture(err);
      Object.assign(body, {
        status: e.err_code,
        message: e.err_msg,
      });
    } else {
      Object.assign(body, { data });
    }

    this.body = body;
  },

  capture(err) {
    if (err && err.err_code !== undefined) {
      return err;
    }

    const body = {};

    if (err) {
      Object.assign(body, {
        err_code: err.statusCode || err.err_code || err.status || 500,
        err_msg: err.message || err.err_msg || '-',
      });
    }

    return body;
  },
};
