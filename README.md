# Condomínio Conectado

## Descrição do Projeto

Um aplicativo móvel voltado para o gerenciamento de pessoas em um condomínio.

## Metodologia

Este projeto foi desenvolvido utilizando a metodologia **Scrum**. A documentação a seguir apresenta as histórias de usuário que guiaram o desenvolvimento, focando na primeira Sprint.

---

## Histórias de Usuário e Tarefas

### Sprint 1: Autenticação e Configuração (27/05/2025)

**História 1: Acesso do Morador**

**Como:** morador
**Quero:** acessar as funcionalidades disponíveis do condomínio no aplicativo

**Descrição:**
Após fazer login como morador, ele verá uma tela com diversas opções de funcionalidades específicas para o morador.

**Critérios de Aceitação:**
- [x] Criar tela home do usuário morador.

**Status:** Concluído

---

**História 2: Acesso do Funcionário**

**Como:** funcionário
**Quero:** realizar login no sistema
**Para:** acessar suas funcionalidades disponíveis.

**Descrição:**
Após fazer login como funcionário, ele verá uma tela com diversas opções de funcionalidades específicas para o funcionário.

**Critérios de Aceitação:**
- [x] Criar tela home do usuário Síndico. (Há uma pequena discrepância na descrição e no checklist; assumi que o checklist está correto, pois a imagem seguinte se refere ao Síndico)

**Status:** Concluído

---

**História 3: Gestão de Moradores**

**Como:** síndico
**Quero:** realizar a função de adicionar e remover morador.

**Critérios de Aceitação:**
- [x] Criar opção de cadastrar morador.
- [x] Criar tela de cadastrar morador.
- [x] Criar tela de listar moradores.
- [x] Criar opção excluir morador.

**Status:** Concluído

---

**História 4: Acesso do Síndico**

**Como:** síndico
**Quero:** acessar as funcionalidades disponíveis do condomínio no aplicativo

**Descrição:**
Após fazer login como síndico, ele verá uma tela com diversas opções de funcionalidades específicas para o síndico.

**Critérios de Aceitação:**
- [x] Criar tela home do usuário Síndico.

**Status:** Concluído

---

**História 5: Recuperação de Senha**

**Como:** usuário
**Quero:** recuperar minha senha
**Para:** que possa acessar o sistema caso a esqueça.

**Descrição:**
Caso o usuário (síndico, morador ou funcionário) esqueça a senha, ele poderá redefinir a senha.
*Obs: precisar pensar em um jeito de confirmar que realmente é o morador que deseja resetar sua senha (por exemplo, enviando um token para o email dele).*

**Critérios de Aceitação:**
- [x] Criar opção para recuperar senha.
- [x] Criar tela de recuperar senha.
- [x] Criar método de confirmar usuário antes de redefinir senha.

**Status:** Concluído

---

**História 6: Login no Sistema**

**Como:** usuário
**Quero:** realizar login no sistema.

**Descrição:**
No sistema, existem três tipos de usuários: síndico, morador e funcionário. Cada um deles tem acesso a informações e recursos diferentes no aplicativo; porém, todos são considerados usuários. Dessa forma, a tela de login será a mesma para todos.

**Critérios de Aceitação:**
- [x] Criar tela de login de usuário.
- [x] Validar usuário com o banco de dados.

**Status:** Concluído

---

**Tarefas Técnicas da Sprint**

*Estas tarefas são importantes para a execução da sprint, mas não são histórias de usuário diretas.*

**Tarefa: Configurar o ambiente**

