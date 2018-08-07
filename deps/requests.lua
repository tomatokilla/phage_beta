--[[
  Imitation of python requests, based on luasocket && luasec
  Usage:
    local requests = require('requests')
    local res = requests.get(url)
    local res = requests.get(api, {params = {foo = 'foo', bar = {...}}})
    local res = requests.get({
      url = 'http://www.baidu.com',
      params = {...},
      data = {...},
      header = {...},
      cookie = {...},
      allow_redirect = true || fasle,
      proxy = '',
      ...
    })
    print(res.statusCode, res.headers, res.status, res.text, res.json())
    local res = requests.post()
    local res = requests.update()
    local res = requests.delete()

  Limitation: http only   // https will be supported as long as luasec
  compiled successfully

  Caveat: functions of requests are not **pure**, which means the
  request obj that passed into the requests funcs might be mutated.
    eg: local requests = require('requests')
        local state = {...}
        local res = requests.get('http://www.foo.com/api/user', {params = state.currentUser})
        then 'state' should be mutated.
  This issue might be improved if necessary.
]]

local httpSocket = require('socket.http')
-- local httpsSocket = require('ssl.https')
-- local urlParser = require('socket.url')
local ltn12 = require('ltn12')
local json = require('json')
-- local json = require('ts').cjson_safe

local next, pairs, type, error, tostring = 
      next, pairs, type, error, tostring
local remove, concat = table.remove, table.concat
local find = string.find

local function makeRequest(req)
  local resBody = {}
  local fullReq = {
    method = req.method,
    url = req.url,
    headers = req.headers,
    source = ltn12.source.string(req.data),
    sink = ltn12.sink.table(resBody),
    redirect = req.allow_redirects,
    proxy = req.proxy
  }
  local res, socket, ok = {}, httpSocket
  ok, res.statusCode, res.headers, res.status = socket.request(fullReq)
  res.text = concat(resBody)
  res.json = function() return json.decode(res.text) end
  return res
end

local function formatParams(url, params)
  if type(params) ~= 'table' or next(params) == nil then
    return url
  end
  url = url .. '?'
  for k, v in pairs(params) do
    url = url .. k .. '='
    if type(v) == 'table' then
      local val = ''
      for _, _v in ipairs(v) do
        val = val .. _v .. ','
      end
      url = url .. val:sub(0, -2)
    else
      url = url .. v
    end
    url = url .. '&'
  end 
  return url:sub(0, -2)
end

-- Check if url is provided and append params if exists
local function checkUrl(req)
  if not req.url then error('url got nil.') end
  req.url = formatParams(req.url, req.params)
end

local function checkData(req)
  req.data = req.data or ''
  if type(req.data) == 'table' then
    req.data = json.encode(req.data)
  end
end

local function createHeader(req)
  req.headers = req.headers or {}
  req.headers['Content-Length'] = req.data:len()
  if req.cookies then
    req.headers.cookies = req.headers.cookies == nil and req.cookies or
                          req.headers.cookies .. '; ' .. req.cookies
  end
end

local function checkTimeout(timeout)
  httpSocket.TIMEOUT = timeout or 6
  -- httpsSocket.TIMEOUT = timeout or 6
end

local function checkRedirect(allow_redirects) end

local function parseArgs(req)
  checkUrl(req)
  checkData(req)
  createHeader(req)
  checkTimeout(req.timeout)
  checkRedirect(req.allow_redirects)
end

local function request(method, url, args)
  local req
  if type(url) == 'table' then
    req = url
    if not req.url and req[1] then
      req.url = remove(req, 1)
    end
  else
    req = args or {}
    req.url = url
  end
  req.method = method
  parseArgs(req)
  return makeRequest(req)
end

---------------------------------------------------------------
local _M = {}

function _M.get(url, args)
  return request('GET', url, args)
end

function _M.post(url, args)
  return request('POST', url, args)
end

function _M.update(url, args)
  return request('PUT', url, args)
end

function _M.delete(url, args)
  return request('DELETE', url, args)
end


---------------------------------------------------------------
return _M