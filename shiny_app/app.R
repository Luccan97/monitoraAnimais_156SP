# Carregar pacotes
pacman::p_load(shiny, leaflet, leaflet.extras2, lubridate, tidyverse, sf, shinydashboard, 
               shinyWidgets, shinycssloaders, shinyBS)

source("auxiliar.R")

# Definir UI
ui <- fluidPage(
  includeCSS("www/styles.css"),
  fluidRow(
    column(width = 11,
      h2("Monitoramento de animais sinantrópicos via atendimento ao cidadão 156 SP",
     style = "text-align: center; font-weight: bold; color: #1B4F72;")
     ),
  
  column(width = 1, actionButton("showHexbinInfo", "?", 
                                 style = "background-color:coral; color:white ; margin-top: 0px;"))),
        div(class = "main-container",
            div(class = "control-panel",
                # column(width = 1, offset = 0, style='padding:0px;color:#EAF2F8'),
                column(width = 4,
                       selectInput("servico", "Selecione o assunto da solicitação:", 
                                   choices = setNames(unique(df2$Serviço), unique(df2$desc)), 
                                   selected = unique(df2$Serviço)[1])),
                # column(width = 1, offset = 0, style='padding:0px;'),
                column(width = 4,
                       dateRangeInput("date_range", "Selecione o Intervalo de datas:",
                                      start = min(df2$Data),
                                      end = max(df2$Data),
                                      min = min(df2$Data),
                                      max = max(df2$Data),
                                      format = "dd-mm-yyyy",
                                      separator = " até ")),
                column(width = 2, valueBoxOutput("num_observations_box", width = NULL)),
                column(width = 2, imageOutput("service_image", height = "20px"))
            ),
            div(class = "map-container",
                tabsetPanel(
                        tabPanel("Mapas", 
                                 fluidRow(
             
                                         column(width = 12, withSpinner(leafletOutput("map", height = 550), color = "#1B4F72")),  
                                 )),
                        painel_info
                )
            )
        )
)

