
var grant = require('grant').azure({
  config: require('./config.json'), session: {secret: 'grant'}
})

module.exports = async (context, req) => {
  var {redirect, response} = await grant(req)
  return redirect || {
    status: 200,
    headers: {'content-type': 'text/plain'},
    body: JSON.stringify(response, null, 2)
  }
}
