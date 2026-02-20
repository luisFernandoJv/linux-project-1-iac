#!/bin/bash

# Configurações de cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sem cor

echo -e "${YELLOW}Iniciando provisionamento de infraestrutura...${NC}"

# 1. Definição de Arrays para evitar repetição (DRY - Don't Repeat Yourself)
GRUPOS=("GRP_ADM" "GRP_VEN" "GRP_SEC")
DIRETORIOS=("/publico" "/adm" "/ven" "/sec")

# 2. Criando Grupos
echo -e "${GREEN}Criando grupos de usuários...${NC}"
for grupo in "${GRUPOS[@]}"; do
    groupadd -f "$grupo"
done

# 3. Criando Diretórios e ajustando permissões base
echo -e "${GREEN}Criando e protegendo diretórios...${NC}"
for dir in "${DIRETORIOS[@]}"; do
    mkdir -p "$dir"
done

# 4. Criando Usuários em massa
# Formato: "usuario:grupo"
USUARIOS=(
    "carlos:GRP_ADM" "maria:GRP_ADM" "joao:GRP_ADM"
    "debora:GRP_VEN" "sebastiana:GRP_VEN" "roberto:GRP_VEN"
    "josefina:GRP_SEC" "amanda:GRP_SEC" "rogerio:GRP_SEC"
)

PASSWORD=$(openssl passwd -6 senha123)

echo -e "${GREEN}Provisionando contas de usuários...${NC}"
for item in "${USUARIOS[@]}"; do
    user=$(echo $item | cut -d: -f1)
    grupo=$(echo $item | cut -d: -f2)
    
    # -p: senha encriptada | -m: cria home | -s: shell padrão | -G: grupo adicional
    useradd "$user" -m -s /bin/bash -p "$PASSWORD" -G "$grupo"
    echo "Usuário $user adicionado ao grupo $grupo"
done

# 5. Aplicando permissões específicas
echo -e "${GREEN}Refinando permissões de segurança...${NC}"

# Público: Total acesso, mas com 'Sticky Bit' (+t) para usuários não deletarem arquivos uns dos outros
chmod 1777 /publico

# Departamentais
chown root:GRP_ADM /adm && chmod 770 /adm
chown root:GRP_VEN /ven && chmod 770 /ven
chown root:GRP_SEC /sec && chmod 770 /sec

echo -e "${YELLOW}Infraestrutura provisionada com sucesso!${NC}"
