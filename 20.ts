enum Pulse {
  Low,
  High
}

type Message = [string, string, Pulse]

class Network {
  modules: { [key: string]: Module }
  stats: { [key: number]: number }
  queue: Message[]
   
  constructor() {
    this.modules = {}
    this.stats = {}
    this.queue = []
    this.stats[Pulse.Low] = 0
    this.stats[Pulse.High] = 0
  }

  addModule(module: Module) {
    this.modules[module.name] = module
  }

  broadcast(index: number, periodicityWatch: { [key: string]: number } = {}) {
    this.stats[Pulse.Low] += 1 // button
    this.modules["broadcaster"].send(Pulse.Low)
    while (this.queue.length > 0) {
      const [from, to, pulse] = this.queue.shift()!
      if (this.modules[to].processMessage(from, pulse)) {
        const name = this.modules[to].name
        if (name in periodicityWatch) {
          periodicityWatch[name] = index
        }
      }
    }
  }

  linkSources() {
    Object.values(this.modules).forEach(module => {
      module.targets.forEach(target => {
        if (!this.modules[target]) {
          this.modules[target] = new Output(this, target, [])
        }
        this.modules[target].addSource(module.name)
      })
    })
  }

  send(from: string, pulse: Pulse) {
    const module = this.modules[from]
    module.targets.forEach(target => {
      // console.log(`${from} -${pulse === Pulse.Low ? 'low' : 'high'}-> ${target}`)
      this.queue.push([from, target, pulse])
      this.stats[pulse] += 1
    })
  }

  reset() {
    this.stats[Pulse.Low] = 0
    this.stats[Pulse.High] = 0
    Object.values(this.modules).forEach(module => module.reset())
  }

  outputs() {
    let ret: { [key: string]: number } = {}
    Object.values(this.modules).forEach(module => {
      const c = module.outputCount()
      if (c) {
        ret[module.name] = c
      }
    })
    return ret
  }
}

class Module {
  network: Network
  name: string
  sources: string[]
  targets: string[]

  constructor(network: Network, name: string, targets: string[]) {
    this.network = network
    this.name = name
    this.sources = []
    this.targets = targets
  }

  addSource(source: string) {
    this.sources.push(source)
  }

  processMessage(from: string, pulse: Pulse) { return false }
  outputCount() { return 0 }
  inspect() { return this.name }
  reset() {}

  send(pulse: Pulse) {
    this.network.send(this.name, pulse)
  }
}

class FlipFlop extends Module {
  on: boolean

  constructor(network: Network, name: string, targets: string[]) {
    super(network, name, targets)
    this.on = false
  }

  reset() {
    this.on = false
  }

  inspect() {
    return `${this.name}:${this.on ? "ON" : "OFF"}`
  }

  processMessage(from: string, pulse: Pulse) {
    if (pulse == Pulse.Low) {
      if (this.on) {
        this.on = false
        this.send(Pulse.Low)
      } else {
        this.on = true
        this.send(Pulse.High)
      }
      return this.on
    }
    return false    
  }  
}

class Conjunction extends Module {
  memory: { [key: string]: Pulse }

  constructor(network: Network, name: string, targets: string[]) {
    super(network, name, targets)
    this.memory = {}
  }

  reset() {
    Object.keys(this.memory).forEach(key => {
      this.memory[key] = Pulse.Low
    })
  }

  addSource(source: string) {
    super.addSource(source)
    this.memory[source] = Pulse.Low
  }

  inspect() {
    return `${this.name}(${Object.entries(this.memory).join(";")})`
  }

  processMessage(from: string, pulse: Pulse) {
    this.memory[from] = pulse
    if (Object.values(this.memory).every(m => m == Pulse.High)) {
      this.send(Pulse.Low)
      return false
    }
    else {
      this.send(Pulse.High)
      return true
    }
  }  
}

class Broadcaster extends Module {
  constructor(network: Network, name: string, targets: string[]) {
    super(network, name, targets)
  }  
}

class Output extends Module {
  count: number

  constructor(network: Network, name: string, targets: string[]) {
    super(network, name, targets)
    this.count = 0
  }  
  
  processMessage(from: string, pulse: Pulse) {
    if (pulse === Pulse.Low) {
      this.count += 1
    }
    return false
  }

  outputCount() {
    return this.count
  }
}

const fs = require('fs')
let network = new Network
const data = fs.readFileSync(process.stdin.fd, { encoding: 'utf8' }) as string
data.split("\n").forEach(line => {
  const [name, target_line] = line.split(' -> ')
  const targets = target_line.split(', ')
  if (name[0] == '%') {
    network.addModule(new FlipFlop(network, name.substr(1), targets))
  } else if (name[0] == '&') {
    network.addModule(new Conjunction(network, name.substr(1), targets))
  } else {
    network.addModule(new Broadcaster(network, name, targets))
  }
})

network.linkSources()

for(let i = 0; i < 1000; ++i)
  network.broadcast(i)

console.log(network.stats)
console.log(Object.values(network.stats).reduce((n, m) => n * m))

network.reset()

function inspectModules(modules: Module[], depth: number) {
  if (depth == 0)
    return

  let nextLevel: Module[] = []
  let thisLine = ""
  while (modules.length > 0) {
    const module = modules.shift()
    thisLine += module!.inspect() + " "
    nextLevel = nextLevel.concat(module!.sources.map(name => module!.network.modules[name]))
  }
  console.log(thisLine)
  inspectModules(nextLevel, depth - 1)
}

let periodicityWatch = {'nx': 0, 'sp': 0, 'cc': 0, 'jq': 0}
for(let i = 1;; ++i) {
  network.broadcast(i, periodicityWatch)
  const period = Object.values(periodicityWatch).map(n => BigInt(n)).reduce((n, m) => n * m)
  if (period != 0n) {
    console.log(period)
    break
  }
}