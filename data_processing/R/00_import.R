# Load packages -------------------------------------------------------------------------
pacman::p_load(
        openxlsx,
        readxl,
        tidyverse
)

# Import data -------------------------------------------------------------

# Obtenha a lista de arquivos XLSX na pasta
file_paths <- list.files(path = "../data/raw", pattern = "*.xlsx", full.names = TRUE)

# Função para renomear e selecionar colunas específicas
clean_rename_and_filter_data <- function(df) {
        # Renomeie a primeira coluna para "Data"
        colnames(df)[1] <- "Data"
        
        # Verifique se todas as colunas têm nomes válidos
        colnames(df) <- make.names(colnames(df), unique = TRUE)
        
        # Selecionar as colunas desejadas
        desired_columns <- c("Data", "Assunto", "Serviço", "Latitude", "Longitude")
        
        # Selecionar e filtrar os dados
        df_filtered <- df %>% 
                select(all_of(desired_columns)) %>%
                filter(Assunto == "Animais que transmitem doenças ou risco à saúde") %>% 
                filter(grepl("Ratos|Morcegos|Escorpião|Pombos",`Serviço`, ignore.case = TRUE))
        
        # Função para limpar e converter Latitude e Longitude
        clean_convert_numeric <- function(column) {
                column <- gsub(",", ".", column) # Substituir vírgulas por pontos
                column <- gsub("[^0-9.-]", "", column) # Remover caracteres não numéricos
                column <- as.numeric(column)
                return(column)
        }
        
        # Converter Latitude e Longitude para numeric se forem character
        if (is.character(df_filtered$Latitude)) {
                df_filtered <- df_filtered %>%
                        mutate(Latitude = clean_convert_numeric(Latitude))
        }
        if (is.character(df_filtered$Longitude)) {
                df_filtered <- df_filtered %>%
                        mutate(Longitude = clean_convert_numeric(Longitude))
        }
        
        return(df_filtered)
}

# Função para ler, limpar, renomear, filtrar e combinar os dados com feedback de progresso
read_clean_rename_filter_and_bind <- function(files) {
        total_files <- length(files)
        data_list <- vector("list", total_files)
        
        for (i in seq_along(files)) {
                cat("\nLendo e filtrando arquivo", i, "de", total_files, ":", files[i], "\n")
                tryCatch({
                        df <- read_excel(files[i], .name_repair = "minimal")
                        names(df) <- trimws(names(df)) # remove espaços
                        
                        # Força a conversão da coluna "Data" para POSIXct se ela existir
                        if ("Data" %in% names(df)) {
                                cat("Classe original da coluna 'Data':", class(df$Data), "\n")
                                df$Data <- tryCatch({
                                        if (inherits(df$Data, "POSIXct")) {
                                                df$Data
                                        } else if (is.numeric(df$Data)) {
                                                as.POSIXct(df$Data, origin = "1899-12-30", tz = "UTC")
                                        } else if (is.character(df$Data)) {
                                                as.POSIXct(df$Data, format = "%Y-%m-%d", tz = "UTC")
                                        } else {
                                                stop("Tipo de 'Data' não conversível.")
                                        }
                                }, error = function(e) {
                                        cat("Erro ao converter coluna 'Data':", e$message, "\n")
                                        df$Data <- NA  # ou NULL para remover
                                        df
                                })
                                cat("Nova classe da coluna 'Data':", class(df$Data), "\n")
                        } else {
                                cat("Coluna 'Data' não encontrada.\n")
                        }
                        
                        # Verifica Latitude e Longitude
                        if ("Latitude" %in% colnames(df) & "Longitude" %in% colnames(df)) {
                                cat("Classe de Latitude:", class(df$Latitude), "\n")
                                cat("Classe de Longitude:", class(df$Longitude), "\n")
                                
                                perc_na_lat_before <- mean(is.na(df$Latitude)) * 100
                                perc_na_long_before <- mean(is.na(df$Longitude)) * 100
                                cat("Percentual de NAs em Latitude antes da conversão:", perc_na_lat_before, "%\n")
                                cat("Percentual de NAs em Longitude antes da conversão:", perc_na_long_before, "%\n")
                                
                                df_clean_filtered <- clean_rename_and_filter_data(df)
                                
                                perc_na_lat_after <- mean(is.na(df_clean_filtered$Latitude)) * 100
                                perc_na_long_after <- mean(is.na(df_clean_filtered$Longitude)) * 100
                                cat("Percentual de NAs em Latitude após a conversão:", perc_na_lat_after, "%\n")
                                cat("Percentual de NAs em Longitude após a conversão:", perc_na_long_after, "%\n")
                        } else {
                                cat("As colunas Latitude ou Longitude não estão presentes no arquivo.\n")
                                df_clean_filtered <- clean_rename_and_filter_data(df)
                        }
                        
                        data_list[[i]] <- df_clean_filtered
                }, error = function(e) {
                        cat("Erro ao ler e processar o arquivo:", files[i], "\n", e$message, "\n")
                })
        }
        
        # Validação final: forçar todas as colunas "Data" a POSIXct (inclusive se limpou depois)
        data_list <- lapply(data_list, function(df) {
                if ("Data" %in% names(df)) {
                        if (!inherits(df$Data, "POSIXct")) {
                                df$Data <- tryCatch({
                                        if (is.numeric(df$Data)) {
                                                as.POSIXct(df$Data, origin = "1899-12-30", tz = "UTC")
                                        } else if (is.character(df$Data)) {
                                                as.POSIXct(df$Data, format = "%Y-%m-%d", tz = "UTC")
                                        } else {
                                                as.POSIXct(NA)
                                        }
                                }, error = function(e) {
                                        cat("Erro forçando POSIXct em bind: ", e$message, "\n")
                                        as.POSIXct(NA)
                                })
                        }
                }
                return(df)
        })
        
        cat("\nVerificando classes finais da coluna 'Data':\n")
        print(sapply(data_list, function(df) class(df$Data)))
        
        bind_rows(data_list)
}



# Leia, limpe, renomeie, filtre e combine todos os arquivos XLSX em um único DataFrame
combined_data <- read_clean_rename_filter_and_bind(file_paths)

# Exportar dados combinados para iniciar a limpeza
saveRDS(combined_data, "../data/clean/animais_156SP.RDS")
