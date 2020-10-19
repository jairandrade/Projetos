#include "pmsicona.ch"

//
// IMPORTANTE:
// Este arquivo não contém strings para tradução,
// apenas literais utilizadas no PMS.
//

// modo de visualização do projeto
#define PMS_VIEW_TREE  1
#define PMS_VIEW_SHEET 2

// tarefa e EDT
#define PMS_TASK  1
#define PMS_WBS   2

// separador de path
#define PMS_PATH_SEP If(IsSrvUnix(), "/", "\")

// separador de extensão
#define PMS_EXT_SEP "."

// extensão do arquivo de planilha,
// tanto de orçamento quanto para projeto
#define PMS_SHEET_EXT  PMS_EXT_SEP + "pln"
#define PMS_BITMAP_EXT PMS_EXT_SEP + "bmp"

// valor de indentação na configuração de colunas (modo planilha)
#define PMS_SHEET_INDENT 4

// data mínima e data máxima
#define PMS_MAX_DATE   CToD("31/12/2050")
#define PMS_MIN_DATE   CToD("01/01/1980")

// hora mínima e hora máxima
#define PMS_MIN_HOUR "00:00"
#define PMS_MAX_HOUR "24:00"

// inicializadores
#define PMS_EMPTY_DATE   CToD("  /  /    ")
#define PMS_EMPTY_STRING ""

// folders
#define PMS_PROFILE_DIR PMS_PATH_SEP + "profile"

// item alocado na tarefa
#define PMS_ITEM_UNKNOWN  0
#define PMS_ITEM_PRODUCT  1 
#define PMS_ITEM_RESOURCE 2
#define PMS_ITEM_RESOURCE_PRODUCT PMS_ITEM_RESOURCE + PMS_ITEM_PRODUCT

//
// constantes ad hoc
//

// constantes utilizadas na toolbar

// constantes contendo os nome de arquivos
// de bitmaps, utilizadas na toolbar
#define BMP_AVANCAR_CAL     "PMSSETADIR"
#define BMP_CANCEL          "CANCEL"
#define BMP_COLUNAS         "SDUFIELDS"
#define BMP_CORES           "PMSCOLOR"
#define BMP_DATA            "BTCALEND"
#define BMP_DOCUMENTOS      "CLIPS"
#define BMP_FERRAMENTAS     "INSTRUME"
#define BMP_FILTRO          "FILTRO"
#define BMP_IMPRIMIR        "IMPRESSAO"
#define BMP_OPCOES          "NCO"
#define BMP_ORC_ESTRUTURA   "SDUSTRUCT"
#define BMP_ORC_IMPRESSAO   "IMPRESSAO"
#define BMP_ORC_INFO        "UPDWARNING"
#define BMP_PESQUISAR       "PESQUISA"
#define BMP_PROJ_APONT      "NCO"
#define BMP_PROJ_CONSULTAS  "GRAF2D"
#define BMP_PROJ_ESTRUTURA  "SDUSTRUCT"
#define BMP_PROJ_EXECUCAO   "PROJETPMS"
#define BMP_PROJ_INFO       "UPDWARNING"
#define BMP_PROJ_PROG_FIS   "SELECTALL"
#define BMP_PROJ_USUARIOS   "BMPUSER"
#define BMP_REAJUS_CUSTO    "PRECO"
#define BMP_RETROCEDER_CAL  "PMSSETAESQ"
#define BMP_SAIR            "CANCEL"

//
// definicao dos resources utilizados no PMS
//
#define BMP_EDT1             "BPMSEDT1"
#define BMP_EDT2             "BPMSEDT2"
#define BMP_EDT3             "BPMSEDT3"
#define BMP_EDT4             "BPMSEDT4"
#define BMP_TASK1            "PMSTASK1"
#define BMP_TASK2            "PMSTASK2" 
#define BMP_TASK3            "PMSTASK3" 
#define BMP_TASK4            "PMSTASK4" 
#define BMP_TASK5            "PMSTASK5" 
#define BMP_TASK6            "PMSTASK6" 
#define BMP_USER             "BMPUSER" 
#define BMP_USER_PQ          "BMPUSER_PQ"
#define BMP_EXPALL           "PMSEXPALL"
#define BMP_EXPCMP           "PMSEXPCMP"
#define BMP_SHORTCUTMINUS    "SHORTCUTMINUS"
#define BMP_SHORTCUTPLUS     "SHORTCUTPLUS"
#define BMP_CLIPS_PQ         "CLIPS_PQ"
#define BMP_RELAC_DIREITA_PQ "RELACIONAMENTO_DIREITA_PQ"
#define BMP_SETA_UP          "PMSSETAUP"
#define BMP_SETA_DOWN        "PMSSETADOWN" 
#define BMP_SETA_TOP         "PMSSETATOP"
#define BMP_ZOOM_OUT         "PMSZOOMOUT"
#define BMP_ZOOM_IN          "PMSZOOMIN"
#define BMP_SETA_BOTTOM      "PMSSETABOT"
#define BMP_IMPRESSAO        "IMPRESSAO"
#define BMP_SETA_DIREITA     "PMSSETADIR"
#define BMP_SETA_ESQUERDA    "PMSSETAESQ"
#define BMP_SALVAR           "SALVAR"
#define BMP_RELOAD           "RELOAD"
#define BMP_PESQUISA         "PESQUISA"
#define BMP_RELATORIO        "RELATORIO"
#define BMP_DOCUMENT         "PMSDOC"
#define BMP_RECURSO          "BPMSREC"
#define BMP_MATERIAL         "PMSMATE"
#define BMP_FAIXA_SUPERIOR   "PMSSUPE"
#define BMP_PROJETOAP        "PROJETOAP"
#define BMP_FAIXA_SUP_PADRAO "FAIXASUPERIOR"

