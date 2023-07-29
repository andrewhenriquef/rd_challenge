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
ruby -I test customer_success_balancing.rb
```

Para rodar algum teste em específico

```bash
ruby -I test customer_success_balancing.rb --name test_scenario_two
```

## Dúvidas, ânseios sobre o "projeto/teste"

Na sessão "O Desafio - CustomerSuccess Balancing" no último parágrafo é comentado que o sistema distribui os clientes com os CSs de capacidade de atendimento mais próxima (maior) ao tamanho do cliente.

Só que no `test_scenario_three` ele não atende a essa condição da pontuação do customer success ser maior que a do client.

- O customer success de id `999` está ausente e seria necessário ele estar disponivel para atender todos os customers que possuem o valor da pontuação inferior ao valor dele (`998`)

- No teste é esperado o retorno do ID `998` que é o customer success que atenderia os 10_000 clientes com score `998`

O que seria a regra de negócio correta:

- O código aceitar pontuações de clientes `<=` a pontuação do customer success ?

- O teste retornar 0 pois nenhum cliente poderia ser atendido já que na descrição do teste é solicitado uma pontuação do customer success `>` que a do cliente ?

Uma outra dúvida é que no `test_scenario_three` foi usado o `Timeout`.

- A intenção dele é simular um teste de performance ?
  - Minha dúvida é por conta de que na minha máquina eu dificilmente algum problema de performance, a menos que o algoritmos estivesse bastante mal otimizado.