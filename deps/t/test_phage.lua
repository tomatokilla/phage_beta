
local routine = {
  initDevice = {
    'checkingFoo',
    'checkingBar',
    '...'
  },

  register = {
    'opennzt',
    'tapfoo',
    'tapbar',
  },
  
  browse = {
    'matching',
    'chat',
    'randomMatch&Chat'
  }
}

local taskMap = {
  {
    task = 'initDevice',
  },
  {
    task = 'register',
    times = 99,
  },
}

-- local labours = {}

local pha = phage:new(routine, taskMap, 'NEX5', 'tantan')

pha:initSettings({
  foo = 'foo',
  bar = 'bar',
})

pha:initState({
  currentTask = '',
  currentIndex = 1,
  flowState = 'ok',
  flowErr = {
    routineErr = '',
    taskMapErr = '',
    workerErr  = '',
  },
  ready = false
})

pha:set({
  autoLoadWorker = true,
  monitor = true,
})

pha:prepare()
pha:run()



