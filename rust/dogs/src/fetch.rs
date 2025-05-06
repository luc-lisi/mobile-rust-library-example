use reqwest::Error;
use std::collections::HashMap;

#[derive(Debug, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct FetchDogListResponse {
    pub message: HashMap<String, Box<[String]>>,
}

pub fn fetch_dog_list() -> Result<FetchDogListResponse, Error> {
    let dog_breed_response: FetchDogListResponse =
        reqwest::blocking::get("https://dog.ceo/api/breeds/list/all")?.json()?;
    Ok(dog_breed_response)
}
