#Include "Totvs.ch"
#include 'protheus.ch'
#Include "FwMvcDef.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"
#include "TbiCode.ch"
//==================================================================================================//
//	Programa: EXCOPKAP		|	Autor: Luis Paulo							|	Data: 05/08/2020	//
//==================================================================================================//
//	Descrição: MARK																					//
//																									//
//==================================================================================================//

//Objeto para a classe FwTemporaryTable (Cria tabela temporária no banco de dados)
Static _oSC2A0401

User Function EXCOPKAP()
Local aSize			:= MsAdvSize()
Local aPosMsSel 	:= {aSize[6]*0.04,005,aSize[6]*0.5,aSize[5]*0.5}
Private lInverte	:= .F.
Private cMark   	:= 'T'
Private cCadastro 	:= "Exclusao de Transferencias"
Private oBrw
Private oGetProt
Private oStruct		:= {}
Private aCpoBro		:= {}
Private aDados		:= {}
Private oDlg		
Private	aButtons	:={}
Private nRegs		:= 0

Aadd(aButtons,{"Excluir", {|| ExcluiTr() }, "Excluir Op" } )
Aadd(aButtons,{"Procurar", {|| ProcOp()  }, "Procurar OP" } )
//Aadd(aButtons,{"Atualiza", {|| AtualOp()  }, "Atualizar OP" } )

ArqTrab() //Funcao responsavel por carregar as informacoes de processamento

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],aSize[1] to aSize[6],aSize[5] Pixel

//oBtnSair := tButton():New(010,005,'Processar'    , oDlg, {|| Processa({ || ExcluTrf() } , "Excluindo - Aguarde")},40,12,,,,.T.)
oBrw      := MsSelect():New( "TTRB","OK","",aCpoBro,@lInverte,@cMark,aPosMsSel,,, oDlg )
oBrw:bMark := {| | Disp()}
oDlg:lMaximized     := .F.


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End(),oDlg:End()},{|| oDlg:End()},,aButtons)

TTRB->(DbCloseArea())
Return()

//procura  uma op
Static Function ProcOp()
Local 	aParamBox 	:= {}
Local nReTTRB       := 0
Private aRet 		:= {}
Private lCentered	:= .T.
Private _cTime      := TIME() // Resultado: 10:37:17
Private cData       := DTOS(Date())

AAdd(aParamBox, {1, "OP?"	    ,Space(6),"","","","",0,.F.}) // Tipo caractere


If ParamBox(aParamBox,"ORDEM DE PRODUCAO", @aRet)//@aRet Array com respostas - Par 11 salvar perguntas //,, ,lCentered,100,900, , , .T., .T.
    
    DbSelectArea("TTRB")
    TTRB->(DbSetOrder(2))
    TTRB->(DbGoTop())
    If !TTRB->(DbSeek(aRet[1]))
        MsgAlert("Op nao localizada!!","Kapazi")
    EndIf
Endif

Return()


//Processa exclusoes
Static Function ExcluiTr()
Local nCount    := 0
Local nXX       := 0
Private aOpExc  := {}

DbSelectArea("TTRB")	
TTRB->(DbGoTop())

