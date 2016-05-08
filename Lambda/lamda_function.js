var https = require('https');
var username = '6ba06866-1891-4145-be25-331f9c8f3e9c';
var password = '';
var flickerId = '142479455@N03';
var loc = '';

var getUrlForPic = function (farmId, serverId, id, secret) {
   
    var url = 'https://farm'+farmId+'.staticflickr.com/'+serverId+'/'+id+'_'+secret+'.jpg';
    return url;
};
var getPics = function (time) {
    var options = {
        host: 'api.flickr.com',
        port: 443,
        path: '/services/rest/?method=flickr.photos.search&api_key=38e7675f8a53235fd4886b57093e1dcf&user_id=142479455%40N03&tags='+loc.split(" ").join("%2C")+'%2C+'+time+'&tag_mode=all&format=json&nojsoncallback=1',
        method: 'GET',
    };
    
    console.log("Getting photos for "+ loc+ time);
    var req = https.request(options, function(response){
            var str = '';
            response.on('data', function (chunk) {
                str += chunk;
             });
  
            response.on('end', function () {
                var obj = JSON.parse(str);
                var photoURLArray= [];
                var photos = obj.photos.photo;
                console.log(photos);
                for (var i = 0; i < photos.length ; i++) {
                    var p = photos[i];
                    photoURLArray.push(getUrlForPic(p.farm,p.server,p.id,p.secret));
                    console.log("P arr "+ photoURLArray);
                }
                c.done(null,{photos:photoURLArray});
            });
    }).end();
};

var logResponse = function(response, context) {
    var str = '';
  response.on('data', function (chunk) {
    str += chunk;
  });
  
  response.on('end', function () {
    var obj = JSON.parse(str);
    getPics("day");
  });
};

exports.handler = function(event, context) {
c = context;
loc = event.location;
var options = {
  host: 'gateway.watsonplatform.net',
  port: 443,
  path: '/natural-language-classifier/api/v1/classifiers/3a84dfx64-nlc-3902/classify?text='+ event.time,
  method: 'GET',
  headers: {
     'Authorization': 'Basic ' + new Buffer(username + ':' + password).toString('base64')
   }
};

console.log(event);
    var req = https.request(options, function(res){
        logResponse(res, context);
    });

    req.end();
};