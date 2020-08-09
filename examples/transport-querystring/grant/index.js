
var grant = require('grant').azure({
  config: require('./config.json'), session: {secret: 'grant'}
})

module.exports = async (context, req) => {
  var {redirect} = await grant(req)
  return redirect
}
