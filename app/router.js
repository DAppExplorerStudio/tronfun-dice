'use strict';

/**
 * @param {Egg.Application} app - egg application
 */
module.exports = app => {
  const { router, controller } = app;
  const home = controller.home;

  router.get('/', home.index);
  router.get('/dice', home.index);

};
