use rand::seq::SliceRandom;
use rand::thread_rng;
use rand::Rng;
use rand_chacha::rand_core::SeedableRng;
use rusqlite::{Connection, Result};
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use warp::{http::Response, Filter};

#[derive(Clone, Debug, Serialize, Deserialize)]
struct Card {
    rank: String,
    suit: String,
}

fn create_deck() -> Vec<Card> {
    let mut deck: Vec<Card> = Vec::new();
    let ranks = vec![
        "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A",
    ];
    let suits = vec!["HEARTS", "CLUBS", "SPADES", "DIAMONDS"];
    for _ in 1..3 {
        for rank in ranks.iter() {
            for suit in suits.iter() {
                deck.push(Card {
                    rank: (*rank).to_string(),
                    suit: (*suit).to_string(),
                });
            }
        }
    }
    deck
}

fn shuffle_deck<R: Rng>(_deck: &mut Vec<Card>, rng: &mut R) {
    let _ = &_deck[..].shuffle(rng);
}

fn create_game() -> Result<()> {
    let conn = Connection::open("games.db")?;
    let id = Uuid::new_v4();
    let deck = create_deck();
    let serialized_deck = serde_json::to_string(&deck).unwrap();

    conn.execute(
        "create table if not exists game (
             id text primary key,
             deck text,
             started integer,
         )",
        (),
    )?;

    conn.execute(
        "INSERT INTO game (name) values (?1, ?2, 0)",
        &[&id.to_string(), &serialized_deck],
    )?;

    Ok(())
}

#[derive(Debug)]
struct Game {
    id: String,
    deck: String,
    started: i8,
}

fn get_game(_id: String) -> Result<()> {
    let conn = Connection::open("games.db")?;
    let mut stmt = conn.prepare("SELECT id, name, data FROM person WHERE id= ?")?;
    let game_iter = stmt.query_map(rusqlite::params![_id], |row| {
        Ok(Game {
            id: row.get(0)?,
            deck: row.get(1)?,
            started: row.get(2)?,
        })
    })?;
    for game in game_iter {
        println!("Found game {:?}", game.unwrap());
    }
    Ok(())
}

fn start_game(_id: String) -> Result<()> {
    Ok(())
}

fn end_game(_id: String) -> Result<()> {
    Ok(())
}

#[derive(Deserialize, Serialize)]
struct UserSeed {
    name: String,
    seed: u128,
}

#[tokio::main]
async fn main() {
    // POST /creategame
    let create = warp::post().and(warp::path("create")).map(|| {
        let _res = match create_game() {
            Ok(res) => res,
            Err(e) => println!("{}", e),
        };
    });

    // POST /shuffle  {"name":"Sean","rate":2}
    // Shuffles the deck with an user-generated seed
    let shuffle = warp::post()
        .and(warp::path("shuffle"))
        .and(warp::path::param::<String>())
        .and(warp::body::json())
        .map(|id: String, seed: UserSeed| {
            // from user seed
            let mut rng = rand_chacha::ChaCha8Rng::seed_from_u64(10);
            warp::reply::json(&seed)
        });
    warp::serve(shuffle).run(([127, 0, 0, 1], 3030)).await
}
