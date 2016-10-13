var request = require('request');
var $ = require("cheerio");
var dateFormat = require('dateformat');
var util = require("util");

// 信息最后更新日期
var day = new Date();
day.setDate(day.getDate() - 1);
var today = dateFormat(day, "yyyy-mm-dd");

var fs = require("fs");
var store_base_info = util.format("store_base_info-%s.txt", today);
var store_credit_info = util.format("store_credit_info-%s.txt", today);
var goods_base_info = util.format("goods_base_info-%s.txt", today);
var goods_sale_info = util.format("goods_sale_info-%s.txt", today);

function writeRecord(item) {
    var detail_url = item["detail_url"]
    // 商品ID
    var goods_id = item["nid"]
    // 商品名
    var goods_name = item["raw_title"]

    // 店铺ID
    var store_id = item["user_id"]
    // 店铺名
    var store_name = item["nick"]
    // class_one, class_two, class_three, date_added
    fs.appendFileSync(goods_base_info, util.format("%s\0%s\0%s\0%s\0%s\0%s\0%s\0%s\n", goods_id, goods_name, store_id, null, null, null, today, null))

    // 1 天猫， 0 淘宝
    var is_tmall = item["shopcard"]["isTmall"] ? 1 : 0
    // 所在地区
    var location_city = item["item_loc"]
    var store_url = item["shopLink"]
    fs.appendFileSync(store_base_info, util.format("%s\0%s\0%s\0%s\n", store_id, store_name, is_tmall, location_city));

    // 卖家信用
    var credit_as_seller = item["shopcard"]["sellerCredit"] || 0
    // 宝贝与描述相符
    var score_goods_desc = item["shopcard"]["description"][0]
    // 卖家的服务态度
    var score_service_manner = item["shopcard"]["service"][0]
    // 卖家发货的速度
    var score_express_speed = item["shopcard"]["delivery"][0]
    fs.appendFileSync(store_credit_info, util.format("%s\0%s\0%s\0%s\0%s\0%s\n", store_id, credit_as_seller, score_goods_desc, score_service_manner, score_express_speed, today));

    var price = parseInt(item["view_price"])
    var express_price = parseInt(item["view_fee"])
    var sales = parseInt(item["view_sales"])
    fs.appendFileSync(goods_sale_info, util.format("%s\0%s\0%s\0%s\n", goods_id, today, price + express_price, sales));

}

function searchKey(keyStr, page, next) {

    // 一级分类，二级分类，三级分类
    var class_one, class_two, class_three

    var url = "http://s.taobao.com/search?q=" + encodeURI/*encodeURIComponent*/(keyStr);
    if (page && page > 0) {
        url += "&s=" + page * 44
    }
    console.log(url);

    /* 浏览器打开访问一个地址，然后拷贝Request Header */
    var header = {
        "accept": "*/*",
        "accept-encoding": "gzip, deflate, sdch",
        "accept-language": "zh-CN,zh;q=0.8,en;q=0.6,zh-TW;q=0.4",
        "referer": "http://www.taobao.com",
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36"
    }

    var options = {
        url: url,
        headers: header,
        method: 'GET',
        gzip: true
    };
    var callback = function (error, response, body) {
        if (!error && response.statusCode == 200) {
            // script中的函数变量定义
            var g_page_config;

            function g_srp_loadCss() {
            };
            function g_srp_init() {
            };
            var window = {givenByFE: {}}

            // 获取数据
            var configFilter = function (i, ele) {
                return $(ele).html().indexOf("g_page_config") > -1;
            };
            var config = $(body).find("script").filter(configFilter).html();
            eval(config);

            var cfg = g_page_config
            // try-catch所有的错误，单记录单个页面的错误不影响后面的数据获取.
            try {
                var items = cfg['mods']['itemlist']['data']['auctions']
                for (var i in items) {
                    try {
                        writeRecord(items[i]);
                    } catch (err) {
                        console.error(err);
                    }
                }
            } catch (err) {
                console.error(err);
            }

            next && next();
        }
    };

    request(options, callback);

}

function buildSearch(query, callback) {
    var latestCallback = callback;

    function search(query, page, callback) {
        return function () {
            function callbackWithLittleSleep() {
                setTimeout(callback, 1000);
            }

            searchKey(query, page, callbackWithLittleSleep);
        };
    }

    // 构造递归查询
    for (var i = 15 - 1; i > 0 - 1; i--)
        latestCallback = search(query, i, latestCallback);

    return latestCallback;
}

// 从淘宝页面的二级分类拷贝
var queries = ["苹果6s plus", "苹果6S", "苹果6", "苹果6 plus", "荣耀", "苹果5s", "二手iphone", "二手回收", "三星", "三星s7", "三星s6", "小米", "小米5", "红米note3", "红米3", "小米4s", "华为", "华为mate8", "魅族", "乐视", "乐视1s", "vivo Xplay5", "oppo",];

var mainCallback = function () {
    process.exit(0);
};
for (var i = queries.length - 1; i > -1; i--) {
    mainCallback = buildSearch(queries[i], mainCallback);
}

var start = mainCallback;
start();
