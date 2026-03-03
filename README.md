# ld_Esalq
Material Empírico - Livre Docência - Gustavo C. Moreira (Esalq-USP)

Esta pasta reúne todos os scripts utilizados nas análises empíricas da tese “Violence and Institutions in Brazil: Studies on Policing, Trust, and the Victimization of Vulnerable Groups”.

Os dados empregados são públicos e podem ser baixados diretamente nas fontes oficiais para fins de replicação. As bases originais não foram incluídas nesta pasta em razão de seu tamanho.

Cabe observar que tais bases passam por atualizações periódicas. Assim, downloads realizados em momento posterior podem gerar resultados ligeiramente distintos daqueles apresentados na tese.

As versões exatas das bases utilizadas nas estimativas encontram-se arquivadas pelo autor e podem ser disponibilizadas mediante solicitação pelo e-mail gustavocmoreira@usp.br

Instruções:

- PNAD Contínua_4 trimestre_2021, microdados e documentação disponível em: https://www.ibge.gov.br/estatisticas/downloads-estatisticas.html?caminho=Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Trimestral/Microdados/2021

- Dados SINAN. Acessar: https://datasus.saude.gov.br/transferencia-de-arquivos/

Em fonte: SINAN - Sistema de Informação de Agravos de Notificação

Em modalidade, clicar em Dados (posteriormente em Documentação, para acessar o dicionário)

Em tipo de arquivo, clicar em VIOL - Violência Doméstica, sexual e/ou outras violências

Selecionar o ano de 2024

Em UF, selecionar BR e clicar em Enviar

Aparecerá para download um arquivo chamado VIOLBR24.dbc

Para que esse arquivo seja lido em softwares estatísticos (como o Stata), é preciso transformá-lo em .dbf, a partir do software TABWIN do Datasus
