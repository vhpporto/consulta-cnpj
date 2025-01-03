# Consulta CNPJ - macOS App

Um aplicativo para macOS que permite consultar informações de empresas pelo CNPJ, usando uma API pública. O aplicativo é simples e prático, localizado na barra de menus para fácil acesso.

## Funcionalidades

- **Consulta rápida:** Insira o CNPJ e obtenha informações detalhadas da empresa, como nome, endereço, telefone, e-mail, e sócios.
- **Cópia de informações:** Clique sobre qualquer texto para copiá-lo para a área de transferência.
- **Máscara de CNPJ:** Remove automaticamente os caracteres especiais ao digitar (pontos, barras e hífens).

## Tecnologias Utilizadas

- **SwiftUI:** Framework para construção da interface do usuário.
- **URLSession:** Para realizar requisições HTTP e obter dados da API.
- **JSONSerialization:** Para manipulação dos dados retornados pela API.

## Pré-requisitos

- macOS 11.0 ou superior.
- Xcode instalado para executar ou compilar o projeto.

## Instalação

1. Clone o repositório:
   ```bash
   git clone https://github.com/vhpporto/consulta-cnpj.git
