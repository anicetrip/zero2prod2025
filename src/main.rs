use zero2prod2025::run;

#[tokio::main]
async fn main() -> Result<(), std::io::Error> {
    run()?.await
}