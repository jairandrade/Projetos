#Include "Protheus.ch"
#include "rwmake.ch"
#include "TbiConn.ch"
//==================================================================================================//
//	Programa: INCOPKPZ		|	Autor: Luis Paulo						|	Data: 05/05/2020		//
//==================================================================================================//
//	Descri��o: ROTINA MATA650 - CLONAR OP                   										//
//																									//
//==================================================================================================//
User Function INCOPKPZ()
Local cSql 			:= ""
Local lCont			:= .t.
Local lErro			:= .f.
Local cCRLF			:=  CRLF
Local nCont         := 1
Private cOpGerada     := ""
Private oDlg		:= nil
Private cWSP	    := Space(3)
Private oWSP	    := nil
Private oNumOrca	:= nil
Private nBtoOk		:= 0
Private cPrompt		:= "Informe a quantidade de copias"
Private cAlias56		

DEFINE MSDIALOG oDlg TITLE "Ordens de Producao" From 001,001 to 220,450 Pixel

nLinha := 32
@ nLinha, 02  group obroup to 100,215 PIXEL prompt cPrompt oF oDlg
nLinha += 20

@ nLinha, 005 SAY  "Qtd" SIZE 040, 007 OF oDlg  PIXEL
@ nLinha, 025 MSGET oWSP VAR cWSP SIZE 20, 010 WHEN .T. OF oDlg PIXEL PICTURE "@R 999" COLORS 0, 16777215 PIXEL
nLinha += 20

ACTIVATE MSDIALOG oDlg CENTERED ON INIT ENCHOICEBAR( oDlg,{ || nBtoOk := 1, oDlg:End() },{ || nBtoOk := 0, oDlg:End() } )

If nBtoOk == 0
        Help( ,, 'Ordens de Producao',, 'Cancelado pelo usuario!!!!!!!', 1, 0 )
        cWSP := Space(3)
        lCont := .f.
    Else
        If !EMpty(cWSP)
 
                If Alltrim(SC2->C2_ITEM) == "01" .And. Alltrim(SC2->C2_SEQUEN) == "001"
                        
                        For nCont := 1 to Val(cWSP)
                            /*
                            If !StartJob("U_INCORDEMK", GetEnvServer(), .T., SC2->(RECNO()))
                                    Exit
                                Else
                                    
                            EndIf
                            */
                            INCORDEMK(SC2->(RECNO()))
                            Sleep(1500)
                        Next
                        
                        cOpGerada := Substr(cOpGerada,1, (Len(cOpGerada))-1 )

    
                        If Empty(cOpGerada)
                                Help( ,, 'Ordens de Producao',, 'Ops n�o foram geradas!!', 1, 0 )         
                            Else
                                Help( ,, 'Ordens de Producao',, 'Ops geradas: ' +cOpGerada , 1, 0 )
                        EndIf

                    Else 
                        Help( ,, 'Ordens de Producao',, 'Posicione na OP principal(nao e permitido ops intermediarias)!!', 1, 0 )
                EndIf

            else
                Help( ,, 'Ordens de Producao',, 'Informe a quantidade de repeticoes!!', 1, 0 )
        EndIf   

EndIf

Return()


Static Function INCORDEMK(nRecc2)
Local lRet          := .t.
Local aArea         := GetArea()
Local aMATA650      := {} //-Array com os campos
Local cNumOp        := ""
Local cEmpNew 		:= "04"
Local cFilNew		:= "01"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 3 - Inclusao ³
//³ 4 - Alteracao ³
//³ 5 - Exclusao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpc          := 3
Local cItemGrd	    := ""
Private lMsErroAuto := .F.
/*	
Conout("Criando NFSE na 0401...")
conout("cEmpNew = " + cEmpNew)
conout("cFilNew = " + cFilNew)

//Seta a nova empresa
RpcClearEnv()
//RpcSetType(3)
lConec := RpcSetEnv(cEmpNew, cFilNew,"LUIS PAULO","190854","FAT")
*/
DbSelectArea("SB1")
DbSelectArea("SG1")
DbSelectArea("SD4")

cNumOP := GetSXENum('SC2','C2_NUM')
SC2->(dbSetOrder(1))
While SC2->(MsSeek(FwXFilial("SC2")+cNumOP))
    If ( __lSx8 )
        ConfirmSX8()
    EndIf
    cNumOP := GetSxENum("SC2","C2_NUM")
EndDo

DbSelectArea("SC2")
SC2->(DbGoTop())
SC2->(DbGoTo(nRecc2))

cItemGrd	    := CriaVar("C2_ITEMGRD")

//596648
aadd(aMata650,{'C2_FILIAL'	,SC2->C2_FILIAL 	,NIL} )
aadd(aMata650,{'C2_ITEM'	,SC2->C2_ITEM       ,NIL} )
aadd(aMata650,{'C2_SEQUEN'	,SC2->C2_SEQUEN 	,NIL} )
aadd(aMata650,{'C2_NUM'		,cNumOp				,NIL} )
aadd(aMata650,{'C2_PRODUTO'	,SC2->C2_PRODUTO    ,NIL} )
aadd(aMata650,{'C2_DATPRI'	,DDATABASE			,NIL} )
aadd(aMata650,{'C2_DATPRF'	,DDATABASE + 180    ,NIL} )
aadd(aMata650,{'C2_LOCAL'	,SC2->C2_LOCAL  	,NIL} )
aadd(aMata650,{'C2_CC' 		,SC2->C2_CC	 		,NIL} )
aadd(aMata650,{'C2_QUANT'	,SC2->C2_QUANT  	,NIL} )
aadd(aMata650,{'C2_EMISSAO'	,dDataBase			,NIL} )
aadd(aMata650,{'AUTEXPLODE'	,"S"			,NIL} )
/*
aMATA650 := {   {'C2_FILIAL'    ,SC2->C2_FILIAL ,NIL},;
                {'C2_NUM'       ,cNumOp         ,NIL},; 
                {'C2_ITEM'      ,SC2->C2_ITEM   ,NIL},; 
                {'C2_SEQUEN'    ,SC2->C2_SEQUEN ,NIL},;
                {'C2_PRODUTO'   ,SC2->C2_PRODUTO ,NIL},;
                {'C2_LOCAL'     ,SC2->C2_LOCAL  ,NIL},;
                {'C2_QUANT'     ,SC2->C2_QUANT  ,NIL},;
                {'C2_DATPRI'    ,DDATABASE      ,NIL},;
                {'C2_DATPRF'    ,DDATABASE      ,NIL},;
                {'C2_CC'        ,SC2->C2_CC     ,NIL}}
 */               
 

//{'AUTEXPLODE'   ,"S" ,NIL}}

ConOut("Inicio : "+Time())
 
MsExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)
If !lMsErroAuto
        ConOut("Sucesso! OP gerada com sucesso -> " +cNumOp)
        
        cOpGerada += cNumOp+"/"
      
    Else
        Conout("O processamento sera cancelado, verifique o erro na proxima janela!!")
        ConOut("Erro!")
        
        cRet := MostraErro()
        Conout("")
        Conout(cRet)
        Conout("")

        lRet := .f.       
EndIf
 
ConOut("Fim : "+Time())
 
RestArea(aArea)
Return(lRet)
