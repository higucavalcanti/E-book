# E-book Interativo: Evolução e Diversidade Biológica

Este projeto é um e-book interativo desenvolvido como trabalho acadêmico para a disciplina de Computação Gráfica e Sistemas Multimídia. O objetivo é apresentar os conceitos fundamentais da evolução e da diversidade biológica de uma forma lúdica e engajadora, utilizando recursos multimídia para criar uma experiência de aprendizado imersiva.

O aplicativo foi desenvolvido utilizando o framework **Solar2D** (antigo Corona SDK) e a linguagem de script **Lua**, permitindo a criação de conteúdo interativo multiplataforma para dispositivos móveis (iOS e Android).

## Funcionalidades Interativas

O e-book guia o usuário através de cinco capítulos principais, cada um com mecânicas de interação únicas para exemplificar os conceitos apresentados:

* **Capítulo 1: A Origem da Vida**
    * **Interação:** Toque na tela.
    * **Conceito:** Demonstra a evolução a partir de um ancestral comum. Cada toque revela um novo estágio evolutivo, desde um micro-organismo até o ser humano moderno, organizando-os em uma espiral evolutiva.

* **Capítulo 2: Teorias da Evolução e Seleção Natural**
    * **Interação:** Toque para mover.
    * **Conceito:** Simula a Seleção Natural. O usuário controla um predador (leão) e deve capturar as presas. Apenas as presas mais lentas podem ser capturadas, enquanto as mais rápidas escapam, ilustrando a sobrevivência do mais apto.

* **Capítulo 3: Processos Evolutivos e Mutação**
    * **Interação:** Toque no personagem.
    * **Conceito:** Representa a mutação genética. Ao tocar no pássaro, ele evolui visualmente em estágios, com efeitos de partículas para ilustrar a mudança e a geração de novas características.

* **Capítulo 4: Evidências da Evolução**
    * **Interação:** Arrastar e soltar.
    * **Conceito:** Demonstra o registro fóssil. O usuário atua como um arqueólogo, arrastando pedras para "escavar" e revelar um fóssil de dinossauro escondido.

* **Capítulo 5: A Importância da Biodiversidade**
    * **Interação:** Gesto de pinça (zoom).
    * **Conceito:** Ilustra a especiação e o aumento da biodiversidade. Ao usar o gesto de pinça para unir dois pássaros, novos pares de pássaros surgem em locais aleatórios, representando a multiplicação e a resiliência dos ecossistemas.

## 🚀 Tecnologias Utilizadas

* **Engine:** [Solar2D (Corona SDK)](https://solar2d.com/) - Um framework de desenvolvimento de jogos e aplicações 2D.
* **Linguagem:** [Lua](https://www.lua.org/) - Uma linguagem de script leve e poderosa, ideal para desenvolvimento rápido.
* **Plataformas Alvo:** iOS e Android.

## ⚙️ Estrutura do Projeto

O código-fonte está organizado da seguinte forma:

* `main.lua`: Ponto de entrada da aplicação, responsável por iniciar o compositor de cenas.
* `config.lua` e `build.settings`: Arquivos de configuração do projeto Solar2D, definindo dimensões de tela, orientação e configurações de compilação para iOS e Android.
* `src/screens/`: Contém os arquivos Lua para cada cena (página) do e-book.
* `src/components/`: Módulos reutilizáveis, como o `button.lua`, que cria os botões de navegação.
* `src/assets/`: Todos os recursos visuais (imagens, ícones) e de áudio utilizados no projeto.

## 🛠️ Como Executar

Para executar este projeto, você precisará do simulador do Solar2D.

1.  **Baixe e instale o Solar2D:** Acesse o [site oficial do Solar2D](https://solar2d.com/) e baixe a versão mais recente para o seu sistema operacional.
2.  **Abra o projeto:** Inicie o simulador do Solar2D e abra o diretório raiz deste projeto.
3.  O simulador irá carregar o `main.lua` e iniciar o e-book interativo.

---
**Desenvolvido por:** Higor Cavalcanti Souza
