const fs = require('fs')
const lines = (fs.readFileSync(process.stdin.fd, { encoding: 'utf8' }) as string)
    .split("\n")
    .filter(line => line.length > 0)

class Card {
    count: number
    readonly wins: number

    constructor(line: string) {
        const [_cardNo, cardInfo] = line.split(':') as string[]
        const [winningNumText, presentNumText] = cardInfo.split('|') as string[]
        const winningNums = winningNumText.split(" ").filter(t => t.length > 0).map(t => parseInt(t))
        const presentNums = presentNumText.split(" ").filter(t => t.length > 0).map(t => parseInt(t))
        let wins = 0    // why doesn't ES6 have Array.prototype.count
        winningNums.forEach(num => {
            if (presentNums.indexOf(num) >= 0)
                ++wins
        })
        this.wins = wins
        this.count = 1
    }
}

let cards: Card[] = []
lines.forEach(line => {
    cards.push(new Card(line))
})

for(let i = 0; i < cards.length; ++i) {
    //console.log(cards.map(c => c.count))
    for(let j = 0; j < cards[i].wins && i + j + 1 < cards.length; ++j) {
        cards[i + j + 1].count += cards[i].count
    }
}

console.log(cards.reduce((count, card) => count + card.count, 0))
