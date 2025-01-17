# monitoraAnimais_156SP
Este projeto é um aplicativo interativo desenvolvido com R e Shiny para monitorar solicitações de serviços relacionadas a animais sinantrópicos (ratos, morcegos, escorpiões e pombos) no município de São Paulo, por meio do canal de atendimento ao cidadão 156.

- **Link do app** [Clique aqui](https://lnielsen97.shinyapps.io/monitoraAnimais156SP/)    


 ## Estrutura das pastas

Para reproduzir e executar o aplicativo web, a pasta `data_processing` não é necessária. Ela foi incluída apenas para demonstrar o processo de importação e transformação dos dados. Caso deseje atualizar ou adicionar dados históricos, basta baixá-los no site da Prefeitura de São Paulo citado abaixo, colocá-los na pasta data/raw e rodar o script `main.R`.

```
monitoraAnimais_156SP/
├── data/                   # Armazena os dados brutos, processados e shapefiles
│   ├── raw/               # Dados brutos (.xlsx e .shp)
│   ├── clean/             # Dados limpos e processados (.RDS)
│   └── external/          # Arquivos geoespaciais (.shp)
├── data_processing/        # Scripts para processar e limpar dados
│   ├── R/
│   │   ├── 00_import.R    # Importação e limpeza inicial dos dados
│   │   ├── 01_process.R   # Processamento e filtragem de dados
│   │   └── 02_prepare_shapefile.R  # Preparação do shapefile simplificado
│   └── main.R             # Script principal para executar o pipeline de dados
shiny_app/
├── app.R              # Script principal do Shiny (UI e Server integrados)
├── auxiliar.R         # Funções auxiliares usadas no app
├── data/              # Dados processados utilizados pelo app
│   ├── df_final.RDS   # Dados filtrados e prontos para visualização
│   └── da_shp.rds     # Shapefile simplificado para mapas
└── www/               # Arquivos estáticos (CSS, imagens)
    ├── styles.css     # Estilos personalizados para o app
    └── (outros arquivos estáticos)  # Imagens ou outros recursos
└── README.md               # Documentação do projeto
```

## 📚 Fonte dos Dados

Os dados utilizados neste projeto foram obtidos do [Portal de Dados Abertos da Prefeitura de São Paulo](http://dados.prefeitura.sp.gov.br/dataset/dados-do-sp156).

- **Origem:** SP156 - Solicitações de serviços relacionados a animais sinantrópicos  
- **Formato:** Arquivos `.xlsx` processados e convertidos em `.RDS` para melhor desempenho  
- **Cobertura Temporal:** Dependendo da atualização do portal


## 👨‍💻 Autor

- **Nome:** Lucca Nielsen  
- **LinkedIn:** [Clique aqui](https://www.linkedin.com/in/lucca-nielsen-53b2a9181/)  
- **Descrição:** Especialista em análise de dados aplicada à saúde pública e vigilância epidemiológica
