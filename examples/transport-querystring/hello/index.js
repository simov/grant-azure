
module.exports = async (context, req) => {
  return {
    status: 200,
    headers: {'content-type': 'text/plain'},
    body: JSON.stringify(req.query, null, 2)
  }
}
