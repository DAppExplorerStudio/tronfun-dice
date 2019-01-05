'use strict';

const lodash = require('lodash');
const CACHE = Symbol('Application#cache');



module.exports = {
  /*
   * worker级别的cache
   */
  get cache() {
    return this[CACHE] || {
      loginUsers: [],
    };
  },

  get randomOrderNumbers() {
    return randomNumbers;
  },

  /*
   * 将登录了的用户id保存起来
   * TODO: 当前是按FIFO淘汰，后续考虑LRU
   */
  cacheLoginUser(uid) {
    const { loginUsers } = this.cache;
    loginUsers.push(uid);

    // 只缓存1000个，多了去掉头部的
    if (loginUsers.length > 1000) {
      loginUsers.splice(0, 1);
    }

    this.cache.loginUsers = loginUsers;
  },

  /*
   * 对this.app.curl的业务外层封装，原因
   * 1. 希望通过业务自己配置timeout来设置curl的超时时间，egg本身不支持配置curl
   * 2. curl后的返回值统一返回data字段，其它地方使用不用再解一层，之前很容易出错和难理解
   * @params {string} url
   * @params {object} options
   * @return {object} data
   */
  async fetch(oUrl, options = {}) {
    // 从config获取可配置项作为默认options
    const { timeout } = this.config.fetch;
    const defaultOptions = {
      dataType: 'json',
      contentType: 'json',
      timeout,
      method: 'GET',
    };

    const url = this.packUrlQuery(oUrl, options.query);
    // 合并默认options和自定义options
    const mergeOptions = Object.assign({}, defaultOptions, options);

    // 直接返回this.curl返回的data字段
    return (await this.curl(url, mergeOptions)).data;
  },

  /*
   * 拼接url参数
   */
  packUrlQuery(url, query = {}) {
    // 去掉 undefined
    const p = Object.keys(query)
      .filter(key => query[key] !== undefined)
      .map(key => {
        let value = query[key];
        if (lodash.isArray(value)) {
          value = value.join(',');
        }

        return `${key}=${value}`;
      })
      .join('&');
    return url + (url.indexOf('?') > -1 ? '&' : '?') + p;
  },
};
