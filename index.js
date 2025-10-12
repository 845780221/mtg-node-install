'use strict'
const {MTProtoProxy} = require('./mtprotoproxy.js');
const net = require('net');
let ad_tag='0b28e29e1ac4d675001d3a50a3ecdede'

// 捕获未处理异常，避免 ECONNRESET 导致进程退出
process.on('uncaughtException', (err) => {
    if (err.code === 'ECONNRESET') {
        console.log('连接被重置:', err.message);
    } else {
        console.error('未捕获异常:', err);
    }
});
process.on('unhandledRejection', (reason, promise) => {});

let telegram=new MTProtoProxy({
    secrets:['ee00000000000000000000000000000000'],
    async enter(options)
    {
      //  console.log('New client:',options);
        return ad_tag;
    },
    leave(options)
    {
        //console.log('Client left:',options);
    },
    ready()
    {
        console.log('ready')
        let proxy=net.createServer(telegram.proxy);
        proxy.on('error',function(err){console.log(err)})
        proxy.listen(443,'0.0.0.0');
    }
});