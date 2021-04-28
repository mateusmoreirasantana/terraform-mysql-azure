# vagrant-mysql

## ESD21 - Infrastructure and Cloud Computing 
---------------------------------------------------------------------------------------------------------------

## Exercício Aula 02

## Atividade
>Subir uma máquina virtual no Azure, AWS ou GCP instalando o MySQL e que esteja acessível no host da máquina na porta 3306, usando Terraform.  

## Tecnologias utilizadas

- [Terraform](hhttps://www.terraform.io/) - Ferramenta de provisionamento
- [Azure](https://www.azure.microsoft.com/) - Provider
- [MySQL](https://www.mysql.com/) - Banco de dados.

## Pre Requisitos
- [terraform](https://www.terraform.io/downloads.html)
- [az cli](https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli)

## Instalação 

Para subir a Máquina Virtual na azure:  
    1 - criar uma pasta em sua maquina.<br/>
    2 - Clonar o repositório: "https://github.com/mateusmoreirasantana/terraform-mysql-azure".  <br/>
    3 - Executar o comando "az login" para logar em sua conta na azure<br/>
    4 - Executar o comando "terraform init" para iniciar o terraform.  <br/>
    5 - Executar o comando "terraform plan" e se tudo estiver correto executar o comando "terraform apply" para criar sua maquina virtual.  <br/>


## Para acessar ao banco de dados:
  
Baixar um client do mySQL
Host:[ip_publico_azure]
Usuário: terraform  
Senha: terraform

