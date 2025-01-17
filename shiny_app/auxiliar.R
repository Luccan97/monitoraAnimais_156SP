# <a href="https://www.flaticon.com/free-icons/bat" title="bat icons">Bat icons created by Freepik - Flaticon</a>
# <a href="https://www.flaticon.com/free-icons/scorpion" title="scorpion icons">Scorpion icons created by Freepik - Flaticon</a>
# <a href="https://www.flaticon.com/free-icons/pigeon" title="pigeon icons">Pigeon icons created by Fir3Ghost - Flaticon</a>
# <a href="https://www.flaticon.com/free-icons/mouse" title="mouse icons">Mouse icons created by Icongeek26 - Flaticon</a>

# Carregar dados
df2 <- readRDS("data/df_final.RDS") %>% 
        filter(!is.na(Longitude) & !is.na(Latitude)) %>% 
        mutate(Latitude = as.numeric(Latitude),
               Longitude = as.numeric(Longitude),
               Data = as.Date(Data),
               Mes = floor_date(Data, "month"))


# write.csv(df2, "df_points.csv", row.names = F)
# Gerar lista de meses para o slider
meses <- seq.Date(from = min(df2$Mes), to = max(df2$Mes), by = "month")
meses_formatados <- format(meses, "%b %Y")

choices_labels <- setNames(unique(df2$Serviço), unique(df2$desc))

da_shp <-  readRDS("data/SIRGAS_SHP_distrito_simplified.rds") 

  
   
st_crs(da_shp) <- 31983

da_shp <- st_transform(da_shp, crs = 4326)

painel_info <-  tabPanel("Mais informações",
                         fluidRow(
                                 column(1),
                                 column(10,
                                        HTML("<br>"),
                                        
                                        h4("Importância dos Animais Sinantrópicos para a Saúde Pública", style = "text-align:center;color:#1B4F72;text-size:15px"),
                                        p("Pombos, morcegos, ratos e escorpiões são considerados animais sinantrópicos, eles se adaptaram a viver em ambientes urbanos e próximos aos humanos. Esses animais podem representar um risco significativo à saúde pública, pois são capazes de transmitir diversas doenças. Na cidade de São Paulo, a Divisão de Vigilância de Zoonoses (DVZ), que faz parte da Coordenadoria de Vigilância em Saúde (Covisa) da Secretaria Municipal da Saúde (SMS), é responsável pelo controle e orientação em relação aos animais sinantrópicos."),
                                        
                                        h5(tags$b(tags$span(style = "color:#1B4F72;", "Pombos"))),
                                        p("Pombos são aves que se adaptaram bem aos centros urbanos. Eles podem hospedar parasitas como bactérias e fungos que causam doenças como criptococose, histoplasmose e ornitose. As fezes de pombos, quando secas e contaminadas, podem ser inaladas e transmitir essas doenças. A alimentação fornecida por pessoas em locais públicos contribui para o aumento da população de pombos.",
                                          # actionLink("pombo_ref", "Artigos sugeridos")
                                          ),
                                        bsModal("modal_pombo", "Sugestões de Artigos Científicos - Pombos", "pombo_ref", size = "large",
                                                p("1. Haider et al. (2016). DOI: https://doi.org/10.1007/s10393-016-1130-x"),
                                                p("2. Outro artigo relevante..."),
                                                p("3. Mais um artigo...")),
                                        
                                        h5(tags$b(tags$span(style = "color:#1B4F72;", "Morcegos"))),
                                        p("Os morcegos são os únicos mamíferos capazes de voar e vivem tanto em áreas rurais quanto urbanas. Ativos durante a noite, são protegidos por lei devido à sua importância ecológica: controlam insetos noturnos e dispersam sementes e frutos, ajudando na recuperação de áreas degradadas. Importante destacar que os morcegos hematófagos não vivem em ambientes urbanos.

Todas as espécies de morcegos podem transmitir doenças aos humanos e animais, como a raiva, disseminada principalmente por mordidas de mamíferos infectados, e a histoplasmose, contraída pela inalação de fungos presentes nas fezes de morcegos em locais fechados. Eles costumam se abrigar em forros, porões, lareiras, copas e cascas de árvores. Caso encontre um morcego, vivo ou morto, no chão, não o toque e contate a Central 156 para que profissionais especializados façam a remoção.",
                                          # actionLink("morcego_ref", "Artigos sugeridos")
),
                                        bsModal("modal_morcego", "Sugestões de Artigos Científicos - Morcegos", "morcego_ref", size = "large",
                                                p("1. Calisher et al. (2006). DOI: https://doi.org/10.3201/eid1204.051201"),
                                                p("2. Outro artigo relevante..."),
                                                p("3. Mais um artigo...")),
                                        
                                        h5(tags$b(tags$span(style = "color:#1B4F72;", "Escorpiões"))),
                                        p("Em São Paulo, três tipos de escorpiões são considerados importantes para a saúde pública: o escorpião amarelo, o amarelo nordestino e o marrom. As picadas dessas espécies podem ser particularmente graves para crianças e idosos. Esses escorpiões são encontrados em áreas verdes, parques, cemitérios, terrenos abandonados, linhas de trem, esgotos, bueiros, materiais de construção, entulhos e margens de córregos.

Sendo animais noturnos, os escorpiões são mais ativos durante a primavera e o verão, e costumam se alimentar principalmente de baratas. Para prevenir acidentes, é crucial manter as áreas externas limpas e livres de entulhos, vedar rachaduras em paredes, muros e pisos, e proteger seus predadores naturais, como louva-a-deus, sapos, corujas, gaviões e lagartixas.",
                                          # actionLink("escorpiao_ref", "Artigos sugeridos")
),
                                        bsModal("modal_escorpiao", "Sugestões de Artigos Científicos - Escorpiões", "escorpiao_ref", size = "large",
                                                p("1. Chippaux et al. (2012). DOI: https://doi.org/10.1016/j.toxicon.2012.05.021"),
                                                p("2. Outro artigo relevante..."),
                                                p("3. Mais um artigo...")),
                                        
                                        h5(tags$b(tags$span(style = "color:#1B4F72;", "Ratos"))),
                                        p("Ratos são roedores altamente adaptáveis que vivem próximos aos humanos e representam um grande risco à saúde pública. Eles podem transmitir doenças como leptospirose, peste bubônica, tifo murino, salmonelose e hantavirose. Ratos contaminam o ambiente com urina, fezes e pelos.",
                                          # actionLink("rato_ref", "Artigos sugeridos")
                                          ),
                                        bsModal("modal_rato", "Sugestões de Artigos Científicos - Ratos", "rato_ref", size = "large",
                                                p("1. Himsworth et al. (2013). DOI: https://doi.org/10.1016/j.ttbdis.2013.02.001"),
                                                p("2. Outro artigo relevante..."),
                                                p("3. Mais um artigo...")),
                                        
                                        p("Fonte: [Animais Sinantrópicos - Saiba Quais São os Principais e as Doenças que Transmitem](https://www.capital.sp.gov.br/w/noticia/animais-sinantropicos-saiba-quais-sao-os-principais-e-as-doencas-que-transmitem)")
                                 )
                                 )
                         )
