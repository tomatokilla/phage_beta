local workingMap = {
  {
    task = "register",
    quantity = 5,
    foo = 'bar'
  },
  {
    task = 'browse',
    quantity = 9
  },
  {
    task = 'fertilize'
    quantity = 8
  }
}

local blocked = {
  item1 = {
    flip = 40,
    noMatch = true
  },

  item2 = {
    ....
  }
}

---------------------------------------------------------
return {
  workingMap = workingMap,
  blocked = blocked,
}