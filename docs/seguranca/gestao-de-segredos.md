# Gestao de segredos

Segredos reais nao devem ser armazenados no Git. Use variaveis de ambiente, cofres ou mecanismos equivalentes.

O workflow `Security` executa `scripts/scan-secrets.sh`. O objetivo e detectar
segredos potencialmente reais, como tokens GitHub, chaves privadas e atribuicoes
hardcoded suspeitas em variaveis sensiveis, sem tratar nomes de variaveis,
placeholders ou senhas deliberadamente publicas de desenvolvimento como
vazamento real.

Valores como `*_dev_password` em `.env.example`, documentacao e composicoes
locais sao permitidos apenas para desenvolvimento. Homologacao e producao devem
usar secrets ou variaveis externas ao Git.
