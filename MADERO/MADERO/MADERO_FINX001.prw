#INCLUDE "Protheus.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"
/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Customização                                            !
+------------------+---------------------------------------------------------+
!Modulo            ! FINANCEIRO                                              !
+------------------+---------------------------------------------------------+
!Nome              ! FINX001                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! FUNCOES INTEGRACAO CONTAS A PAGAR - PROTHEUS X CSV      !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Andrade   										 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/10/2018                                              !
+------------------+---------------------------------------------------------+
!				   !														 !
!				   !												         !
+------------------+---------------------------------------------------------+

*/

User Function FINX001()
Local aButtons := {}
Local cCadastro := "Integração Movimentação bancária Excel X Protheus"
Local nOpca     	:= 0
Local aSays     	:= {}
Local aArea			:= GetArea()
Private cArq		:= ""

AADD(aSays,OemToAnsi("Este programa tem o objetivo importar o a movimentação bancaria do arquivo Excel..."))
AADD(aSays,OemToAnsi(""						                                                 		      ))
AADD(aSays,OemToAnsi(""																					  ))
AADD(aSays,OemToAnsi("Clique no botão parâmetros para selecionar o ARQUIVO CSV de interface."		      ))
AADD(aButtons, { 1,.T.						,{|o| (Iif(ImpArq(),o:oWnd:End(),Nil)) 						  }})
AADD(aButtons, { 2,.T.						,{|o| o:oWnd:End()											  }})
AADD(aButtons, { 5,.T.						,{|o| (AbreArq(),o:oWnd:refresh())							  }})
FormBatch( cCadastro, aSays, aButtons )
RestArea(aArea)
Return .T.

