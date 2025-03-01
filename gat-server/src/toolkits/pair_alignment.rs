use std::{collections::HashMap, ops::Deref, sync::Arc};

use axum::{extract::State, Json};

use crate::utils::dna::reverse_complement;
use lazy_static::lazy_static;
use mm2::{
    build_aligner,
    gskits::{
        ds::ReadInfo,
        fastx_reader::{fasta_reader::FastaFileReader, read_fastx},
    },
    mapping_ext::MappingExt,
    params::{AlignParams, IndexParams, MapParams, OupParams},
};
use serde::{Deserialize, Serialize};

lazy_static! {
    static ref REF_GENOME: HashMap<String, String> = {
        let ecoli_reader = FastaFileReader::new("/data/REF_GENOMES/MG1655.fa".to_string());
        let ecoli_targets = read_fastx(ecoli_reader);

        let sa_reader = FastaFileReader::new(
            "/data/REF_GENOMES/ref_Saureus_ATCC25923.m.new.corrected.fasta".to_string(),
        );
        let sa_targets = read_fastx(sa_reader);

        let mut ref_genome = HashMap::new();
        ref_genome.insert("ecoli".to_string(), ecoli_targets[0].seq.clone());
        ref_genome.insert("sa".to_string(), sa_targets[0].seq.clone());

        ref_genome
    };
}

#[derive(Deserialize)]
pub struct PairAlignParam {
    query: String,
    target: String,
}

#[derive(Deserialize, Serialize)]
pub struct PairAlignResp {
    result: Vec<Vec<String>>,
}

pub async fn pair_alignment(Json(payload): Json<PairAlignParam>) -> Json<PairAlignResp> {
    // println!("req:query{}\ntarget:{}", payload.query, payload.target);
    let resp = pair_align_core(payload, None);
    resp
}

pub async fn pair_alignment_with_ref_genome(
    State(ref_genomes): State<Arc<Option<HashMap<String, String>>>>,
    Json(mut payload): Json<PairAlignParam>,
) -> Json<PairAlignResp> {
    let ref_genomes = ref_genomes.deref().as_ref().unwrap();
    let target_name = payload.target.clone();
    let target_seq = ref_genomes.get(&payload.target).unwrap().clone();
    payload.target = target_seq;
    pair_align_core(payload, Some(target_name))
}

pub fn pair_align_core(
    payload: PairAlignParam,
    target_name: Option<String>,
) -> Json<PairAlignResp> {
    let payload = PairAlignParam {
        query: payload.query.replace("\0", ""),
        target: payload.target.replace("\0", ""),
    };

    let target_name = target_name.unwrap_or("unk".to_string());
    let preset = "map-ont";
    let index_args = IndexParams::default();
    let map_args = MapParams::default();
    let align_args = AlignParams::default();
    let oup_args = OupParams::default();
    let targets = vec![ReadInfo::new_fa_record(target_name.clone(), payload.target)];
    let mut target_idx = HashMap::new();
    target_idx.insert(target_name.clone(), (0, targets[0].seq.len()));

    let query = ReadInfo::new_fa_record("query".to_string(), payload.query);

    let mut aligners = build_aligner(
        preset,
        &index_args,
        &map_args,
        &align_args,
        &oup_args,
        &targets,
        1,
    );
    aligners.iter_mut().for_each(|aligner| {
        aligner.mapopt.best_n = 10000;
        aligner.mapopt.pri_ratio = 0.2;
    });
    let aligner = &aligners[0];

    let mut hits = aligner
        .map(
            query.seq.as_bytes(),
            false,
            false,
            None,
            Some(&[67108864, 68719476736]),
            Some(b"query"),
        )
        .unwrap();
    hits.sort_by_key(|hit| hit.query_start);

    let resp = hits
        .iter()
        .map(|record| {
            let hit_ext = MappingExt(record);
            let (ref_aligned, query_aligned) =
                hit_ext.aligned_2_str(targets[0].seq.as_bytes(), query.seq.as_bytes());
            let rev = hit_ext.is_rev();

            let (ref_start, ref_end) = if rev {
                (hit_ext.target_end, hit_ext.target_start)
            } else {
                (hit_ext.target_start, hit_ext.target_end)
            };

            let (ref_aligned, query_aligned) = if rev {
                (
                    reverse_complement(ref_aligned.as_str()),
                    reverse_complement(query_aligned.as_str()),
                )
            } else {
                (ref_aligned, query_aligned)
            };

            let (ref_aligned, query_aligned) = (
                ref_aligned.replace("\0", ""),
                query_aligned.replace("\0", ""),
            );
            assert_eq!(ref_aligned.len(), query_aligned.len());

            let q_start = hit_ext.query_start;
            let q_end = hit_ext.query_end;
            let ref_tag = format!("target:{}-{}; rev:{}", ref_start, ref_end, rev);
            let query_tag = format!(
                "query:{}-{}; identity:{:.2}%",
                q_start,
                q_end,
                hit_ext.identity() * 100.
            );
            vec![ref_aligned, query_aligned, ref_tag, query_tag]
        })
        .collect::<Vec<_>>();
    let resp = PairAlignResp { result: resp };
    Json(resp)
}
