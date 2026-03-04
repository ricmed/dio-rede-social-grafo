**1. Insight de Popularidade: Qual post tem o maior engajamento total (Curtidas + Comentários)?**
Esta consulta soma os relacionamentos de entrada (LIKES) e os comentários (ON) para definir a relevância de um conteúdo

```cypher
OPTIONAL MATCH (:User)-[:LIKES]->(p)
WITH p, COUNT(DISTINCT parent) AS curtidas // parent é uma variável implícita do path, mas vamos usar uma forma mais explícita:
MATCH (p:Post)
OPTIONAL MATCH (u:User)-[:LIKES]->(p)
OPTIONAL MATCH (c:Comment)-[:ON]->(p)
RETURN p.content AS Post, 
       p.createdAt AS Data,
       COUNT(DISTINCT u) AS Curtidas, 
       COUNT(DISTINCT c) AS Comentarios,
       (COUNT(DISTINCT u) + COUNT(DISTINCT c)) AS EngajamentoTotal
ORDER BY EngajamentoTotal DESC LIMIT 3;
```

**2. Sistema de Recomendação: Sugerindo novos perfis (Pessoas que você talvez conheça)**
Essa é uma clássica aplicação de *triangulação* vista no curso. Se a Alice segue a Kelly, quem a Kelly segue que a Alice ainda não segue?

```cypher
MATCH (alice:User {username: 'alice_tech'})-[:FOLLOWS]->(amigo:User)-[:FOLLOWS]->(sugestao:User)
WHERE NOT (alice)-[:FOLLOWS]->(sugestao) AND alice <> sugestao
RETURN sugestao.username AS Recomendacao, COUNT(amigo) AS ConexoesEmComum
ORDER BY ConexoesEmComum DESC;
```

**3. Mapeamento de Comunidades: Quais os temas mais fortes da rede?**
Uma query agregadora para descobrir as Tags/Hashtags que mais geram conteúdo no aplicativo.

```cypher
MATCH (p:Post)-[:HAS_TAG]->(t:Tag)
RETURN t.name AS Tema, COUNT(p) AS QuantidadeDePosts
ORDER BY QuantidadeDePosts DESC;
```

Para rodar este protótipo, basta copiar e colar o conteúdo do arquivo `.cypher` gerado na sua interface do Neo4j (AuraDB ou Desktop) e, em seguida, rodar as consultas analíticas.
