#Include 'Protheus.ch'
#Include 'RWMAKE.ch'
/*/{Protheus.doc} APON001
Funcao para regras de autorizacao para manipular ponto. 
@type function
@author luizf
@since 17/08/2016
/*/
User Function APON001()

//+----------------------------------------------------------------------------+
//! Declaracao de variaveis...                                                 !
//+----------------------------------------------------------------------------+
PRIVATE cCadastro := "Usuários Liberados para Ajuste no Ponto."
PRIVATE aRotina   := {}    

//+----------------------------------------------------------------------------+
//! Inclusao de opcoes para navegacao...                                       !
//+----------------------------------------------------------------------------+
AADD( aRotina, {"Pesquisar" ,"AxPesqui" ,0,1})
AADD( aRotina, {"Visualizar" ,'AxVisual',0,2})
AADD( aRotina, {"Incluir" ,'AxInclui',0,3})
AADD( aRotina, {"Alterar" ,'AxAltera',0,4})
AADD( aRotina, {"Excluir" ,'AxDeleta',0,5})
AADD( aRotina, {"Data Limite" ,'U_APONB01',0,5})

//+----------------------------------------------------------------------------+
//! Monta a interface.                                                         !
//+----------------------------------------------------------------------------+
MBrowse(006,001,022,075,"ZAB")

Return


/*/{Protheus.doc} APONB01
Atualizacao do Parametro para data limite dos usuarios, para alteração das marcacoes e apontamentos.
@type function
@author luizf
@since 17/08/2016
/*/
User Function APONB01()

LOCAL nAcao :=0
LOCAL dDtLim := GETMV("TCP_DTPON")
LOCAL oDlg1

DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Data de Fechamento") from 150, 030 TO 250, 300  PIXEL	
@ 005, 005 Say "Data atual -> "
@ 005, 045 GET dDtLim SIZE 40,15 
@ 020, 045 BMPBUTTON TYPE 1 ACTION (nAcao:= 1,oDlg1:END())
@ 020, 085 BMPBUTTON TYPE 2 ACTION oDlg1:END()

ACTIVATE DIALOG oDlg1 CENTERED

If nAcao == 1 .And.;
	 (Aviso("Confirmação para Alteração.","Confirma a alteração da Data Limite para ajustes do ponto para "+DToC(dDtLim)+"?",{"Sim","Não"})==1)
	PUTMV("TCP_DTPON", dDtLim)
EndIf

Return

/*/{Protheus.doc} APONV01
Função genérica para validar a digitacao do ponto. 
A regra é todos os usuarios bloqueados exceto os contidos na tabela customizada.
@type function
@author luizf
@since 17/08/2016
/*/
User Function APONV01(dData,cCpo)
// nCpo 1=
LOCAL lRet      := .T.
LOCAL dDtComp   := dData
LOCAL nPosDt    := 0
LOCAL nPosQT    := 0
LOCAL nPosdES   := 0
LOCAL nPosdAb   := 0
LOCAL aArea     := GetArea()

//Tratamento para PONA280 Integrados.
LOCAL lP8DataVld	:= .T.
LOCAL lGetDados		:= .F.
LOCAL lAlterou		:= .F.

DEFAULT cCpo    := ""
DBSelectArea("ZAB")
DBSetOrder(01)//ZAB_FILIAL+ZAB_USER
If !ZAB->(MSSeek(xFilial("ZAB")+__cUserID))

If ValType(dDtComp) == "D"//Quando a data é passada por parmatro faz a validacao e sai da rotina.
	If dDtComp < GETMV("TCP_DTPON")
		Aviso("Periodo Bloqueado.","Alteração não permitida, período bloqueado para ajustes.",{"Fechar"})
		Return .F.
	EndIf
	Return .T.
EndIf

//Tratamento para a tela de Integrados
	If AllTrim(FunName()) == "PONA280" .And. Subs(cCpo,1,3) == "P8_"
		lGetDados := (;
						( Type( "aHeader" ) == "A" ) .and. ;
						( Type( "aCols"	  ) == "A" ) .and. ;
						( GdFieldPos("P8_DATA") > 0 ) ;
					  )	
					  
		IF ( lGetDados )
			If GdFieldGet("P8_DATA")	< GETMV("TCP_DTPON")
					Aviso("Periodo Bloqueado.","Alteração não permitida, período bloqueado para ajustes.",{"Fechar"})
					Return .F.
			EndIf			
		EndIF
		Return .T.
	EndIf



	//PC_PDI PC_ABONO PC_QTABONO
	//Quando chamado pela rotina Manutenção dos apontamentos. PONA130 ou Integrados.
	If AllTrim(FunName()) == "PONA130" .Or. FunName()=="PONA280" //!IsInCallStack( "PONA280" )
		nPosDt    := ASCAN(aHeader,{|x| alltrim(x[2]) == "PC_DATA"}) 
		nPosQT    := ASCAN(aHeader,{|x| alltrim(x[2]) == "PC_QTABONO"})
		nPosdAb   := ASCAN(aHeader,{|x| alltrim(x[2]) == "PC_ABONO"})
		nPosdES   := ASCAN(aHeader,{|x| alltrim(x[2]) == "PC_DESCABO"}) 
		dDtComp   := aCols[n][nPosDt]
	EndIf

	If dDtComp < GETMV("TCP_DTPON")
	    If (AllTrim(FunName()) == "PONA130" .Or. FunName()=="PONA280") .And. Alltrim(cCpo) == "PC_ABONO".And. Empty(aCols[n][nPosdAb])
			aCols[n][nPosQT] := 0
			M->PC_QTABONO    := 0
		    aCols[n][nPosdES]:= Space(TamSX3("PC_DESCABO")[1])	
		    M->PC_DESCABO    := Space(TamSX3("PC_DESCABO")[1])			
		EndIf
		lRet:= .F.
		Aviso("Periodo Bloqueado.","Alteração não permitida, período bloqueado para ajustes.",{"Fechar"})
	EndIf
EndIf
RestArea(aArea)
Return lRet