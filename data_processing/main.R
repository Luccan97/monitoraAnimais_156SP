# main.R - Script para executar todo o pipeline data_processing

# ------------------- Função para checar pacotes -------------------
check_packages <- function(packages) {
        new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
        if(length(new_packages)) install.packages(new_packages)
        invisible(lapply(packages, library, character.only = TRUE))
}

# Pacotes essenciais
check_packages(c("openxlsx", "readxl", "tidyverse", "sf", "rmapshaper", "readr"))

# ------------------- Criar pastas necessárias -------------------
dir.create("../data/clean", showWarnings = FALSE, recursive = TRUE)

# ------------------- Rodar 00_import.R -------------------
cat("🔍 Etapa 1: Importação e pré-processamento...\n")

if (length(list.files("../data/raw", pattern = "*.xlsx")) > 0) {
        source("R/00_import.R")
        cat("✅ Dados importados e salvos em ../data/clean/animais_156SP.RDS\n")
} else {
        stop("⚠️ Nenhum arquivo .xlsx encontrado em ../data/raw.")
}

# ------------------- Rodar 01_process.R -------------------
cat("🔍 Etapa 2: Processamento dos dados...\n")

if (file.exists("../data/clean/animais_156SP.RDS")) {
        source("R/01_process.R")
        cat("✅ Dados processados e salvos em ../data/clean/df_final.RDS e semGeolocalização.RDS\n")
} else {
        stop("⚠️ O arquivo ../data/clean/animais_156SP.RDS não foi encontrado.")
}

# ------------------- Rodar 02_prepare_shapefile.R -------------------
cat("🔍 Etapa 3: Preparação do shapefile...\n")

if (file.exists("../data/raw/SIRGAS_SHP_distrito/SIRGAS_SHP_distrito.shp")) {
        source("R/02_prepare_shapefile.R")
        cat("✅ Shapefile simplificado e salvo em ../data/clean/SIRGAS_SHP_distrito_simplified.rds\n")
} else {
        stop("⚠️ O shapefile de distritos não foi encontrado em ../data/raw/SIRGAS_SHP_distrito.")
}

cat("🎉 Pipeline finalizado com sucesso!\n")
