# Instruções sobre teste realizado para vaga de DevOps/SRE no Zé Delivery

- Arquivo ZéDelivery_Arquitetura.pdf: Apresenta arquitetura proposta;
- Arquivo ZéDelivery_Glossário_Arquitetura.pdf: Apresenta a descrição dos recursos propostos no desenha do arquitetura;
- A IaC foi feita usando Terraform | cada arquivo .tf representa uma parte da arquitetura;

NOTA 1: A IaC não contém o ambiente de DR proposto na arquitetura;
NOTA 2: Arquivo terraform_fmt_ok.png mostra comando de formatação dos arquivos .tf;
NOTA 3: Ao executar comando <terraform validate> o sistema retornou algumas criticas do código (validate_error.png). Como não consegui resolver a tempo, estes erros precisam ser corrigidos para perfeita execução da infra;
NOTA 4: Realizei um teste no terraform, onde criei com sucesso uma instância EC2 e um  bucket S3. As evidências estão nas seguintes imagens: arq_terraform.png, terraform_init.png, terraform_apply.png, terraform_show.png, terraform_show_2.png, aws_ec2_ok.png e aws_s3_ok.png;

## ESTA É A PRIMEIRA VEZ QUE USO O TERRAFORM. A TÍTULO DE CURIOSIDADE, EU FIZ UM CURSO RÁPIDO PARA TENTAR REALIZAR O DESAFIO DA MELHOR FORMA ###
....
