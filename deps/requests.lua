local httpSocket = require('socket.http')
-- local httpsSocket = require('ssl.https')
local urlParser = require('socket.url')
local ltn12 = require('ltn12')
local json = require('cjson.safe')

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
  local res = {}
  local ok
  local socket = (find(fullReq.url, '^https:') and 
        not request.proxy) and https_socket or http_socket
  ok, res.statusCode, res.headers, res.status = socket.request(fullReq)
  res.text = concat(resBody)
  res.json = function() return json.decode(res.text) end
  return res
end

local function parseArgs(req)
  checkUrl(req)
  checkData(req)
  createHeader(req)
  checkTimeout(req.timeout)
  checkRedirect(req.allow_redirects)
end

local function formatParams(url, params)
  if not params or next(params) == nil then
    return url
  end
  url = url .. '?'
  for k, v in pairs(params) do
    url = url .. k .. '='
    if type(v) == 'table' then
      local val = ''
      for _, _v in ipairs(v) do
        val = val .. tostring(_v) .. ','
      end
      url = url .. val:sub(0, -2)
    else
      url = url .. tostring(v)
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

local function createHeader(req)
  req.headers = req.headers or {}
  req.headers['Content-Length'] = req.data:len()
  if req.cookies then
    if req.headers.cookies then
      req.headers.cookies = req.headers.cookies .. '; ' .. req.cookies
    else
      req.headers.cookies = req.cookies
    end
  end
end

local function checkData(req)
  req.data = req.data or ''
  if type(req.data) == 'table' then
    req.data = json.encode(req.data)
  end
end

local function checkTimeout(timeout)
  httpSocket.TIMEOUT = timeout or 5
  httpsSocket.TIMEOUT = timeout or 5
end

local function checkRedirect(allow_redirects)
  return
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

function _M.update(url, args)
  return request('DELETE', url, args)
end


---------------------------------------------------------------
return _M