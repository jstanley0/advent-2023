const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

type Handful = {
    [color: string]: number
}

type Game = {
    id: number
    handfuls: Handful[]
}

function isGamePossible(game: Game, bag_contents: Handful) : boolean {
    return game.handfuls.every(handful => {
        return Object.keys(handful).every(color => bag_contents[color] >= handful[color])
    })
}

function minimalBagContents(game: Game) : Handful {
    let bag : Handful = {}
    game.handfuls.forEach(handful => {
        Object.keys(handful).forEach(color => {
            if (!bag[color] || bag[color] < handful[color])
                bag[color] = handful[color]
        })
    })
    return bag
}

function cubePower(handful: Handful) : number {
    return Object.values(handful).reduce((product, val) => product * val, 1)
}

async function run() {
    let games : Game[] = []
    for await (const line of rl) {
        // Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        const [game_and_id, game_text] = line.split(": ")
        if (typeof game_text !== 'string')
            continue
        let game : Game = {
            id: parseInt(game_and_id.split(' ').pop()),
            handfuls: []
        }
        game_text.split("; ").forEach(handfulText => {
            let handful : Handful = {}
            handfulText.split(", ").forEach(cubeText => {
                const [count, color] = cubeText.split(" ")
                handful[color] = parseInt(count)
            })
            game.handfuls.push(handful)
        })
        games.push(game)
    }

    console.log("\n---\n") // why does readline echo input? stop doing that.

    // part 1
    const bag_contents: Handful = { "red": 12, "green": 13, "blue": 14 }
    let sum = games.filter(game => isGamePossible(game, bag_contents)).reduce(
        (sum, game) => sum + game.id,
        0
    )
    console.log(sum)

    // part 2
    console.log(games.reduce((sum, game) => sum + cubePower(minimalBagContents(game)), 0))
}

run()