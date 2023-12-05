const fs = require('fs')
const data = (fs.readFileSync(process.stdin.fd, { encoding: 'utf8' }) as string)
    .split("\n\n")

type Range = {
    source: number
    dest: number
    length: number
}

type Mapp = {
    source: string
    dest: string
    ranges: Range[]
}

function mapValue(source: number, map: Mapp): number {
    const range = map.ranges.find(range => source >= range.source && source < range.source+range.length)
    if (!range)
        return source
    return range.dest + (source - range.source)
}

let maps : Mapp[] = []
const seeds = data.shift()!.split(": ").pop()!.split(" ").map(n => parseInt(n))

while(data.length > 0) {
    const map_lines = data.shift()!.split("\n")
    const [map_source, map_dest] = map_lines.shift()!.split(' ').shift()!.split("-to-")
    let ranges : Range[] = []
    map_lines.forEach(line => {
        const [dest, source, length] = line.split(' ').map(i => parseInt(i))
        ranges.push({dest, source, length})
    })
    maps.push({source: map_source, dest: map_dest, ranges})
}

let min = Infinity
seeds.forEach(seed => {
    let n = seed
    maps.forEach(map => {
        n = mapValue(n, map)
    })
    if (n < min)
        min = n
    console.log(n)
})
console.log(min)
console.log('--')

min = Infinity
for(let i = 0; i < seeds.length; i += 2) {
    for(let j = 0; j < seeds[i + 1]; ++j) {
        let n = seeds[i] + j
        maps.forEach(map => {
            n = mapValue(n, map)
        })
        if (n < min)
            min = n
    }
}
console.log(min)