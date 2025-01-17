
# Script para limpeza e tratamento dos dados importados -------------------

df <- readRDS("../data/clean/animais_156SP.RDS")

# Função para extrair o nome do animal
extract_animal_name <- function(servico) {
        str_extract(servico, "^[^ -]+( [^ -]+)?")
}

# Aplicar a transformação
df2 <- df %>%
        mutate(desc = Serviço) %>% 
        mutate(Serviço = extract_animal_name(Serviço)) %>% 
        filter(
                Latitude >= -24.0081 & Latitude <= -23.3569,
                Longitude >= -46.8256 & Longitude <= -46.3659
        )



semGeo <- df2 %>% 
        filter(is.na(Longitude) | is.na(Latitude)) %>% 
        group_by(Serviço) %>% 
        summarise(n = n())

saveRDS(df2, "../data/clean/df_final.RDS")
saveRDS(df2, "../shiny_app/data/df_final.RDS")
saveRDS(semGeo, "../data/clean/semGeolocalização.RDS")




