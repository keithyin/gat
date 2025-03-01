use clap::{self, Args, Parser};

#[derive(Debug, Parser, Clone)]
#[command(version, about, long_about=None)]
pub struct Cli {
    #[arg(long = "genomes_dir")]
    pub genomes_dir: Option<String>,
}
