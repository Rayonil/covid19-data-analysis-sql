# COVID-19 Data Analysis with SQL

Este projeto realiza uma análise exploratória de dados sobre a pandemia de COVID-19 utilizando a linguagem SQL, com foco nas tabelas CovidDeaths e CovidVaccinations. Os dados foram originalmente extraídos e armazenados no projeto BigQuery centered-carver-463915-a1, dentro do dataset COVID_19.

    ⚠Nota: Para utilizar este código em seu próprio ambiente, substitua os nomes do projeto e dataset conforme sua configuração no BigQuery.

## Objetivos

    Investigar a evolução de casos, mortes e vacinação por COVID-19 ao redor do mundo.

    Criar indicadores e métricas como taxa de letalidade, porcentagem da população infectada e taxa de vacinação.

    Identificar países com maior impacto relativo da pandemia com base em proporções populacionais.

## Técnicas e Recursos Utilizados

    Joins: integração entre tabelas de óbitos e vacinação.

    Common Table Expressions (CTEs): modularização e clareza do código.

    Funções de janela (Window Functions): cálculo acumulado de vacinados ao longo do tempo.

    Funções de agregação: sumarização de casos e mortes.

    Criação de views: armazenamento de resultados prontos para uso em ferramentas de visualização.

    Conversões de tipo de dados: garantindo integridade nos cálculos e precisão estatística.

## Exemplos de Análises Realizadas

    Evolução diária de casos e mortes no Brasil.

    Estimativa da taxa de letalidade por país.

    Comparação da porcentagem de infectados em relação à população.

    Países e continentes com os maiores números absolutos e relativos de casos e óbitos.

    Proporção acumulada da população vacinada ao longo do tempo.

    Criação de uma view persistente para visualizações dinâmicas em ferramentas como Power BI e Data Studio.

O repositório é ideal para quem deseja aprender SQL através de um caso real, relevante e com aplicação direta em visualização e análise de dados públicos de grande escala.
