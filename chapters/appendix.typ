= OMT vágások kiszámítása <omt_split>

// #let todo_counter = counter("__todo__")

// #let list_todos() = context [
//   #for i in range(0, todo_counter.final().at(0)) [
//     #link(label("__todo__" + str(i)), "click")
//   ]
// ]

// #list_todos()

// #let todo(body) = context [
//   #text(red, body)
//   #label("__todo__" + str(todo_counter.get().at(0)))
//   #todo_counter.step()
// ]

// #todo[a]

// #todo[b]

// #todo[c]

// #context todo_counter.final()

Az OMT a szinteket "felülről-lefelé" építi fel, de egy adott szinten a vágásokat
"alulról-felfelé" számoljuk ki a következő módon:
```rust
fn calculate_splits(
    node_count: usize, // a létrehozandó csúcsok száma
    item_count: usize, // a szétosztandó elemek száma
    dimensions: usize, // a dimenziók száma
) -> Vec<Vec<usize>> {
    // vágások listája, minden vágás részei tartalmazzák,
    // hogy hány elemet tartalmaznak
    // 
    // igazából csak dimensions vágásunk lesz,
    // de az algoritmusban a kezdőállapotot is egy vágásnak tekintjük
    let mut splits = Vec::with_capacity(dimensions + 1);
    // a kezdőállapotot hozzáadjuk a vágások listájához
    // a kezdő vágás minden része 1 elemet tartalmaz
    splits.push(vec![1; item_count]);
    for dim in 0..dimensions {
        // vesszük az előző vágást
        let last = splits.last().unwrap();
        // kiszámoljuk, hogy a jelenlegi dimenzió
        // szerint hány részre kell vágni
        let chunk_count = (node_count as f64)
            .powf((dimensions - dim) as f64 / dimensions as f64)
            .round() as usize;
        // az előző vágás nem garantáltan bontható egyenlő részekre,
        // ezért kiszámoljuk a kisebb és a nagyobb részek méretét
        let small_size = last.len() / chunk_count;
        let large_size = small_size + 1;
        // nagyobb részből annyi van,
        // ahány az előző részekből marad az egyenlőre osztás után
        let large_count = last.len() % chunk_count;
        let small_count = chunk_count - large_count;
        // számon tartja, hogy eddig hány részt használtunk
        let mut i = 0;
        let new_split = iter::empty()
            .chain(iter::repeat(small_size).take(small_count))
            .chain(iter::repeat(large_size).take(large_count))
            .map(|c| {
                // a last-ból c rész összevonásával kapjuk meg az új részt
                let res = last[i..][..c].iter().sum();
                i += c;
                res
            })
            .collect();
        // az új vágást hozzáadjuk a vágásokhoz,
        // a következő iterációban ez lesz az utolsó vágás
        splits.push(new_split);
    }
    // a vágások listáját meg kell fordítani,
    // mert alulról-felfele építettük fel,
    // de felülről-lefelé fogjuk végrehajtani a vágásokat
    splits.reverse();
    // a kezdő vágást kitöröljük, mert arra nincs szükség
    splits.pop();
    splits
}
```
