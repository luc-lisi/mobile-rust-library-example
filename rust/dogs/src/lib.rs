mod fetch;
mod types;

use fetch::{fetch_dog_by_breed, fetch_dog_list};
use types::DogBreedList;

uniffi::setup_scaffolding!();

#[uniffi::export]
fn list_dogs() -> DogBreedList {
    let mut breed_list = vec![];
    let result = fetch_dog_list();
    match result {
        Ok(v) => {
            println!("Got some dogs! {:?}", v.message.keys());

            for breed in v.message.into_keys() {
                breed_list.push(breed);
            }
            DogBreedList { breeds: breed_list }
        }
        Err(e) => {
            eprintln!(
                "Something went wrong while attempting to get dog breeds: {:?}",
                e
            );
            DogBreedList { breeds: vec![] }
        }
    }
}

#[uniffi::export]
fn get_dog(dog_breed: &str) -> String {
    let result = fetch_dog_by_breed(dog_breed);
    match result {
        Ok(v) => v.message,
        Err(e) => {
            eprintln!(
                "Something went wrong while attempting to get a picture for {:?} breed: {:?}",
                dog_breed, e
            );
            String::from("Not Found")
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::list_dogs;

    #[test]
    fn list_dogs_test() {
        let dog_breed_list = list_dogs().breeds;

        assert!(!dog_breed_list.is_empty());
        assert!(dog_breed_list.contains(&String::from("bulldog")));
        assert!(dog_breed_list.contains(&String::from("leonberg")));
        assert!(dog_breed_list.contains(&String::from("dane")));
    }
}