# Definir lógica do servidor
server <- function(input, output, session) {
        addResourcePath("www", "www")
        
        filteredData <- reactive({
                req(input$date_range)
                df2 %>%
                        filter(Serviço == input$servico,
                               Data >= input$date_range[1] & Data <= input$date_range[2],
                               !is.na(Latitude) & !is.na(Longitude))
        })
        
        output$map <- renderLeaflet({
                leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
                        addProviderTiles(providers$Esri.WorldImagery) %>%
                        setView(lng = -46.681, lat = -23.687, zoom = 9.5) %>%
                        addLayersControl(
                                overlayGroups = c("Contagem de pontos nos distritos",  "Cluster de pontos"),
                                options = layersControlOptions(collapsed = FALSE)
                        ) 
        })
        
        observe({
                data <- filteredData()
                points_sf <- st_as_sf(data, coords = c("Longitude", "Latitude"), crs = 4326)
                
                # Criação da camada coroplética
                da_shp$count <- sapply(st_intersects(da_shp, points_sf), length)
                da_shp$ds_nome <- ifelse(is.na(da_shp$ds_nome), "Desconhecido", as.character(da_shp$ds_nome))
                da_shp$count <- ifelse(is.na(da_shp$count), 0, as.numeric(da_shp$count))
                pal <- colorNumeric(RColorBrewer::brewer.pal(6, "Reds"), domain = da_shp$count)
                
                leafletProxy("map", data = da_shp) %>%
                        clearGroup("Contagem de pontos nos distritos") %>%
                        clearControls() %>%
                        addPolygons(
                                group = "Contagem de pontos nos distritos",
                                fillColor = ~pal(count),
                                color = "#444444",
                                weight = .2,
                                smoothFactor = 0.5,
                                opacity = 1.0,
                                fillOpacity = 0.7,
                                highlightOptions = highlightOptions(
                                        color = "#1B4F72",
                                        weight = 2,
                                        bringToFront = TRUE
                                ),
                                popup = ~paste0(
                                        "<b>Distrito:</b> ", str_to_title(as.character(ds_nome)),
                                        "<br><b>Solicitações sobre ", input$servico, ":</b> ", as.character(count),
                                        "<br><b>Intervalo de data:</b> ", format(input$date_range[1], "%d-%m-%Y"), " até ", format(input$date_range[2], "%d-%m-%Y")
                                ),
                                label = ~lapply(paste0(
                                        "<div style='font-size: 16px;'><b>Distrito:</b> ", str_to_title(as.character(ds_nome)),
                                        "<br><b>Solicitações sobre ", input$servico, ":</b> ", as.character(count),
                                        "<br><b>Intervalo de data:</b> ", format(input$date_range[1], "%d-%m-%Y"), " até ", format(input$date_range[2], "%d-%m-%Y"), "</div>"
                                ), htmltools::HTML)
                        ) 
                
                # Criação da camada de clusters
                leafletProxy("map", data = points_sf) %>%
                        clearGroup("Cluster de pontos") %>%
                        addMarkers(group = "Cluster de pontos", clusterOptions = markerClusterOptions(spiderfyOnMaxZoom = T),
                                   popup = ~paste0(
                                          
                                           "<br><b>", desc, ":</b> ", 
                                           "<br><b>Data da solicitação:</b> ", Data
                                   ))
        })
        
        output$num_observations_box <- renderValueBox({
                valueBox(
                        value = nrow(filteredData()), 
                        subtitle = "Solicitações", color = "light-blue"
                )
        })
        
        output$service_image <- renderImage({
                list(src = file.path("www", paste0(input$servico, ".png")),
                     contentType = "image/png", 
                     alt = input$servico,
                     class = "service-image")
        }, deleteFile = FALSE)
        
        # Mostrar modal ao iniciar
        showModal(modalDialog(
          title = "Informações Importantes sobre a Aplicação",
          p("Esta aplicação monitora solicitações de serviços relacionadas a animais de importância para a saúde pública no município de São Paulo, através do atendimento ao cidadão via 156.
     Os dados e o dicionário de dados estão disponíveis no ",
     a("Portal de Dados Abertos da Prefeitura de São Paulo", href = "http://dados.prefeitura.sp.gov.br/dataset/dados-do-sp156", target = "_blank"), "."),
     p("Nesta análise, focamos nas solicitações relacionadas a morcegos, pombos, ratos e escorpiões. Utilizando os filtros acima, você pode selecionar notificações específicas para cada um desses animais e ajustar o intervalo de datas."),
     p("É importante considerar que uma mesma ocorrência pode ter sido reportada várias vezes, resultando em duplicidade nos dados. Além disso, algumas solicitações não possuem informações de latitude e longitude, o que impede o georreferenciamento."),
     p("Este trabalho foi realizado por Lucca Nielsen, utilizando Shiny - R para criar uma ferramenta interativa e informativa gratuita."),
     p("Data da última atualização: 15/01/2025"),
     easyClose = TRUE,
     footer = tagList(
       actionButton("closeModal", "Fechar", class = "btn-primary")
     )
        ))
        
        observeEvent(input$closeModal, {
                removeModal()
        })
        
        # Exibir modal com informação sobre o mapa Hexbin
        observeEvent(input$showHexbinInfo, {
          showModal(modalDialog(
            title = "Como Interpretar os Mapas?",
            p("Esta aplicação oferece duas visualizações principais: Contagem de pontos nos distritos e Cluster de pontos."),
            p("Contagem de pontos nos distritos: Este mapa mostra a contagem total de solicitações de serviços relacionadas a animais dentro de cada distrito administrativo. A cor de cada polígono de distrito é determinada pelo número total de solicitações, com cores mais escuras indicando uma maior quantidade de solicitações."),
            p("Cluster de pontos: Este mapa permite a visualização dos pontos exatos indicados pelos solicitantes, agrupando-os em clusters para facilitar a visualização. À medida que você aumenta o zoom no mapa, os clusters se dividem em pontos individuais, permitindo uma análise mais detalhada das localizações específicas das solicitações."),
            p("Você pode alternar entre essas visualizações usando o controle de camadas no canto superior direito do mapa. É possível ativar ambas as visualizações simultaneamente."),
            p(strong("Qualquer dúvida, crítica ou sugestão, entre em contato com Lucca Nielsen através do "), 
              a("LinkedIn", href = "https://www.linkedin.com/in/lucca-nielsen-53b2a9181/", target = "_blank"), "."),
            easyClose = TRUE,
            footer = tagList(
              actionButton("closeHexbinInfo", "Fechar", class = "btn-primary")
            )
          ))
        })
        
        observeEvent(input$closeHexbinInfo, {
                removeModal()
        })
}

shinyApp(ui = ui, server = server)
