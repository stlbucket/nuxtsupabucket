import jwt from 'jsonwebtoken'
import {postgraphile} from 'postgraphile'

const schemas = process.env.GRAPHQL_SCHEMAS || 'todo,todo_fn_api,app,app_fn_api'.split(',')
const SUPABASE_URI = process.env.SUPABASE_URI
const SUPABASE_JWT_SECRET = process.env.SUPABASE_JWT_SECRET
// const SUPABASE_URL = process.env.SUPABASE_URL
// const SUPABASE_KEY = process.env.SUPABASE_KEY

if (!SUPABASE_URI) {
  throw new Error('MUST DEFINE SUPABASE_URI')
}

if (!SUPABASE_JWT_SECRET) {
  throw new Error('MUST DEFINE ENV VARIABLE:     SUPABASE_JWT_SECRET')
}


const postgraphileOptions = {
  graphiql: true,
  graphqlRoute: '/api/graphql',
  graphiqlRoute: '/api/graphiql',
  enhanceGraphiql: true,
  ignoreRBAC: false,
  disableDefaultMutations: true,
  dynamicJson: true,
  disableQueryLog: false,
  allowExplain: true,
  simpleCollections: 'both',
  pgSettings: async (req: any): Promise<any> => {
    const claims = await parseClaims(req)
    const pgSettings = {
      role: claims.aud || 'anon',
      'request.jwt.claim.sub': claims.sub,
      'request.jwt.claim.aud': claims.aud,
      'request.jwt.claim.exp': claims.exp,
      'request.jwt.claim.email': claims.email,
      'request.jwt.claim': JSON.stringify(claims)
    }
    console.log('pgSettings', JSON.stringify(pgSettings,null,2))
    return pgSettings
  }
}

const postgraphileServer = postgraphile(SUPABASE_URI, schemas, postgraphileOptions)

async function parseClaims(req: any) {  
  try {
    const tokenCookie = req.headers["cookie"] ? req.headers["cookie"].split('; ').find((c: string) => c.indexOf('sb-access-token=') === 0) : null
    const token = tokenCookie ? tokenCookie.toString().split('=')[1] : null

    if (!token) {
      throw 'No token provided'
    }
    const claims = await jwt.verify(token, SUPABASE_JWT_SECRET)
    const nowNum = Math.floor((new Date()).getTime() / 1000)

    if (nowNum > claims.exp) {
      throw new Error("SESSION EXPIRED")
    } else {
      return claims
    }
  } catch (e: any) {
    if (e.toString() === 'No token provided') {
      return {
        role: 'anon'
      }
    } else {
      throw e
    }
  }
}


export default fromNodeMiddleware(postgraphileServer)