#define BMP_EDT4_INCLUIDO    "BPMSEDT4I"
#define BMP_EDT4_EXCLUIDO    "BPMSEDT4E"
#define BMP_EDT4_ALTERADO    "BPMSEDT4A"

#define BMP_TASK3_INCLUIDO    "BPMSTSK3I"
#define BMP_TASK3_EXCLUIDO    "BPMSTSK3E"
#define BMP_TASK3_ALTERADO    "BPMSTSK3A"

#define BMP_BUDGET            "BUDGET"
#define BMP_INTERROGACAO      "S4WB016N"

#define BMP_RECURSO_INCLUIDO  "BPMSRECI"
#define BMP_RECURSO_EXCLUIDO  "BPMSRECE"
#define BMP_RECURSO_ALTERADO  "BPMSRECA"

#define BMP_RELACIONAMENTO_INCLUIDO "BPMSRELAI"
#define BMP_RELACIONAMENTO_ALTERADO "BPMSRELAA"
#define BMP_RELACIONAMENTO_EXCLUIDO "BPMSRELAE"

#define BMP_CHECKED                 "CHECKED"
#define BMP_NOCHECKED               "NOCHECKED"
#define BMP_SDUPROP                 "SDUPROP"

#define BMP_NEXT                    "NEXT"
#define BMP_PROCESSA                "PROCESSA"

#define BMP_TRIANGULO_DOWN          "TRIDOWN"
#define BMP_TRIANGULO_UP            "TRIUP"
#define BMP_TRIANGULO_LEFT          "TRILEFT"
#define BMP_TRIANGULO_RIGHT         "TRIRIGHT"

#define BMP_LOGIN                   "LOGIN"

#define BMP_EXCEL                   "MDIEXCEL"
#define BMP_OUTLOOK "OUTLOOK"

#define BMP_OPEN                    "OPEN"
#define BMP_E5                      "E5"

#define BMP_OK                      "OK"
#define BMP_CANCELA                 "CANCEL"

#define BMP_RELACIONAMENTO_DIREITA  "RELACIONAMENTO_DIREITA"

#define BMP_TOOLBAR                 "TOOLBAR"
#define BMP_TABLE                   "BMPTABLE"
#define BMP_TABLE_PQ                "BMPTABLE_PQ"

#define BMP_CHECKBOX                 "LBOK"
#define BMP_UNCHECKBOX               "LBNO"

#define BMP_CINZA                    "BR_CINZA"
#define BMP_VERDE                    "BR_VERDE"
#define BMP_VERMELHO                 "BR_VERMELHO"
#define BMP_AMARELO                  "BR_AMARELO"
#define BMP_AZUL                     "BR_AZUL"

#define BMP_SIMULACAO_ALOCACAO_RECURSOS "GRAF2D"

// as constantes abaixo estao presentes
// no arquivo pmsicona.ch

// seus nomes comecam com STR0P para evitar
// conflito com strings ja existentes

// descricoes dos botoes da toolbar
#define TOOL_AVANCAR_CAL    STR0P39 //"Avancar"
#define TOOL_CANCEL         STR0P34 //"Cancelar" 
#define TOOL_COLUNAS        STR0P05 //"Colunas"
#define TOOL_CORES          STR0P40 //"Cores"
#define TOOL_DATA           STR0P41 //"Data"
#define TOOL_DOCUMENTOS     STR0P10 //"Docum."
#define TOOL_FERRAMENTAS    STR0P06 //"Ferramentas"
#define TOOL_FILTRO         STR0P03 //"Filtro"
#define TOOL_IMPRIMIR       STR0P33 //"Imprimir"
#define TOOL_OPCOES         STR0P42 //"Opcoes"
#define TOOL_ORC_ESTRUTURA  STR0P27 //"Estrut."
#define TOOL_ORC_IMPRESSAO  STR0P13 //"Imprimir"
#define TOOL_ORC_INFO       STR0P12 //"Inform."
#define TOOL_PESQUISAR      STR0P09 //"Pesquisar"
#define TOOL_PROJ_APONT     STR0P11 //"Apont."
#define TOOL_PROJ_CONSULTAS STR0P02 //"Consultas"
#define TOOL_PROJ_ESTRUTURA STR0P07 //"Estrut."
#define TOOL_PROJ_EXECUCAO  STR0P04 //"Execucao"
#define TOOL_PROJ_INFO      STR0P01 //"Inform."
#define TOOL_PROJ_PROG_FIS  STR0P32 //"Prg. Fis."
#define TOOL_PROJ_USUARIOS  STR0P08 //"Usuarios"
#define TOOL_REAJUS_CUSTO   STR0P28 //"Custo"
#define TOOL_RETROCEDER_CAL STR0P43 //"Retroceder"
#define TOOL_SAIR           STR0P35 //"Sair"

// tooltips dos botoes da toolbar
#define TIP_AVANCAR_CAL     STR0P44 //"Avancar Calendario"
#define TIP_CANCEL          STR0P37 //"Cancelar"
#define TIP_COLUNAS         STR0P18 //"Configurar colunas"
#define TIP_CORES           STR0P45 //"Configurar cores do grafico"
#define TIP_DATA            STR0P46 //"Data"
#define TIP_DOCUMENTOS      STR0P23 //"Documentos"
#define TIP_FERRAMENTAS     STR0P19 //"Ferramentas"
#define TIP_FILTRO          STR0P16 //"Filtrar visualizacao"
#define TIP_IMPRIMIR        STR0P36 //"Imprimir"
#define TIP_OPCOES          STR0P47 //"Opcoes do Grafico"
#define TIP_ORC_ESTRUTURA   STR0P29 //"Estrutura do Orcamento" 
#define TIP_ORC_IMPRESSAO   STR0P26 //"Impressao do Orcamento"
#define TIP_ORC_INFO        STR0P25 //"Informacoes do Orcamento"
#define TIP_PESQUISAR       STR0P22 //"Pesquisar"
#define TIP_PROJ_APONT      STR0P24 //"Apontamentos do Projeto"
#define TIP_PROJ_CONSULTAS  STR0P15 //"Consultas"
#define TIP_PROJ_ESTRUTURA  STR0P20 //"Estrutura do Projeto"
#define TIP_PROJ_EXECUCAO   STR0P17 //"Gerenciamento de execucao"
#define TIP_PROJ_INFO       STR0P14 //"Informacoes do Projeto"
#define TIP_PROJ_PROG_FIS   STR0P31 //"Progresso Fisico do Projeto"
#define TIP_PROJ_USUARIOS   STR0P21 //"Usuarios"
#define TIP_REAJUS_CUSTO    STR0P30 //"Reajustar Custo Previsto"
#define TIP_RETROCEDER_CAL  STR0P48 //"Retroceder Calendario"
#define TIP_SAIR            STR0P38 //"Sair"

// constantes para o array de simulações
// de tarefas na realocação
#define SIM_QTDELEM   17
#define SIM_RECAF9     1
#define SIM_START      2
#define SIM_HORAI      3
#define SIM_FINISH     4
#define SIM_HORAF      5
#define SIM_REVISA     6
#define SIM_RECURS     7
#define SIM_ALOC       8
#define SIM_PRIORI     9
#define SIM_HDURAC    10
#define SIM_QUANT     11
#define SIM_PROJETO   12
#define SIM_TAREFA    13
#define SIM_CALEND    14
#define SIM_DESCRI    15
#define SIM_PREDEC    16
#define SIM_USERINFO  17


#define ATA_PROJINFO       "0100."
#define ATA_COLUNAS        "0200."
#define ATA_FERRAMENTAS    "0300."
#define ATA_FILTRO         "0400."
#define ATA_PROJ_CONSULTAS "0500."
#define ATA_PROJ_ESTRUTURA "0600."
#define ATA_DOCUMENTOS     "0700."
#define ATA_PROJ_EXECUCAO  "0800."
#define ATA_PROJ_PROG_FIS  "0900."
#define ATA_PROJ_APONT     "1000."
