extern crate csv;
extern crate flate2;

#[macro_use]
extern crate serde_derive;

//use std::env;
use std::fs::File;
use std::io;

use flate2::read::GzDecoder;
use chrono::{DateTime, Utc, NaiveDateTime};


trait EventTime {
    fn get_timestamp(&self) -> DateTime<Utc>;
}

macro_rules! impl_get_timestamp_for_events {
	($ ( $t:ident ), * ) => {
		$(
			impl EventTime for $t{
				fn get_timestamp(&self) -> DateTime<Utc>{
					let seconds: i64 = (self.timestamp / 1_000_000) as i64;
					let nsecs: u32 = (self.timestamp % 1_000_000) as u32;
					let naive = NaiveDateTime::from_timestamp(seconds, nsecs * 1000);
					let datetime: DateTime<Utc> = DateTime::from_utc(naive, Utc);
					datetime
				}
			}
		)*
	};
}

impl_get_timestamp_for_events!(Quote, QuoteRow, Trade, TradeRow);

#[derive(Debug, Default, Clone)]
struct Quote {
    symbol: String,
    timestamp: i64,
    ask_amount: f32,
    ask_price: f32,
    bid_price: f32,
    bid_amount: f32,
}


#[derive(Debug, Deserialize)]
struct QuoteRow {
    exchange: String,
    symbol: String,
    timestamp: i64,
    local_timestamp: i64,
    ask_amount: f32,
    ask_price: f32,
    bid_price: f32,
    bid_amount: f32,
}

#[derive(Debug,  Clone)]
struct Trade {
    symbol: String,
    timestamp: i64,
    id: u32,
    side: String,
    price: f32,
    amount: f32,
}

#[derive(Debug, Deserialize)]
struct TradeRow {
    exchange: String,
    symbol: String,
    timestamp: i64,
    local_timestamp: i64,
    id: u32,
    side: String,
    price: f32,
    amount: f32,
}

#[derive(Debug)]
enum Ticks {
    Trade(Trade),
    Quote(Quote),
}


#[derive(Default)]
struct Producer {
    events_cache: Vec<Ticks>,
    trades_reader: Option<csv::Reader<GzDecoder<File>>>,
    quotes_reader: Option<csv::Reader<GzDecoder<File>>>,

    has_tick_data: bool,

    _next_quote_tick: Option<Quote>,
    _next_trade_tick: Option<Trade>,

    _trade_row_record: csv::ByteRecord,
    _quote_row_record: csv::ByteRecord,

    _quotes_counter: u64,
    _trades_counter: u64,

}

impl Producer {
    fn new(trades_path: &str, quotes_path: &str) -> Producer {
        let tr = Self::read_gz_file(trades_path);
        let qr = Self::read_gz_file(quotes_path);
        let mut p = Producer {
            trades_reader: Option::from(tr),
            quotes_reader: Option::from(qr),
            ..Default::default()
        };
        p._iterate_quote_tick();
        p._iterate_trade_tick();
        p.has_tick_data = true;
        p

    }

    fn read_gz_file(path: &str) -> csv::Reader<GzDecoder<File>> {
        let input_file = File::open(&path).expect("Unable to open");
        let decoder = GzDecoder::new(input_file);
        csv::ReaderBuilder::new().has_headers(true).from_reader(decoder)
    }

    fn push(&mut self, value: Ticks) {
        self.events_cache.push(value);
    }

    fn _iterate_trade_tick(&mut self) {
        if let Option::Some(reader) = &mut self.trades_reader {
            if let Ok(true) = reader.read_byte_record(&mut self._trade_row_record) {
                self._trades_counter += 1;
                let row: TradeRow = self._trade_row_record.deserialize(None).unwrap();
                self._next_trade_tick = Some(Trade {
                    symbol: row.symbol.to_string(),
                    timestamp: row.local_timestamp,
                    id: row.id,
                    side: row.side,
                    price: row.price,
                    amount: row.amount,
                });
                //println!("{:?}", self._next_trade_tick.as_ref());
            } else {
                println!("Trades is end total: {} ticks", self._trades_counter);
                self._next_trade_tick = None;
                if self._next_quote_tick.is_none() {
                    self.has_tick_data = false;
                }
            }
        }
    }

    fn _iterate_quote_tick(&mut self) {
        if let Option::Some(reader) = &mut self.quotes_reader {
            if let Ok(true) = reader.read_byte_record(&mut self._quote_row_record) {
                self._quotes_counter += 1;
                let row: QuoteRow = self._quote_row_record.deserialize(None).unwrap();
                self._next_quote_tick = Some(Quote {
                    symbol: row.symbol.to_string(),
                    timestamp: row.local_timestamp,
                    ask_amount: row.ask_amount,
                    ask_price: row.ask_price,
                    bid_amount: row.bid_amount,
                    bid_price: row.bid_price,
                });
                //println!("{:?}", self._next_quote_tick.as_ref());
            } else {
                println!("Quotes is end total: {} ticks", self._quotes_counter);
                self._next_quote_tick = None;
                if self._next_trade_tick.is_none() {
                    self.has_tick_data = false;
                }
            }
        }
    }

    /// Return the next tick in the stream (if one exists).
    ///
    ///         Checking `has_tick_data` is `True` will ensure there is a next tick.
    ///
    ///         Returns
    ///         -------
    ///         Tick or None
    fn next_tick(&mut self) -> Option<Ticks>{
        // Quote ticks only

        if self.has_tick_data == false{
            return None;
        }

        if  self._next_trade_tick.is_none() {
            let next_tick =  self._next_quote_tick.as_ref().unwrap().to_owned();
            self._iterate_quote_tick();
            return Some(Ticks::Quote(next_tick));
        }
        //  Trade ticks only
        if  self._next_quote_tick.is_none() {
            let next_tick = self._next_trade_tick.as_ref().unwrap().to_owned();
            self._iterate_trade_tick();
            return Some(Ticks::Trade(next_tick));
        }
        // Mixture of quote and trade ticks
        if self._next_quote_tick.as_ref().unwrap().timestamp <= self._next_trade_tick.as_ref().unwrap().timestamp {
            let next_tick = self._next_quote_tick.as_ref().unwrap().to_owned();
            self._iterate_quote_tick();
            return Some(Ticks::Quote(next_tick));
        }else{
            let next_tick = self._next_trade_tick.as_ref().unwrap().to_owned();
            self._iterate_trade_tick();
            return Some(Ticks::Trade(next_tick));
        }

    }
}


//binance-futures,BTCUSDT,1582156799862000,1582156799997336,4.55,9593.61,9593.31,8.171
static CSV_PATH_QUOTES: &str = "quotes/2020-02-20_BTCUSDT.csv.gz";
#[allow(dead_code)]
//binance-futures,BTCUSDT,1582070402288000,1582070403564191,41370304,buy,10175.48,0.018
static CSV_PATH_TRADES: &str = "trades/2020-02-20_BTCUSDT.csv.gz";


fn main() {
    let mut p = Producer::new(CSV_PATH_TRADES, CSV_PATH_QUOTES);
    let mut counter: i16 = 0;
    while let Some(t) = p.next_tick() {
        counter += 1;
    }
    println!("{:?} {:?}", p._next_trade_tick, p._next_quote_tick)
}
