const fs = require('fs')
const data = (fs.readFileSync(process.stdin.fd, { encoding: 'utf8' }) as string)
    .split("\n")

const times = data[0].split(':').pop()!.trim().split(/\s+/).map(x => parseInt(x))
const dists = data[1].split(':').pop()!.trim().split(/\s+/).map(x => parseInt(x))

let prod = 1
for(let i = 0; i < times.length; ++i) {
    let wins = 0
    for(let hold_time = 1; hold_time < times[i]; ++hold_time) {
        const distance = (times[i] - hold_time) * hold_time
        if (distance > dists[i])
            ++wins;
    }
    console.log(wins)
    prod *= wins
}
console.log(prod)
console.log('--')

const time_frd = parseInt(times.map(n => `${n}`).join(''))
const dist_frd = parseInt(dists.map(n => `${n}`).join(''))
let wins = 0
for(let hold_time = 1; hold_time < time_frd; ++hold_time) {
    const distance = (time_frd - hold_time) * hold_time
    if (distance > dist_frd)
        ++wins;
}
console.log(wins)
