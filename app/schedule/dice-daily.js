exports.schedule = {
  type: 'worker', // worker 类型的定时任务在到执行时间时只会有一个进程执行
  cron: '0 0 0 * * *', // 每天的 00:00:00 执行
  // immediate: true
  // cron: '* * * * * *',
};

const fs = require('fs')
const path = require('path')

const TronWeb = require('tronweb')
const HttpProvider = TronWeb.providers.HttpProvider

const fullNode = new HttpProvider('https://api.trongrid.io');
const solidityNode = new HttpProvider('https://api.trongrid.io');
const eventServer = 'https://api.trongrid.io';

const privateKey = '';
const artifacts = JSON.parse(fs.readFileSync(path.join(__dirname, './../../build/contracts/Dice.json'), 'utf-8'));

const tronWeb = new TronWeb(
  fullNode,
  solidityNode,
  eventServer,
  privateKey
);

const diceContract = tronWeb.contract(artifacts.abi, artifacts['networks']['*'].address);

// 计算每日榜单
exports.task = async function (ctx) {
  async function getPidTrx(pid) {
    let addr = ''
    try {
      addr = await diceContract.getPAddrByPID(pid).call()
      addr = diceContract.tronWeb.address.fromHex(addr)
    } catch (e) {
      console.log(2, e)
    }
    let trx = 0
    try {
      trx = await diceContract.totalInOfByPAddr(addr).call()
      trx = parseFloat(diceContract.tronWeb.fromSun(trx.toNumber()))
    } catch (e) {
      console.log(3, e)
    }

    return {
      addr,
      trx
    }
  }

  const rank = {}
  try {
    console.log('daily rank start')
    let idIndex = await diceContract.pIDIndex_().call()
    idIndex = idIndex.toNumber()
    // 最新榜单
    let i = 0
    for (let x = 1; x <= Math.ceil(idIndex / 40); x++) {
      const reqArr = []
      for (; i < 40 * x; i++) {
        if (i > idIndex) {
          break
        }
        reqArr.push(getPidTrx(i))
      }
      const ret = await Promise.all(reqArr)
      ret.forEach(item => {
        rank[item.addr] = item.trx
      })
      // console.log(x, 'over')
    }

    // 历史榜单数据 写入文件
    fs.writeFileSync(path.join(__dirname, '../../tronserver/users_dice_last.txt'), JSON.stringify(rank))
    console.log('daily rank over')
  } catch (e) {
    console.log(1, e)
  }
}
