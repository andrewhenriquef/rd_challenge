# Ruby

Versão do ruby utilizada nesse projeto

```
3.2.2
```

É necessário instalar a gem minitest para rodas os testes desse projeto

```bash
gem install minitest
```

## Como rodar os testes

Acesse o repositório ruby do projeto

```bash
cd ruby
```

Para rodar a suíte toda de testes use o comando abaixo

```bash
ruby test/customer_success_balancing_tests.rb
```

Para rodar algum teste em específico

```bash
ruby test/customer_success_balancing_tests.rb --name test_scenario_two
```

## Dúvidas, ânseios sobre o "projeto/teste"

Na sessão "O Desafio - CustomerSuccess Balancing" no último parágrafo é comentado que o sistema distribui os clientes com os CSs de capacidade de atendimento mais próxima (maior) ao tamanho do cliente.

Só que no `test_scenario_three` ele não atende a essa condição da pontuação do customer success ser maior que a do client.

- O customer success de id `999` está ausente e seria necessário ele estar disponivel para atender todos os customers que possuem o valor da pontuação inferior ao valor dele (`998`)

- No teste é esperado o retorno do ID `998` que é o customer success que atenderia os `10_000` clientes com score `998`

O que seria a regra de negócio correta ?

- O código aceitar pontuações de clientes `<=` a pontuação do customer success ?

- O teste retornar 0 pois nenhum cliente poderia ser atendido já que na descrição do teste é solicitado uma pontuação do customer success `>` que a do cliente ?

Outro ponto sobre o mesmo teste `test_scenario_three`

- Ao tentar criar a validação para a premissa `0 < nível do cs < 10.000` o teste falha, pois o o teste cria `10_000` customer success de nivel `998` enquanto que a premissa `0 < id do cs < 1.000` permite até o customer success de id `1.000`



Evitei de atualizar os testes por conta dessa expectativa `Testes. Você pode adicionar novos testes, mas sem alterar o pacote original`

Mas ao meu ver algumas premissas não serão atendidas corretamente se os testes não forem atualizados, como as que descrevi acima.

O que seria o ideal por aqui a se feito por aqui, atualizar os teste ou alterar a premissa/regra de negócio ? :thinking: