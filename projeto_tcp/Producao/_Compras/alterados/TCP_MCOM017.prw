#DEFINE aPos  {  15,  1, 70, 315 }
#INCLUDE "protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MCOM017   �Autor  �Microsiga           � Data �  30/05/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MCOM017()

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
                                                                                               


	PRIVATE aRotina := {	{ "Pesquisar"	,	"AxPesqui"  	, 0 , 1},;			//"Pesquisar"
							{ "Visualizar"	,	"AxVisual"  	, 0 , 2},;		 	//"Visualizar"
							{ "Legenda"		,	'U_LegLog()'	, 0 , 6},;
							{ "Reenvio de Avalia��o",'U_RCOM009()', 0 , 7}}
                                     
aCores := { { "ZZB->ZZB_STATUS = '1' ", 'BR_VERDE'    },;    // Ativado do Financeiro
            { "ZZB->ZZB_STATUS = '2' ", 'BR_VERMELHO' }} 	// Desativado no Financeiro

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi("LOG Envio e-mails Qualif. Fornece")

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"ZZB",,,,,,aCores)

dbSelectArea("ZZB")
SET FILTER TO
Return


User Function LegLog()

cCadastro := "Log Envio e-mails"

aCores2 := { { "BR_VERDE" , "Enviado com Sucesso" },;
             { "BR_VERMELHO", "Erro no Envio" }}

BrwLegenda(cCadastro,"Legenda do Browse",aCores2)

Return
