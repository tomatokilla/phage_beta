local routine = {
  initDevice = {
    'initDevice',
    'markStatus',
  },
  register = {
	  'foo',
    'bar'
  },
}

local taskMap = {
  {
    taskname = 'initDevice',
    times = 1,
  },
  {
  	taskname = 'register',
	  times = 3,
  }
}

local Phage = require('phage')
local pha = Phage:new(routine, taskMap, 'NEX5', 'tantan')
pha:initState()
pha:loadWorker('initDevice', {initDevice = function() print('initdevice functon') return {ok=true} end, markStatus = function() print('mark statusfunction') return {ok=true} end,})
pha:loadWorker('register', {foo = function() print('foo functon') return {ok=true} end, bar = function() print('bar function') return {ok=true} end,})
pha:prepare()
pha:reportAndLog()
pha:run()
