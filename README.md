[![Maintainability](https://api.codeclimate.com/v1/badges/d21c02c221f6c0dd1796/maintainability)](https://codeclimate.com/github/pedroperrone/management-duty/maintainability)[![Test Coverage](https://api.codeclimate.com/v1/badges/d21c02c221f6c0dd1796/test_coverage)](https://codeclimate.com/github/pedroperrone/management-duty/test_coverage)

## Descrição

Este repositório contém o trabalho final da disciplina de Engenharia de Software N da Universidade Federal do Rio Grande do Sul do grupo composto por [José Pedro Martinez](https://github.com/jotapem), [Lucas Flores](https://github.com/pacluke), [Mario Zemor](https://github.com/mgfzemor) e [Pedro Perrone](https://github.com/pedroperrone). Neste trabalho, cada grupo desenvolve um produto e atua como analista. Em seguida ocorre uma troca de especificações entre os grupos e um grupo atua como desenvolvedor para o outro.

## Dependências
* Ruby 2.5.1
* PostgreSQL 10.5

Recomenda-se o uso de algum gerenciador de versão de Ruby, como `rbenv` ou `rvm`.

## Configuração do ambiente

Comece clonando o repositório com o comando
`git clone https://github.com/pedroperrone/management-duty.git`

Em seguida navegue para o diretório do projeto com
`cd management-duty`.

Para instalar as dependências use o comando
`bundle install`.

Em seguida, faça uma cópia do arquivo de variávies de ambiente com o comando
`cp .env.sample .env`.

Se for desejado alterar aspectos como nome do banco de dados ou usuário do banco de dados, faça as devidas modificações no arquivo `.env`.

Rode a seguinte sequência de comandos para inicializar o banco de dados:
```
rake db:create
rake db:migrate
```

Por fim, use o comando `rails s`. O projeto deve estar disponível em `http://localhost:3000`.

## Testes automatizados

Para rodar os testes automatizados da aplicação pela primeira vez, rode os seguintes comandos para initializar o banco de dados:
```
rake db:create RAILS_ENV=test
rake db:migrate RAILS_ENV=test
```

Depois, para cada execução da rotina de testes automatizados, basta rodar `bundle exec rspec`.
