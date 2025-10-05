# HashPilot 🚀

Ferramenta **menu-driven** em Bash para executar e organizar testes com **hashcat**.  
Mantém a interface original do programa, mantendo funcionalidade e saída de logs, porém com linguagem neutra e focada em uso educacional.

---

## Status
- Implementação: Menu interativo (Bash)  
- Objetivo: facilitar execução de sessões hashcat, restaurar sessões e coletar resultados para estudo e automação local  
- Aviso: use apenas em ambientes e arquivos aos quais você tem autorização.

---

## Requisitos
- `bash` (recomendado ≥ 4)  
- `hashcat` instalado e disponível no `PATH`  
- Espaço para salvar logs e potfiles (por padrão o script utiliza `~/.local/share/hashcat/`)  
- opcional: `shellcheck` para lint, `jq` para saída JSON

---

## Instalação (rápida)

### 1) Em Debian / Ubuntu / Kali
```bash
# atualiza e instala dependências
sudo apt update && sudo apt install -y git hashcat shellcheck jq

# clonar o repo (exemplo)
git clone https://github.com/CyberSecurity0000/hashpilot.git
cd hashpilot/src

# permissão de execução
chmod +x hashpilot.sh
