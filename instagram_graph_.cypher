// ============================================================================
// 1. CONSTRAINTS DE UNICIDADE (Boas Práticas de Integridade)
// ============================================================================
// Garantem que não teremos duplicidade de entidades no nosso grafo.
CREATE CONSTRAINT user_id IF NOT EXISTS FOR (u:User) REQUIRE u.userId IS UNIQUE;
CREATE CONSTRAINT username_unique IF NOT EXISTS FOR (u:User) REQUIRE u.username IS UNIQUE;
CREATE CONSTRAINT post_id IF NOT EXISTS FOR (p:Post) REQUIRE p.postId IS UNIQUE;
CREATE CONSTRAINT comment_id IF NOT EXISTS FOR (c:Comment) REQUIRE c.commentId IS UNIQUE;
CREATE CONSTRAINT tag_name IF NOT EXISTS FOR (t:Tag) REQUIRE t.name IS UNIQUE;

// ============================================================================
// 2. CRIAÇÃO DOS NÓS (Utilizando UNWIND e MERGE para performance e segurança)
// ============================================================================

// A. Criando Usuários (15 usuários de 3 nichos diferentes)
UNWIND [
    {id: 'u1', username: 'alice_tech', name: 'Alice Silva'},
    {id: 'u2', username: 'bob_dev', name: 'Bob Souza'},
    {id: 'u3', username: 'charlie_code', name: 'Charlie Santos'},
    {id: 'u4', username: 'diana_data', name: 'Diana Lima'},
    {id: 'u5', username: 'enzo_ai', name: 'Enzo Costa'},
    
    {id: 'u6', username: 'fabio_lentes', name: 'Fábio Retratos'},
    {id: 'u7', username: 'gabi_photo', name: 'Gabi Oliveira'},
    {id: 'u8', username: 'hugo_drone', name: 'Hugo Aéreo'},
    {id: 'u9', username: 'iris_click', name: 'Iris Pereira'},
    {id: 'u10', username: 'joao_focus', name: 'João Foco'},
    
    {id: 'u11', username: 'kelly_fit', name: 'Kelly Treinos'},
    {id: 'u12', username: 'lucas_gym', name: 'Lucas Força'},
    {id: 'u13', username: 'mia_run', name: 'Mia Maratona'},
    {id: 'u14', username: 'nuno_cross', name: 'Nuno Box'},
    {id: 'u15', username: 'olivia_wellness', name: 'Olivia Saúde'}
] AS userData
MERGE (u:User {userId: userData.id})
SET u.username = userData.username, u.name = userData.name;

// B. Criando Tags (Comunidades de Interesse)
UNWIND ['Tecnologia', 'Programacao', 'InteligenciaArtificial', 'Fotografia', 'Natureza', 'Fitness', 'Corrida', 'Saude'] AS tagName
MERGE (t:Tag {name: tagName});

// C. Criando Posts
UNWIND [
    {id: 'p1', author: 'u1', content: 'Novo framework JS lançado hoje!', date: '2026-03-01'},
    {id: 'p2', author: 'u2', content: 'Dicas de arquitetura de dados com Grafos.', date: '2026-03-02'},
    {id: 'p3', author: 'u5', content: 'A IA está mudando tudo.', date: '2026-03-03'},
    {id: 'p4', author: 'u6', content: 'Luz perfeita no pôr do sol de hoje.', date: '2026-03-01'},
    {id: 'p5', author: 'u7', content: 'Ensaio fotográfico urbano.', date: '2026-03-02'},
    {id: 'p6', author: 'u11', content: 'Treino de pernas finalizado! 🏋️‍♀️', date: '2026-03-01'},
    {id: 'p7', author: 'u13', content: '10km concluídos para começar o dia.', date: '2026-03-04'}
] AS postData
MATCH (author:User {userId: postData.author})
MERGE (p:Post {postId: postData.id})
SET p.content = postData.content, p.createdAt = postData.date
MERGE (author)-[:POSTED]->(p);

// D. Conectando Posts às Tags
MATCH (p:Post {postId: 'p1'}), (t1:Tag {name: 'Tecnologia'}), (t2:Tag {name: 'Programacao'}) MERGE (p)-[:HAS_TAG]->(t1) MERGE (p)-[:HAS_TAG]->(t2);
MATCH (p:Post {postId: 'p2'}), (t1:Tag {name: 'Tecnologia'}) MERGE (p)-[:HAS_TAG]->(t1);
MATCH (p:Post {postId: 'p3'}), (t1:Tag {name: 'Tecnologia'}), (t2:Tag {name: 'InteligenciaArtificial'}) MERGE (p)-[:HAS_TAG]->(t1) MERGE (p)-[:HAS_TAG]->(t2);
MATCH (p:Post {postId: 'p4'}), (t1:Tag {name: 'Fotografia'}), (t2:Tag {name: 'Natureza'}) MERGE (p)-[:HAS_TAG]->(t1) MERGE (p)-[:HAS_TAG]->(t2);
MATCH (p:Post {postId: 'p5'}), (t1:Tag {name: 'Fotografia'}) MERGE (p)-[:HAS_TAG]->(t1);
MATCH (p:Post {postId: 'p6'}), (t1:Tag {name: 'Fitness'}), (t2:Tag {name: 'Saude'}) MERGE (p)-[:HAS_TAG]->(t1) MERGE (p)-[:HAS_TAG]->(t2);
MATCH (p:Post {postId: 'p7'}), (t1:Tag {name: 'Fitness'}), (t2:Tag {name: 'Corrida'}) MERGE (p)-[:HAS_TAG]->(t1) MERGE (p)-[:HAS_TAG]->(t2);