ProcRegua(nRegs)
While !TTRB->(EOF())
	nCount++
	IncProc('Excluido Ops - ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
	
	If TTRB->OK == cMark
        //Chama a exclusao
        DbSelectArea("SC2")
        SC2->(DbGoTo(TTRB->nRec))

        ExcluiOPK()

    EndIf

	 TTRB->(DbSkip())
EndDo

For nXX := 1 To Len(aOpExc)

    DbSelectArea("TTRB")
    TTRB->(DbSetOrder(2))
    TTRB->(DbGoTop())
    If TTRB->(DbSeek(aOpExc[nXX]))
        DbSelectArea("TTRB")
        RecLock("TTRB",.F.)
        TTRB->(DbDelete())
        TTRB->(MsUnlock())
    EndIf

Next 

Return()

//Funcao para marcar o item
Static Function Disp()

DbSelectArea("TTRB")
RecLock("TTRB",.F.)
If Marked("OK")
		TTRB->OK := cMark
	Else
		TTRB->OK := ""
Endif
TTRB->(MsUnlock())

oBrw:oBrowse:Refresh()

Return()


//Funcao responsavel por carregar dos dados dados
Static Function ArqTrab()

If Select("TTRB") > 0
    TTRB->(dbCloseArea())
EndIf

AADD(oStruct,{"OK"     		,"C"	,1		,0		})
AADD(oStruct,{"Filial" 		,"C"	,2		,0		})
AADD(oStruct,{"Numero" 		,"C"	,6		,0		})
AADD(oStruct,{"Item" 		,"C"	,2		,0		})
AADD(oStruct,{"Sequen"  	,"C"	,3		,0		})
AADD(oStruct,{"Produto"  	,"C"	,15		,0		})
AADD(oStruct,{"Local"  	    ,"C"	,2		,0		})
AADD(oStruct,{"Um"  	    ,"C"	,2		,0		})
AADD(oStruct,{"Quant"  	    ,"N"	,12		,2		})
AADD(oStruct,{"Emissao"  	,"D"	,8		,0		})
AADD(oStruct,{"Obs"  	    ,"C"	,30		,0		})

AADD(oStruct,{"nRec" 		,"N"	,10		,0		})

If _oSC2A0401 <> Nil
    _oSC2A0401:Delete()
    _oSC2A0401 := Nil
Endif

_oSC2A0401 := FWTemporaryTable():New( "TTRB" )
_oSC2A0401:SetFields(oStruct)
_oSC2A0401:AddIndex("1", {"Filial","Numero","Item","Sequen","Produto"})
_oSC2A0401:AddIndex("2", {"Numero","Item","Sequen","Produto"})

//------------------
//Criação da tabela temporaria
//------------------
_oSC2A0401:Create()

//C2_FILIAL|C2_NUM|C2_ITEM|C2_SEQUEN|C2_PRODUTO|C2_LOCAL|C2_UM|C2_QUANT|C2_DATPRI|C2_DATPRF|C2_EMISSAO|C2_OBS
aCpoBro	:= {{ "OK"			,, ""           ,"@!"},;
			{ "Filial"		,, "Filial"     ,"@!"},;
			{ "Numero"		,, "Numero"     ,"@!"},;
			{ "Item"		,, "Item"       ,"@!"},;
			{ "Sequen"		,, "Sequen"     ,"@!"},;
            { "Produto"		,, "Produto"    ,"@!"},;
            { "Local"		,, "Local"      ,"@!"},;
            { "UM"		    ,, "Um"         ,"@!"},;
            { "Quant"		,, "Quant"      ,"999,999,999.99"},;
            { "Emissao"     ,, "Emissao"    ,"@!"},;
            { "Obs"		    ,, "Obs"        ,"@!"}}

aDados := CargaDados() //Funcao responsavel por carregar os dados
For nDados := 1 To Len(aDados)
	DbSelectArea("TTRB")
	RecLock("TTRB",.T.)

    TTRB->Filial      	:=  aDados[nDados][1]
    TTRB->Numero      	:=  aDados[nDados][2]
	TTRB->Item        	:=  aDados[nDados][3]
	TTRB->Sequen  		:=  aDados[nDados][4]
	TTRB->Produto		:=  aDados[nDados][5]

    TTRB->Local		    :=  aDados[nDados][6]
	TTRB->Um		    :=  aDados[nDados][7]
    TTRB->Quant		    :=  aDados[nDados][8]
    TTRB->Emissao		:=  aDados[nDados][9]
    TTRB->Obs		    :=  aDados[nDados][10]

    TTRB->nRec		  	:=  aDados[nDados][11]
	TTRB->(MsunLock())
	
	nRegs++
Next
TTRB->(DbGoTop())

Return()

//Funcao responsavel por carregar os dados
Static Function CargaDados()
Local cQuery	:= ""
Local aRet		:= {}
Local cCRLF     := CRLF
Local cChave    := ""

cQuery += " SELECT R_E_C_N_O_ NRECNO, *        "+cCRLF
cQuery += " FROM "+RetSqlName("SC2")+"     "+cCRLF
cQuery += " WHERE D_E_L_E_T_ = '' "+cCRLF
cQuery += " AND C2_QUJE = 0 "+cCRLF
cQuery += " AND C2_EMISSAO >= '20200101' "+cCRLF
cQuery += " ORDER BY C2_FILIAL,C2_NUM "+cCRLF

TcQuery cQuery New Alias "QSC2"

QSC2->(DbGoTop())
While QSC2->(!EOF())

	Aadd(aRet,{QSC2->C2_FILIAL,QSC2->C2_NUM,QSC2->C2_ITEM,QSC2->C2_SEQUEN,QSC2->C2_PRODUTO,QSC2->C2_LOCAL,QSC2->C2_UM,QSC2->C2_QUANT,stod(QSC2->C2_EMISSAO),QSC2->C2_OBS,QSC2->NRECNO})
	QSC2->(DbSkip())
EndDo
QSC2->(DbCloseArea())

Return aRet

Static Function ExcluiOPK()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 3 - Inclusao ³
//³ 4 - Alteracao ³
//³ 5 - Exclusao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpc          := 5
Local aMATA650      := {}
Local lRet          := .t.
Local cNumOp        := SC2->C2_NUM
Private lMsErroAuto := .F.
 
 
aMATA650 := {   {'C2_FILIAL'    ,SC2->C2_FILIAL ,NIL},;
                {'C2_NUM'       ,SC2->C2_NUM ,NIL},; 
                {'C2_ITEM'      ,SC2->C2_ITEM ,NIL},; 
                {'C2_SEQUEN'    ,SC2->C2_SEQUEN ,NIL},;
                {'C2_PRODUTO'   ,SC2->C2_PRODUTO ,NIL}}
 

Conout("Inicio : "+Time())
  
MsExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)
If !lMsErroAuto
        Conout("Op Excluída com Sucesso!!! " + cNumOp)
        /*
        DbSelectArea("TTRB")
        RecLock("TTRB",.F.)
        TTRB->(DbDelete())
        TTRB->(MsUnlock())
        */
        aAdd(aOpExc,cNumOp)
    Else
        lRet := .f.
        Conout("Erro na Excluída da OP!!! " + cNumOp)
        MostraErro()
EndIf
 
ConOut("Fim : "+Time())
 
Return(lRet)
