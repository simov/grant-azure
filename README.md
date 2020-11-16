
# grant-azure

> _Azure Function handler for **[Grant]**_

```js
var grant = require('grant').azure({
  config: {/*configuration - see below*/}, session: {secret: 'grant'}
})

module.exports = async (context, req) => {
  var {redirect, response} = await grant(req)
  return redirect || {
    status: 200,
    headers: {'content-type': 'application/json'},
    body: JSON.stringify(response)
  }
}
```

> _Also available for [AWS], [Google Cloud], [Vercel]_

> _[ES Modules and TypeScript][grant-types]_

---

## Configuration

The `config` key expects your [**Grant** configuration][grant-config].

### proxies.json

It is required to set the following `requestOverrides` for Grant:

```json
{
  "$schema": "http://json.schemastore.org/proxies",
  "proxies": {
    "oauth": {
      "matchCondition": {
        "route": "{*proxy}"
      },
      "requestOverrides": {
        "backend.request.querystring.oauth_code": "{backend.request.querystring.code}",
        "backend.request.querystring.code": ""
      },
      "backendUri": "http://localhost/{proxy}"
    }
  }
}
```

---

## Routes

You login by navigating to:

```
https://[APP].azurewebsites.net/connect/google
```

The redirect URL of your OAuth app have to be set to:

```
https://[APP].azurewebsites.net/connect/google/callback
```

And locally:

```
http://localhost:3000/connect/google
http://localhost:3000/connect/google/callback
```

---

## Session

The `session` key expects your session configuration:

Option | Description
:- | :-
`name` | Cookie name, defaults to `grant`
`secret` | Cookie secret, **required**
`cookie` | [cookie] options, defaults to `{path: '/', httpOnly: true, secure: false, maxAge: null}`
`store` | External session store implementation

#### NOTE:

- The default cookie store is used unless you specify a `store` implementation!
- Using the default cookie store **may leak private data**!
- Implementing an external session store is recommended for production deployments!

Example session store implementation using [Firebase]:

```js
var request = require('request-compose').client

var path = process.env.FIREBASE_PATH
var auth = process.env.FIREBASE_AUTH

module.exports = {
  get: async (sid) => {
    var {body} = await request({
      method: 'GET', url: `${path}/${sid}.json`, qs: {auth},
    })
    return body
  },
  set: async (sid, json) => {
    await request({
      method: 'PATCH', url: `${path}/${sid}.json`, qs: {auth}, json,
    })
  },
  remove: async (sid) => {
    await request({
      method: 'DELETE', url: `${path}/${sid}.json`, qs: {auth},
    })
  },
}
```

---

## Handler

The Azure Function handler for Grant accepts:

Argument | Type | Description
:- | :- | :-
`req` | **required** | The request object
`state` | optional | [Dynamic State][grant-dynamic-state] object `{dynamic: {..Grant configuration..}}`

The Azure Function handler for Grant returns:

Parameter | Availability | Description
:- | :- | :-
`session` | Always | The session store instance, `get`, `set` and `remove` methods can be used to manage the Grant session
`redirect` | On redirect only | HTTP redirect controlled by Grant, your function have to return this object when present
`response` | Based on transport | The [response data][grant-response-data], available for [transport-state][example-transport-state] and [transport-session][example-transport-session] only

---

## Examples

Example | Session | Callback λ | Routing
:- | :- | :- | :-
`transport-state` | Cookie Store | ✕ | {*proxy}
`transport-querystring` | Cookie Store | ✓ | /connect/{provider}/callback
`transport-session` | Firebase Session Store | ✓ | /connect/{provider}/callback
`dynamic-state` | Firebase Session Store | ✕ | {*proxy}

> _Different routing configurations and session store types were used for example purposes only._

#### Configuration

All variables at the top of the [`Makefile`][example-makefile] with value set to `...` have to be configured:

- `subscription_id` - Subscription ID
- `tenant_id` - Azure AD Tenant ID
- `client_id` - Azure AD Client ID
- `client_secret` - Azure AD Client Secret

- `user` - Publish Profile User Name
- `pass` - Publish Profile Password

- `firebase_path` - [Firebase] path of your database, required for [transport-session][example-transport-session] and [dynamic-state][example-dynamic-state] examples

```
https://[project].firebaseio.com/[prefix]
```

- `firebase_auth` - [Firebase] auth key of your database, required for [transport-session][example-transport-session] and [dynamic-state][example-dynamic-state] examples

```json
{
  "rules": {
    ".read": "auth == '[key]'",
    ".write": "auth == '[key]'"
  }
}
```

All variables can be passed as arguments to `make` as well:

```bash
make plan example=transport-querystring ...
```

#### Dockerfile

Running the [transport-session][example-transport-session] and the [dynamic-state][example-dynamic-state] examples locally requires your [Firebase] credentials to be set in the `Dockerfile` as well:

```Dockerfile
ENV FIREBASE_PATH=...
ENV FIREBASE_AUTH=...
```

---

## Develop

```bash
# build example locally
make build-dev
# run example locally
make run-dev
```

---

## Deploy

```bash
# build Grant for deployment
make build-grant
# build Grant for transport-querystring and transport-session examples
make build-callback
# deploy Grant
make deploy
```

```bash
# execute only once
make init
# plan for deployment
make plan
# apply plan for deployment
make apply
# cleanup resources
make destroy
```

---

  [Grant]: https://github.com/simov/grant
  [AWS]: https://github.com/simov/grant-aws
  [Azure]: https://github.com/simov/grant-azure
  [Google Cloud]: https://github.com/simov/grant-gcloud
  [Vercel]: https://github.com/simov/grant-vercel

  [cookie]: https://www.npmjs.com/package/cookie
  [Firebase]: https://firebase.google.com/

  [grant-config]: https://github.com/simov/grant#configuration
  [grant-dynamic-state]: https://github.com/simov/grant#dynamic-state
  [grant-response-data]: https://github.com/simov/grant#callback-data
  [grant-types]: https://github.com/simov/grant#misc-es-modules-and-typescript

  [example-makefile]: https://github.com/simov/grant-azure/tree/master/Makefile
  [example-transport-state]: https://github.com/simov/grant-azure/tree/master/examples/transport-state
  [example-transport-querystring]: https://github.com/simov/grant-azure/tree/master/examples/transport-querystring
  [example-transport-session]: https://github.com/simov/grant-azure/tree/master/examples/transport-session
  [example-dynamic-state]: https://github.com/simov/grant-azure/tree/master/examples/dynamic-state
