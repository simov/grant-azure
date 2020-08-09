
var grant = require('grant').azure({
  config: require('./config.json'),
  session: {secret: 'grant', store: require('./store')}
})

module.exports = async (context, req) => {
  if (/\/connect\/google\?/.test(req.originalUrl)) {
    var state = {dynamic: {scope: ['openid']}}
  }
  else if (/\/connect\/twitter\?/.test(req.originalUrl)) {
    var state = {dynamic: {key: 'CONSUMER_KEY', secret: 'CONSUMER_SECRET'}}
  }

  var {redirect, response, session} = await grant(req, state)

  if (redirect) {
    return redirect
  }
  else {
    await session.remove()
    return {
      status: 200,
      headers: {'content-type': 'text/plain'},
      body: JSON.stringify(response, null, 2)
    }
  }
}
