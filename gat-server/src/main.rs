use axum::{
    http::{Method, StatusCode}, routing::{get, post}, Router, ServiceExt
};
use tokio;
use toolkits::pair_alignment;
use tower_http::{cors::{Any, CorsLayer}, services::{self, ServeDir}};

pub mod toolkits;
pub mod utils;

#[tokio::main]
async fn main() {
    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods([Method::GET, Method::POST])
        .allow_headers(Any);

    // build our application with a single route

    let static_files = ServeDir::new("/data/web-server/toolkits-of-rocyin").append_index_html_on_directories(true);

    let app = Router::new()
        .fallback_service(static_files)
        .route("/pair_align", post(pair_alignment::pair_alignment))
        .route("/align_to_ref_genome", post(pair_alignment::pair_alignment_with_ref_genome))
        .layer(cors);

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:40724")
        .await
        .unwrap();
    axum::serve(listener, app).await.unwrap();
}
