# ⚡ HashPilot

![Aviso](https://img.shields.io/badge/Usage-Educational%20Only-red)  

**Uso:** fins educacionais e testes autorizados apenas.  
**Autor:** CyberSecurity0000 — versão refatorada com assistência de IA disponível.

---

## Descrição
**HashPilot** é uma **ferramenta menu-driven em Bash** que organiza execuções do **hashcat** para fins educativos: testes de hash, wordlists, máscaras e geração de relatórios. Mantém interface interativa simples para experimentar técnicas de forma controlada.

---

## Status
- **Interface:** menu interativo (Bash)  
- **Motor de cracking:** hashcat (obrigatório no PATH)  
- **Destinado a:** laboratórios, estudo e testes autorizados  
- **Recomendado:** usar a versão `-clean` para demos e integrações

---

## 🔁 Versões incluídas
- `src/hashpilot-original.sh` — versão **original**, criada por **CyberSecurity0000**.  
- `src/hashpilot-clean.sh` — versão **refatorada e segura** (melhorada com assistência de IA). Mesma interface; corrigidos nomes de funções, tratamento de erros, checagem de dependências, paths configuráveis, proteção de variáveis e `read -r`. **Recomendada para uso.**

> Ambas existem para fins de estudo: compare, aprenda e use a `-clean` para execução.

---

## Requisitos
- `bash` (recomendado ≥ 4)  
- `hashcat` instalado e acessível via `PATH`  
- Espaço para logs e potfiles (`~/.local/share/hashcat/` por padrão ou `./reports/`)  
- Opcional: `shellcheck` (lint), `jq` (saída JSON futura)

---

## Instalação rápida

### Debian / Ubuntu / Kali
```bash
sudo apt update
sudo apt install -y git hashcat shellcheck jq
git clone https://github.com/CyberSecurity0000/hashpilot.git
cd hashpilot/src
chmod +x hashpilot-clean.sh
