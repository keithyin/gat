use std::{collections::HashMap, fs, ops::Deref, path::Path, sync::Arc};

use axum::{Json, Router, extract::State, http::Method, routing::{post, get}};
use clap::Parser;
use cli::Cli;
use mm2::gskits::fastx_reader::{fasta_reader::FastaFileReader, read_fastx};
use serde::{Deserialize, Serialize};
use tokio;
use toolkits::{msa::generate_aligned_bam, pair_alignment};
use tower_http::{
    cors::{Any, CorsLayer},
    services::ServeDir,
};

mod cli;
pub mod toolkits;
pub mod utils;

fn get_ref_genomes(genomes_dir: Option<&str>) -> Option<HashMap<String, String>> {
    if let Some(p) = genomes_dir {
        let mut key2ref = HashMap::new();

        let path = Path::new(p);

        // 遍历目录中的所有文件
        if path.is_dir() {
            for entry in fs::read_dir(path).unwrap() {
                let entry = entry.unwrap();
                let file_name = entry.file_name(); // 获取文件名
                let file_name = file_name.to_str().unwrap().to_string();
                assert!(
                    file_name.ends_with("fa")
                        || file_name.ends_with("fasta")
                        || file_name.ends_with("fna")
                );
                let key = file_name.rsplit_once(".").unwrap().0;

                let reader = FastaFileReader::new(entry.path().to_str().unwrap().to_string());
                let targets = read_fastx(reader);
                let seq = targets[0].seq.clone();
                key2ref.insert(key.to_string(), seq);
            }
        } else {
            println!("The specified path is not a directory.");
        }

        Some(key2ref)
    } else {
        None
    }
}

#[derive(Deserialize, Serialize)]
pub struct GetRefGenomesResp {
    result: Vec<String>,
}
async fn get_ref_genomes_handler(
    State(ref_genomes): State<Arc<Option<HashMap<String, String>>>>,
) -> Json<GetRefGenomesResp> {
    let mut resp = GetRefGenomesResp { result: vec![] };

    if ref_genomes.is_some() {
        resp.result = ref_genomes
            .deref()
            .as_ref()
            .unwrap()
            .keys()
            .map(|v| v.to_string())
            .collect::<_>();
    }

    Json(resp)
}

#[tokio::main]
async fn main() {
    let cli = Cli::parse();

    let ref_genomes = get_ref_genomes(cli.genomes_dir.as_ref().map(|v| v.as_str()));
    let ref_genomes = Arc::new(ref_genomes);

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods([Method::GET, Method::POST])
        .allow_headers(Any);

    // build our application with a single route

    let static_files =
        ServeDir::new("/data/web-server/toolkits-of-rocyin").append_index_html_on_directories(true);

    let app = Router::new()
        .fallback_service(static_files)
        .route("/pair_align", post(pair_alignment::pair_alignment))
        .route(
            "/align_to_ref_genome",
            post(pair_alignment::pair_alignment_with_ref_genome),
        )
        .route("/ref_genomes", get(get_ref_genomes_handler))
        .route("/msa/generate_aligned_bam", post(generate_aligned_bam))
        .with_state(ref_genomes)
        .layer(cors);

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:40724")
        .await
        .unwrap();
    axum::serve(listener, app).await.unwrap();
}
