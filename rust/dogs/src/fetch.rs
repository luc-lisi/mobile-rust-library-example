use reqwest::Error;
use std::collections::HashMap;

#[derive(Debug, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct FetchDogListResponse {
    pub message: HashMap<String, Box<[String]>>,
}

#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub struct FetchDogResponse {
    pub message: String,
}

pub fn fetch_dog_list() -> Result<FetchDogListResponse, Error> {
    let dog_breed_response: FetchDogListResponse =
        reqwest::blocking::get("https://dog.ceo/api/breeds/list/all")?.json()?;
    Ok(dog_breed_response)
}

pub fn fetch_dog_by_breed(breed_name: &str) -> Result<FetchDogResponse, Error> {
    let dog_response: FetchDogResponse = reqwest::blocking::get(format!(
        "https://dog.ceo/api/breed/{}/images/random",
        breed_name
    ))?
    .json()?;
    Ok(dog_response)
}