/*---------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Descricao         ! Seleciona arquivo que será copiado para a pasta         !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/10/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function AbreArq()

Local cType		:=	"Arquivos CSV|*.CSV|Todos os Arquivos|*.*"
cArq := cGetFile(cType, OemToAnsi("Selecione o arquivo de interface"),0,"C:\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

Return()
/*---------------------------------------------------------------------------+
!   DADOS DO PROGRAMA   - IMPARQ()                                           !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina que prepara a importação do arquivo              !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/10/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function ImpArq()
Local lRet := .T.
Private nHdl	:= 0

If !File(cArq)
	Aviso("Atenção !","Arquivo não selecionado ou inválido !",{"Ok"})
	Return .F.
Endif

ProcRegua(474336)

BEGIN TRANSACTION
Processa({|| Importa() },"Processando...")
END TRANSACTION

Return lRet

/*---------------------------------------------------------------------------+
!   DADOS DO PROGRAMA   - Importa()                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina que prepara a importação do arquivo              !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/10/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function Importa()
Local cLog		:= ""
Local nCont 	:= 0
Local nRepet  	:= 0
Local cEol     	:= CHR(13)+CHR(10)
Local lErroSE5 	:= .F.
Local cLinha  	:= ""
Local aDados  	:= {}
Local cFilOri 	:= cFilAnt
Local cTabelas 	:=""
Local nX := 0
Private lMsErroAuto := .F.

FT_FUSE(cArq)
FT_FGOTOP()
While !FT_FEOF()
	
	cLinha := FT_FREADLN()
	
	If !Empty(cLinha)
		AADD(aDados,Separa(cLinha,";",.T.))
	EndIf
	
	FT_FSKIP()
EndDo
FT_FUSE()

DbSelectArea("SM0")
SM0->(DbGoTop())
For nX:=2 to Len(aDados)
	
	//Verifica se filial que está no arquivo é da empresa correta
	If !SM0->(dbSeek( cEmpAnt + aDados[nX][1] ) )
		Aviso("Atenção","A filial "+Alltrim(aDados[nX][1])+" pertence a outra empresa.", {"Ok"}, 2)
		Exit
	EndIf
	
	If cFilAnt <> aDados[nX][1]
		cFilAnt := aDados[nX][1]
	EndIf
	
	//Chama a rotina de execauto
	Begin Transaction
	
	aBcOri 		:= strtokarr ( aDados[nX][2] , "|")
	aAgOri 		:= strtokarr ( aDados[nX][3] , "|")
	aContaOri 	:= strtokarr ( aDados[nX][4] , "|")
	aBcDest 	:= strtokarr ( aDados[nX][6] , "|")
	aAgDest 	:= strtokarr ( aDados[nX][7] , "|")
	aContaDest 	:= strtokarr ( aDados[nX][8] , "|")
	aDoc 		:= strtokarr ( aDados[nX][11] , "|")
	
	If !ValDoc(aBcOri[1],aAgOri[1],aContaOri[1],aDoc[1],aDados[nX][10])
		nRepet++
	Else
		nCont++
		aFINA100 := {{"CBCOORIG"        ,aBcOri[1]		,Nil},;
		{"CAGENORIG"        			,aAgOri[1]   	,Nil},;
		{"CCTAORIG"         			,aContaOri[1]  	,Nil},;
		{"CNATURORI"        			,aDados[nX][5]  ,Nil},;
		{"CBCODEST"         			,aBcDest[1]   	,Nil},;
		{"CAGENDEST"        			,aAgDest[1]   	,Nil},;
		{"CCTADEST"         			,aContaDest[1]  ,Nil},;
		{"CNATURDES"        			,aDados[nX][9]  ,Nil},;
		{"CTIPOTRAN"        			,aDados[nX][10] ,Nil},;
		{"CDOCTRAN"         			,aDoc[1]		,Nil},;
		{"NVALORTRAN"       			,Val(StrTran( aDados[nX][12], ',', '.' ))  ,Nil},;
		{"CHIST100"         			,aDados[nX][13]	,Nil},;
		{"CBENEF100"        			,aDados[nX][14]	,Nil}}
		
		MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,7)
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			Break
		EndIf
	EndIf
	
	End Transaction
	
Next nX
If lMsErroAuto
	Aviso("Atenção","A Transferência não foi executada. Verifique a linha: "+Alltrim(Str(nX)), {"Ok"}, 2)
ElseIf nCont>0
	Aviso("Concluído","Transferência executada com sucesso para a data de "+Dtoc(dDatabase)+"."+Chr(13)+ Chr(10)+"Total: "+Alltrim(Str(nCont))+" transfências", {"Ok"}, 2)
ElseIf nRepet>0
	Aviso("Concluído","Transferência já foi efetuada para a data de "+Dtoc(dDatabase)+"."+Chr(13)+ Chr(10)+"Total: "+Alltrim(Str(nRepet))+" transfências", {"Ok"}, 2)
EndIf

//retorna para a filial correta
cFilAnt :=cFilOri

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ValDoc(cBanco,cAgencia,cConta,cDocumento)
valida se o documento já existe na tabela SE5

@author Jair  Matos
@since 25/10/2018
@version P12
@return lRet
/*/
//---------------------------------------------------------------------

Static Function ValDoc(cBanco,cAgencia,cConta,cDocumento,cTipoTran)

Local lRet := .T.
Local cQuery :=""
Local nSaldo := 0

If select("TRBSE5")<>0
	TRBSE5->(dbclosearea())
EndIf

cQuery += " SELECT 1 "
cQuery += " FROM "+RetSQLName("SE5") + "  "
cQuery += " WHERE E5_FILIAL = '" + xFilial("SE5") + "' "
cQuery += " AND E5_BANCO    = '" +cBanco+ "' "
cQuery += " AND E5_AGENCIA  = '" +cAgencia+ "' "
cQuery += " AND E5_CONTA    = '" +cConta+ "' "
cQuery += " AND E5_NUMCHEQ  = '" +Alltrim(cDocumento)+ "' "
cQuery += " AND E5_RECPAG 	= 'P' "
cQuery += " AND E5_DATA		= '"+ DTOS(dDataBase) +"' "
cQuery += " AND E5_MOEDA    = '"+ cTipoTran +"' "
cQuery += " AND D_E_L_E_T_= ' ' "

TcQuery cQuery new Alias "TRBSE5"
//Memowrite("c:\temp\ValDoc.txt",CQuery)
DbSelectArea("TRBSE5")
TRBSE5->(DbGoTop())

If !TRBSE5->(EOF())
	lRet := .F.
EndIf

Return lRet
