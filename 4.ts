const fs = require('fs')
const data = (fs.readFileSync(process.stdin.fd, { encoding: 'utf8' }) as string)
    .split("\n")
    .filter(line => line.length > 0)

let total = 0
data.forEach(line => {
    const [cardNo, cardInfo] = line.split(':') as string[]
    const [winningNumText, presentNumText] = cardInfo.split('|') as string[]
    const winningNums = winningNumText.split(" ").filter(t => t.length > 0).map(t => parseInt(t))
    const presentNums = presentNumText.split(" ").filter(t => t.length > 0).map(t => parseInt(t))

    let matches = 0
    winningNums.forEach(num => {
        if (presentNums.indexOf(num) >= 0)
            ++matches
    })
    if (matches > 0) {
        total += (1 << (matches - 1))
    }
})

console.log(total)