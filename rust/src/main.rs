mod fetch;

fn main() {
    let width = 500;
    let height = 600;
    fetch::get_image(&width, &height)
}
