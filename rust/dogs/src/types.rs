#[derive(Clone, Debug, PartialEq, uniffi::Object)]
pub struct DogBreedList {
    pub breeds: Vec<String>,
}
