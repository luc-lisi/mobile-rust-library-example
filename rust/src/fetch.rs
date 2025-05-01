use reqwest::blocking;

pub struct PicSumRequest {
    width_px: u16,
    height_px: u16,
}

pub struct PicSumResponse {
    image_url: String,
}

// We want to expose this function
pub fn get_image(width_px: &u16, height_px: &u16) {
    let request = PicSumRequest {
        width_px: width_px.clone(),
        height_px: height_px.clone(),
    };
    get_from_picsum(request);
}

fn get_from_picsum(request: PicSumRequest) -> Result<String, reqwest::Error> {
    let picsum_url = "https://picsum.photos";

    println!(
        "Requesting image of size {}x{}px from Picsum",
        &request.width_px, &request.height_px
    );

    let formatted_string = format_picsum_url(picsum_url, request);
    let body = reqwest::blocking::get(formatted_string)?.text()?;
    println!("body = {body:?}");
    Ok(body)
}

fn format_picsum_url(base_url: &str, request: PicSumRequest) -> String {
    format!("{}/{}/{}", base_url, &request.width_px, &request.height_px)
}
