

use axum::Json;
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
pub struct GenerateAlignedBamReq {
    ref_file: String,
    sbr_bam: String,
    cs_bam: String
}


#[derive(Deserialize, Serialize)]
pub struct GenerateAlignedBamResp {
    aligned_bam: String
}
pub async fn generate_aligned_bam(Json(req): Json<GenerateAlignedBamReq>) -> Json<GenerateAlignedBamResp>{
    let mut resp = GenerateAlignedBamResp{aligned_bam:"".to_string()};

    

    Json(resp)

}