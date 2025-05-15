#[derive(Clone, Debug, PartialEq, uniffi::Object)]
pub struct DogBreedList {
    pub breeds: Vec<String>,
}

#[uniffi::export]
impl DogBreedList {
    pub fn get_breeds(&self) -> Vec<String> {
        self.breeds.clone()
    }
}
