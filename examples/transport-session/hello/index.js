
var Session = require('grant/lib/session')({
  secret: 'grant', store: require('../store')
})

module.exports = async (context, req) => {
  var session = Session(req)

  var {response} = (await session.get()).grant
  await session.remove()

  return {
    status: 200,
    headers: {'content-type': 'text/plain'},
    body: JSON.stringify(response, null, 2)
  }
}