// ============================================================================
// 3. CRIAÇÃO DE RELACIONAMENTOS (A Magia dos Grafos)
// ============================================================================

// A. Rede de Seguidores (Mão única: FOLLOWS)
// Comunidade Tech
MATCH (u1:User {userId: 'u1'}), (u2:User {userId: 'u2'}), (u3:User {userId: 'u3'}), (u4:User {userId: 'u4'}), (u5:User {userId: 'u5'})
MERGE (u2)-[:FOLLOWS]->(u1) MERGE (u3)-[:FOLLOWS]->(u1) MERGE (u4)-[:FOLLOWS]->(u1) MERGE (u5)-[:FOLLOWS]->(u1) // Todos seguem a Alice
MERGE (u1)-[:FOLLOWS]->(u2) MERGE (u1)-[:FOLLOWS]->(u5);

// Comunidade Fotografia
MATCH (u6:User {userId: 'u6'}), (u7:User {userId: 'u7'}), (u8:User {userId: 'u8'}), (u9:User {userId: 'u9'}), (u10:User {userId: 'u10'})
MERGE (u7)-[:FOLLOWS]->(u6) MERGE (u8)-[:FOLLOWS]->(u6) MERGE (u9)-[:FOLLOWS]->(u7) MERGE (u10)-[:FOLLOWS]->(u7);

// Comunidade Fitness
MATCH (u11:User {userId: 'u11'}), (u12:User {userId: 'u12'}), (u13:User {userId: 'u13'}), (u14:User {userId: 'u14'}), (u15:User {userId: 'u15'})
MERGE (u12)-[:FOLLOWS]->(u11) MERGE (u13)-[:FOLLOWS]->(u11) MERGE (u14)-[:FOLLOWS]->(u11) MERGE (u15)-[:FOLLOWS]->(u13);

// Cross-Community (Pessoas com múltiplos interesses)
MATCH (u1:User {userId: 'u1'}), (u11:User {userId: 'u11'}), (u6:User {userId: 'u6'}), (u2:User {userId: 'u2'})
MERGE (u1)-[:FOLLOWS]->(u11) // Alice (Tech) segue Kelly (Fit)
MERGE (u2)-[:FOLLOWS]->(u6);  // Bob (Tech) segue Fabio (Photo)

// B. Curtidas em Posts (LIKES)
UNWIND [
    {user: 'u2', post: 'p1'}, {user: 'u3', post: 'p1'}, {user: 'u4', post: 'p1'}, // Post 1 bombou
    {user: 'u1', post: 'p2'}, {user: 'u5', post: 'p2'},
    {user: 'u7', post: 'p4'}, {user: 'u8', post: 'p4'}, {user: 'u9', post: 'p4'}, {user: 'u2', post: 'p4'},
    {user: 'u12', post: 'p6'}, {user: 'u13', post: 'p6'}, {user: 'u14', post: 'p6'}, {user: 'u1', post: 'p6'}
] AS likeData
MATCH (u:User {userId: likeData.user}), (p:Post {postId: likeData.post})
MERGE (u)-[:LIKES]->(p);

// C. Criação de Comentários (Nó intermediário - BOAS PRÁTICAS)
// Em vez de (User)-[:COMMENTED]->(Post), fazemos: (User)-[:WROTE]->(Comment)-[:ON]->(Post)
UNWIND [
    {id: 'c1', user: 'u2', post: 'p1', text: 'Muito bom, Alice!'},
    {id: 'c2', user: 'u5', post: 'p1', text: 'Vou testar hoje mesmo.'},
    {id: 'c3', user: 'u8', post: 'p4', text: 'Qual lente você usou?'},
    {id: 'c4', user: 'u13', post: 'p6', text: 'Monstro! 💪'}
] AS commentData
MATCH (u:User {userId: commentData.user}), (p:Post {postId: commentData.post})
MERGE (c:Comment {commentId: commentData.id})
SET c.text = commentData.text, c.createdAt = '2026-03-04'
MERGE (u)-[:WROTE]->(c)
MERGE (c)-[:ON]->(p);

// ============================================================================
// FIM DO SCRIPT
// ============================================================================
