'use strict';

const Controller = require('egg').Controller;
const fs = require('fs');
const path = require('path');
const pako = require('pako');
const lodash = require('lodash')
const dayjs = require('dayjs')

class HomeController extends Controller {
  async index() {
    this.ctx.set('Access-Control-Allow-Origin', '*');
    await this.ctx.render('index.nj', {
      ctx: {}
    });
  }

}

module.exports = HomeController;
