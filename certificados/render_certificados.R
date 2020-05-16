library(readxl)
library(dplyr)
library(janitor)
library(tidyverse)
library(readr)

# abrir a lista de presenca

#lista_de_presenca <-
  # read_excel(
  #   "certificados/lista-preenchida.xlsx",
  #   col_types = c("skip", "text", "skip",
  #                 "text", "text")
  # ) %>% janitor::clean_names() %>%
  # filter(presenca == "presente")


  lista_de_presenca <-
  read_delim(
    "certificados/meetup-16-05-2020.csv",
    ";",
    escape_double = FALSE,
    col_types = cols(
      `Respondeu ao RSVP em` = col_skip(),
      X9 = col_skip(),
      ordem = col_skip()
    ),
    trim_ws = TRUE
  ) %>% janitor::clean_names() %>%
     filter(presenca == TRUE)


# Organizadoras --------------------------------------
# Organizadoras - Ler arquivos

lista_de_presenca_organizadoras <-
  lista_de_presenca %>% filter(observacao == "organizador(a)") %>%
  select(nome_completo) %>%
  as_vector()

# Organizadoras - gerar certificados em html
purrr::walk(
  lista_de_presenca_organizadoras,
  ~ rmarkdown::render(
    "certificados/modelo_certificados.Rmd",
    params = list(nome_participante = ., tipo_participacao = "organizadora(o)"),
    output_file = glue::glue('Certificado_Organizacao_R-Ladies_{.}.html')
  )
)

# Monitoras --------------------------------------
lista_de_presenca_monitoria <-
  lista_de_presenca %>% filter(observacao == "monitor(a)") %>%
  select(nome_completo) %>%
  as_vector()

#  gerar certificados em html
purrr::walk(
  lista_de_presenca_monitoria,
  ~ rmarkdown::render(
    "certificados/modelo_certificados.Rmd",
    params = list(nome_participante = ., tipo_participacao = "monitora(o)"),
    output_file = glue::glue('Certificado_Monitoria_R-Ladies_{.}.html')
  )
)

# Participantes --------------------------------------
# Participantes - ler arquivo

lista_de_presenca_participantes <-
  lista_de_presenca %>% filter(observacao == "participante") %>%
  select(nome_completo) %>%
  as_vector()



# Gerar arquivos html das participantes

purrr::walk(
  lista_de_presenca_participantes,
  ~ rmarkdown::render(
    "certificados/modelo_certificados.Rmd",
    params = list(nome_participante = .),
    output_file = glue::glue('Certificado_R-Ladies_{.}.html')
  )
)

# -------------------
# Gerar os PDF's de todos os HTML na pasta
purrr::walk(.x = list.files(pattern = "\\.html$", recursive = TRUE),
            .f = pagedown::chrome_print)


beepr::beep() # a etapa de gerar os PDFs demora.
# A função beep faz um aviso sonoro para saber que terminou!
