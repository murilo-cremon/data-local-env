# 🐳 data-local-env

Ambiente local de **Engenharia de Dados e Analytics** orquestrado via Docker Compose.

O objetivo deste repositório é fornecer uma **infraestrutura base reutilizável e independente de projeto**, simulando um stack moderno de dados com ferramentas amplamente utilizadas no mercado.

> DAGs do Airflow, modelos dbt, scripts de ingestão e demais códigos de negócio ficam em seus próprios repositórios de projeto — este repo é exclusivamente de infraestrutura.

---

## 🏗️ Arquitetura

```
┌──────────────────┐
│ PostgreSQL (OLTP)│  ← Fonte de dados (sistema transacional)
└────────┬─────────┘
         │ extração
┌────────▼─────────┐
│     Airflow       │  ← Orquestração dos pipelines
└────────┬─────────┘
         │ carga
┌────────▼─────────┐
│      MinIO        │  ← Object Storage S3-compatible
│  landing-zone/    │     arquivos Parquet, CSV, JSON...
│  processed/       │
│  curated/         │
└────────┬─────────┘
         │ transformação
┌────────▼──────────┐
│ DuckDB/MotherDuck  │  ← Data Warehouse (externo, sem Docker)
└────────┬──────────┘
         │
┌────────▼─────────┐
│       dbt         │  ← Transformações (externo, via pip)
└──────────────────┘
```

---

## 🛠️ Serviços

| Serviço | Descrição | Porta |
|---|---|---|
| **postgres-oltp** | Banco relacional simulando um sistema transacional (fonte dos dados) | `5432` |
| **postgres-airflow** | Banco de metadados interno do Airflow | `5433` |
| **minio** | Object storage S3-compatible para a landing zone | `9000` (API) / `9001` (Console) |
| **airflow-webserver** | Interface web para monitorar e acionar DAGs | `8080` |
| **airflow-scheduler** | Processo que agenda e dispara as DAGs | — |

> **DuckDB/MotherDuck** e **dbt** rodam fora do Docker, instalados via `pip` em cada projeto.

---

## 📁 Estrutura do repositório

```
data-local-env/
├── docker-compose.yml
├── .env                  ← credenciais locais (não versionado)
├── .env.example          ← template das variáveis (versionado)
├── .gitignore
├── README.md
└── postgres/
    └── init/             ← scripts SQL executados na inicialização
        ├── 01_schema.sql
        └── 02_seed.sql
```

---

## 🚀 Como usar

### Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/) v2+

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/data-local-env.git
cd data-local-env
```

### 2. Configure as variáveis de ambiente

```bash
cp .env.example .env
# edite o .env com suas credenciais
```

### 3. Suba o ambiente

```bash
docker compose up -d
```

### 4. Acompanhe a inicialização do Airflow

```bash
docker compose logs -f airflow-init
```

Aguarde a conclusão antes de acessar o Airflow.

---

## 🔐 Acessos

| Serviço | URL | Usuário | Senha |
|---|---|---|---|
| Airflow | http://localhost:8080 | `admin` | `admin` |
| MinIO Console | http://localhost:9001 | `minio_access_key` | `minio_secret_key` |
| PostgreSQL OLTP | `localhost:5432` | `oltp_user` | `oltp_password` |

> As credenciais acima refletem os valores padrão do `.env.example`. Altere no seu `.env` local.

---

## 🗄️ Buckets MinIO

Criados automaticamente ao subir o ambiente:

| Bucket | Descrição |
|---|---|
| `landing-zone` | Dados brutos extraídos do OLTP |
| `processed` | Dados após limpeza e padronização |
| `curated` | Dados prontos para consumo analítico |

---

## 🗃️ Scripts SQL do PostgreSQL

Coloque seus arquivos `.sql` em `postgres/init/`. Eles são executados **automaticamente e em ordem alfabética** na primeira vez que o container sobe.

> ⚠️ Os scripts só rodam quando o volume está vazio. Para recriar do zero:
> ```bash
> docker compose down -v && docker compose up -d
> ```

---

## ⏹️ Comandos úteis

```bash
# Subir o ambiente
docker compose up -d

# Parar sem remover dados
docker compose down

# Parar e remover todos os volumes (reset completo)
docker compose down -v

# Ver logs de um serviço
docker compose logs -f airflow-scheduler

# Status dos containers
docker compose ps
```