**Itens:**
- [x] Ativar o Hyper-V no Windows.
- [x] Seguir o tutorial do vídeo: [Curso Flutter – saiba como pegar um projeto Flutter no git e abrir no VS Code](https://www.youtube.com/watch?v=link_do_video).
- [x] Seguir o outro tutorial: [Guia Completo de Instalação do Flutter no Windows | VSCode e Android Studio](https://www.youtube.com/watch?v=link_do_video).

**Status:** Concluído

---

**Tarefa: Documento de Visão de Projeto**

**Itens:**
- [x] Preencher tópicos do documento.
**Link:** [Documento de Visão de Projeto] (você pode acessar os documentos na sessão Documentos do Projeto)

**Status:** Concluído

---

### Sprint 2: Gestão de Usuários e Comunicação (10/06/2025)

**História 1: Acesso ao App**

**Como:** usuário
**Quero:** clicar no ícone do App e acessá-lo.

**Critérios de Aceitação:**
- [x] Criar a imagem da logo.
- [x] Configurar o código para utilizar a imagem.

**Status:** Concluído

---

**História 2: Cadastrar Pets**

**Como:** morador
**Quero:** cadastrar todos os pets existentes na residência, para reconhecimento do mesmo nas áreas externas.

**Descrição:**
O morador poderá cadastrar seus animais de estimação.

**Critérios de Aceitação:**
- [x] Criar opção de cadastrar pet.
- [x] Criar tela de cadastrar pet.
- [x] Integrar com o banco de dados.

**Status:** Concluído

---

**História 3: Lista de Pets**

**Como:** síndico
**Quero:** ter acesso a uma lista com todos os pets cadastrados nas respectivas residências.

**Critérios de Aceitação:**
- [x] Criar opção de listar pets.
- [x] Criar tela de listar pets.

**Status:** Concluído

---

**História 4: Cadastrar Comunicados**

**Como:** síndico
**Quero:** cadastrar comunicados, para informar os moradores sobre assuntos ou decisões importantes (como ocorrências/agendamento de assembleias).

**Critérios de Aceitação:**
- [x] Criar opção de cadastrar comunicados.
- [x] Criar tela de cadastrar comunicados.

**Status:** Concluído

---

**História 5: Gestão de Funcionários**

**Como:** síndico
**Quero:** cadastrar e editar funcionários, para manter os dados atualizados.

**Descrição:**
O síndico deverá ter a opção de cadastrar um novo funcionário ou listar os funcionários existentes, podendo editá-los ou excluí-los.

**Critérios de Aceitação:**
- [x] Criar a opção de cadastrar funcionários.
- [x] Criar tela de cadastrar funcionários.
- [x] Criar tela de listar funcionários.
- [x] Criar opção de excluir funcionários.

**Status:** Concluído

---

### Sprint 3: Refatoramento e Comunicação (18/06/2025)

**História 1: Consultar Comunicados**

**Como:** usuário
**Quero:** consultar os comunicados do condomínio, para ficar informado sobre avisos e decisões.

**Critérios de Aceitação:**
- [x] Criar opção de consultar comunicados.
- [x] Criar tela de consultar comunicados.

**Status:** Concluído

---

**Tarefa: Refatoramento**

**Itens:**
- [x] Renomeação.
- [x] Refatoração planejada.

**Status:** Concluído

---

### Sprint 4: Estimativas (09/07/2025)

**Tarefa: Estimativa de Software**

**Itens:**
- [x] Estimativa de tempo.
- [x] Estimativa de entrega.

**Link:** [Estimativa de Software](https://docs.google.com/presentation/d/1DM67UvOzubgGcaEkEk1h-KarfDLmatqBfiv_AOFDw/edit?usp=drivesdk)

**Status:** Concluído

---

### Sprint 5: Reservas e Controle de Acesso (15/07/2025)

**História 1: Cadastrar Visitantes**

**Como:** morador
**Quero:** cadastrar visitantes no condomínio, para garantir a segurança e controle de acesso.

**Critérios de Aceitação:**
- [x] Criar opção de cadastrar visitante.
- [x] Criar tela de cadastrar visitante.
- [x] Criar opção de cadastrar visita.
- [x] Criar tela de cadastrar visita.

**Status:** Concluído

---

**História 2: Solicitar Reserva**

**Como:** morador
**Quero:** solicitar a reserva de um espaço comum, para uso privado em eventos.

**Descrição:**
O morador irá na opção de reservar espaço comum e poderá selecionar o dia e o horário que deseja solicitar a reserva, desde que esteja disponível.

**Critérios de Aceitação:**
- [x] Criar opção de reservar área.
- [x] Criar tela de reservar área.
- [x] Criar tela de listar dias/horários disponíveis.

**Status:** Concluído

---

**História 3: Consultar Reservas (Síndico)**

**Como:** síndico
**Quero:** consultar todas as reservas feitas, para monitoramento geral.

**Critérios de Aceitação:**
- [x] Criar tela de listar reservas.
- [x] Criar opção de verificar reservas.

**Status:** Concluído

---

**História 4: Consultar Lista de Visitantes (Porteiro/Zelador)**

**Como:** porteiro/zelador
**Quero:** consultar a lista de visitante cadastrados, para garantir o acesso seguro de pessoas ao condomínio.

**Critérios de Aceitação:**
- [x] Criar opção de listar visitantes.
- [x] Criar opção de registrar presença do visitante.

**Status:** Concluído

---

**História 5: Consultar Reservas (Porteiro/Zelador)**

**Como:** porteiro/zelador
**Quero:** consultar a lista de reserva de um espaço comum, para organizar o espaço.

**Critérios de Aceitação:**
- [x] Criar opção de listar reservas.

**Status:** Concluído

---

### Entrega Final

**História 1: Consultar Atas**

**Como:** morador
**Quero:** consultar as atas das assembleias do condomínio, para ficar informado sobre as discussões e decisões acordadas.

**Critérios de Aceitação:**
- [x] Criar opção de consultar Atas.
- [x] Criar tela de consultar Atas.

**Status:** Concluído

---

**História 2: Consultar Débitos**

**Como:** morador
**Quero:** consultar meus débitos, para acompanhar os pagamentos do condomínio.

**Critérios de Aceitação:**
- [x] Criar tela de listar débitos.
- [x] Criar opção de listar débitos.

**Status:** Concluído

---

**História 3: Emitir Débitos**

**Como:** síndico
**Quero:** emitir débitos para os moradores, para controle das cobranças mensais.

**Critérios de Aceitação:**
- [x] Criar opção de cadastrar débitos.
- [x] Criar tela de cadastrar débitos.

**Status:** Concluído

---

**História 4: Consultar Boletos Gerados**

**Como:** síndico
**Quero:** consultar todos os boletos gerados, para fins de auditoria.

**Descrição:**
Nessa tela, o síndico terá acesso a todos os débitos de cada um dos moradores.

**Critérios de Aceitação:**
- [x] Criar tela de listar débitos de moradores.
- [x] Criar opção de listar débitos de moradores.

**Status:** Concluído

---

**História 5: Cadastrar Solicitações de Manutenção**

**Como:** usuário
**Quero:** cadastrar solicitações de manutenção, para manter a infraestrutura do condomínio em boas condições.

**Critérios de Aceitação:**
- [x] Criar tela de cadastrar manutenção.
- [x] Criar opção de cadastrar manutenção.

**Status:** Concluído

---

**História 6: Aprovar Manutenções**

**Como:** síndico
**Quero:** aprovar manutenções solicitadas por usuários, para manter a infraestrutura do condomínio em boas condições.

**Descrição:**
O síndico deverá conseguir listar todas as solicitações de manutenção cadastradas pelos usuários e aprovar ou não cada uma delas, para que possam ser executadas por um funcionário posteriormente.

**Critérios de Aceitação:**
- [x] Criar tela de listar manutenções solicitadas.
- [x] Criar opção de aprovar manutenções solicitadas.
- [x] Criar opção de reprovar manutenções solicitadas.

**Status:** Concluído

---

**História 7: Consultar Histórico de Manutenções**

**Como:** síndico
**Quero:** consultar o histórico de manutenções, para controle e planejamento.

**Critérios de Aceitação:**
- [x] Criar opção de listar manutenções.
- [x] Criar tela de listar manutenções.

**Status:** Concluído

---

**História 8: Cadastrar Atas**

**Como:** síndico
**Quero:** cadastrar Atas, para informar os moradores sobre as discussões e decisões tomadas nas assembleias.

**Critérios de Aceitação:**
- [x] Criar opção de cadastrar Atas.
- [x] Criar tela de cadastrar Atas.

**Status:** Concluído

---

## Documentos do Projeto

Você pode acessar os documentos completos do projeto através do seguinte link:

[Documentos do Drive](https://drive.google.com/drive/folders/1n4LtoeHBnJ_M6VFh9DGgzMwGn8g4CHId?usp=sharing)

---

## Licença

[Informações sobre a licença do seu projeto.]
