# 📸 Protótipo de Rede Social com Neo4j (Estilo Instagram)

Este projeto foi desenvolvido com o intuito de aplicar e demonstrar os meus conhecimentos em Bases de Dados Orientadas a Grafos utilizando o Neo4j e a linguagem Cypher.

Trata-se de um projeto de estudo e portefólio, focado em ilustrar como as interações de uma rede social (como o Instagram) podem ser modeladas nativamente em formato de grafo para responder a perguntas complexas de negócio com alta performance.

# 🎯 Objetivo do Projeto

Criar um modelo lógico e físico de uma rede social capaz de rastrear utilizadores, publicações, comunidades (tags) e o engajamento (gostos e comentários). O objetivo principal é extrair insights valiosos, como popularidade de conteúdo e sistemas de recomendação de amizades, superando as limitações das bases de dados relacionais tradicionais nestes cenários de dados altamente conectados.

# 🛠️ Tecnologias e Ferramentas

- Base de Dados: Neo4j (AuraDB / Desktop)
- Linguagem de Consulta: Cypher
- Conceitos Aplicados: Modelagem de Grafos, Constraints, Idempotência (MERGE), Nós Intermediários, Triangulação de Relacionamentos.

# 🧠 Modelagem do Grafo (Schema)

Para representar fielmente o ecossistema da rede social, o grafo foi modelado com as seguintes entidades:

## Nós (Nodes/Labels)

- User: Representa os utilizadores da plataforma (ex: username, nome).
- Post: Representa as publicações feitas pelos utilizadores.
- Tag: Representa as comunidades ou hashtags (ex: Tecnologia, Fotografia).
- Comment: Representa os comentários feitos nas publicações.

## Relacionamentos (Edges)

- (User)-[:FOLLOWS]->(User): Relacionamento unidirecional de seguidores.
- (User)-[:POSTED]->(Post): Autoria do conteúdo.
- (Post)-[:HAS_TAG]->(Tag): Categorização do conteúdo.
- (User)-[:LIKES]->(Post): Engajamento direto (gosto).
- (User)-[:WROTE]->(Comment)-[:ON]->(Post): Engajamento em texto.

# 🌟 Boas Práticas Aplicadas

Durante a construção deste projeto, apliquei conceitos vitais para a saúde e performance de uma base de dados de grafos:

1. Constraints de Unicidade: Implementação de CREATE CONSTRAINT para garantir que usernames e IDs únicos não sejam duplicados no sistema, mantendo a integridade dos dados.
2. Carga Segura de Dados (Idempotência): Utilização das cláusulas UNWIND em conjunto com MERGE em vez de CREATE. Isto garante que o script possa ser executado múltiplas vezes sem gerar dados duplicados.
3. Padrão de Nó Intermediário (Evitando Dense Nodes): Em vez de criar um relacionamento direto de comentário contendo o texto (User)-[:COMMENTED {text: "..."}]->(Post), optei por criar um nó intermediário Comment. Isso evita a sobrecarga das arestas, melhora a performance em consultas pesadas e prepara a arquitetura para futuras análises de Processamento de Linguagem Natural (NLP) no texto dos comentários.

# 🚀 Como Executar este Projeto

1. Instale o Neo4j Desktop ou crie uma instância gratuita no Neo4j AuraDB.
2. Copie o conteúdo do ficheiro instagram_graph.cypher.
3. Cole o script no Neo4j Browser e execute-o. A base de dados criará automaticamente as constraints e a massa de dados de teste (15 utilizadores e suas interações).

# 🔍 Consultas de Demonstração (Insights)

Com a base populada, é possível extrair métricas cruciais de negócio. Aqui estão alguns exemplos do que o grafo pode responder:

1. Sistema de Recomendação (Pessoas que talvez conheças)

Recomenda novos perfis para um utilizador com base nos perfis que as pessoas que ele segue também seguem (Triangulação).

```cypher
MATCH (alice:User {username: 'alice_tech'})-[:FOLLOWS]->(amigo:User)-[:FOLLOWS]->(sugestao:User)
WHERE NOT (alice)-[:FOLLOWS]->(sugestao) AND alice <> sugestao
RETURN sugestao.username AS Recomendacao, COUNT(amigo) AS ConexoesEmComum
ORDER BY ConexoesEmComum DESC;
```

2. Análise de Popularidade e Engajamento

Calcula o engajamento total (Gostos + Comentários) de cada publicação.

```cypher
MATCH (p:Post)
OPTIONAL MATCH (u:User)-[:LIKES]->(p)
OPTIONAL MATCH (c:Comment)-[:ON]->(p)
RETURN p.content AS Post, 
       COUNT(DISTINCT u) AS Curtidas, 
       COUNT(DISTINCT c) AS Comentarios,
       (COUNT(DISTINCT u) + COUNT(DISTINCT c)) AS EngajamentoTotal
ORDER BY EngajamentoTotal DESC LIMIT 3;
```

3. Mapeamento de Comunidades

Descobre quais as tags/nichos mais fortes da rede naquele momento.

```cypher
MATCH (p:Post)-[:HAS_TAG]->(t:Tag)
RETURN t.name AS Tema, COUNT(p) AS QuantidadeDePosts
ORDER BY QuantidadeDePosts DESC;
```

Este projeto foi criado estritamente para fins educacionais e para demonstração de conhecimentos em modelagem de dados com Neo4j.
