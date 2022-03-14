#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "totvs.ch"
#include "tbiconn.ch"
#include "TbiCode.ch"
#include "TOPCONN.CH"
//==================================================================================================//
//	Programa: NFTRFENT 	|	Autor: Luis Paulo									|	Data: 04/03/2021//
//==================================================================================================//
//	Descrição: Funcao para gerar a NF de entrada de transferencia                                    //
//																									//
//==================================================================================================//
User Function NFTRFENT(cXIDTRFCD,nRegNFEn)
Local aArea         := GetArea()

Local cFornec       := Alltrim( SuperGetMV("KP_FORCD01"	,.F. ,"000018"))
Local cLojFor       := Alltrim( SuperGetMV("KP_FORLJ01"	,.F. ,"20"))

Local cConFor       := Alltrim( SuperGetMV("KP_FCONTRF"	,.F. ,"001"))
Local 	cOP			:= Alltrim( SuperGetMV("KP_OPPVTRF"	,.F. ,"06")) //TRANSFERENCIA
Local cTESF4        := ""
Local aLastQuery    := {}
Local cLastQuery    := ""
Local aCabec        := {}
Local aLinha        := {}
Local aItens        := {}
Local lRet          := .f.
Private lMsErroAuto := .f.
Private cAliasF2    := GetNextAlias()

BeginSql Alias cAliasF2
    SELECT *
    FROM %TABLE:SF2% SF2
    INNER JOIN %TABLE:SD2% SD2 ON SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_DOC = SD2.D2_DOC AND SD2.%NOTDEL%
    WHERE SF2.F2_XIDTRFP = %EXP:cXIDTRFCD%
        AND SF2.F2_FILIAL = '01'
        AND SF2.F2_SERIE = '2'
        AND SF2.%NOTDEL%
endsql

aLastQuery    := GetLastQuery()
cLastQuery    := aLastQuery[2]

DbSelectArea((cAliasF2))
(cAliasF2)->(DbGoTop())

DbSelectArea("SA2")
SA2->(DbSetOrder(1))
SA2->(DbGoTop())
SA2->(DbSeek(xFilial("SA2") + cFornec + cLojFor))

aCabec   := {}
aadd(aCabec,{"F1_TIPO"   	,"N"                })
aadd(aCabec,{"F1_FORMUL" 	,"N"                })
aadd(aCabec,{"F1_DOC"    	,(cAliasF2)->F2_DOC     })
aadd(aCabec,{"F1_SERIE"  	,(cAliasF2)->F2_SERIE  })
aadd(aCabec,{"F1_EMISSAO"	,dDataBase              })
aadd(aCabec,{"F1_FORNECE"	,SA2->A2_COD            })
aadd(aCabec,{"F1_LOJA"   	,SA2->A2_LOJA           })
aadd(aCabec,{"F1_ESPECIE"	,"NF"                   })      //VERIFICAR
aadd(aCabec,{"F1_COND"		,cConFor                })     //VERIFICAR
aadd(aCabec,{"F1_EST"		,SA2->A2_EST            })
nItem := 1

//conout("")
//conout(varinfo("aCabec (SF1)",aCabec))
//conout("")

aItens := {}
While !(cAliasF2)->(EOF())
    cTESF4 := MaTesInt(1,cOP,SA2->A2_COD,SA2->A2_LOJA,"F",(cAliasF2)->D2_COD)
    
    aLinha := {}

    DbSelectArea("SB2")
    SB2->(DbSetOrder(1) )
    SB2->(DbGoTop())
    If SB2->(DbSeek( xFilial("SB2") + (cAliasF2)->D2_COD + "04")) //Busca qqr residuo de saldo que possa haver na origem
        CriaSB2((cAliasF2)->D2_COD,"04")
    EndIf

    DbSelectArea("SB1")
    SB1->(dbSetOrder(1))
    SB1->(dbGoTop())
    If SB1->(DbSeek(xFilial("SB1")+(cAliasF2)->D2_COD))
    
        aadd(aLinha,{"D1_ITEM"	,Strzero(nItem,4)       ,Nil})
        aadd(aLinha,{"D1_COD"	,(cAliasF2)->D2_COD     ,Nil})
        aadd(aLinha,{"D1_QUANT"	,(cAliasF2)->D2_QUANT   ,Nil})
        aadd(aLinha,{"D1_VUNIT"	,(cAliasF2)->D2_PRCVEN  ,Nil})
        aadd(aLinha,{"D1_TOTAL"	,(cAliasF2)->D2_TOTAL   ,Nil})
        aadd(aLinha,{"D1_LOCAL"	,"04"                   ,Nil})
        aadd(aLinha,{"D1_OPER"  ,cOP                    ,Nil})
        aadd(aLinha,{"D1_TES"   ,cTESF4                 ,Nil})
        aadd(aLinha,{"D1_CC"	,SB1->B1_XCCTRF         ,Nil})         //Definido em 18/03/21 que seria o cc 490020002

        aadd(aItens,aLinha)
        
        nItem ++

    EndIf
     
    (cAliasF2)->(DbSkip())

EndDo

//conout("")
//conout(varinfo("aItens (SD1)",aItens))
//conout("")

If Len(aCabec) > 0 .And. Len(aItens) > 0
    MSExecAuto({ |x,y,z| Mata103(x,y,z)},aCabec,aItens,3)

    If lMsErroAuto
            MostraErro() 
        Else
            nRegNFEn := SF1->(RECNO())
            
            Reclock("SF1",.F.)
            SF1->F1_XIDTRFP := cXIDTRFCD
            SF1->(MsUnlock())
            
            Sleep(1500)

            If U_EndNFEnt(SF1->F1_FILIAL,SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_FORNECE,SF1->F1_LOJA)
                lRet := .t.
            EndIf 
    EndIf

EndIf

(cAliasF2)->(DbCloseArea())

RestArea(aArea)
Return(lRet)


/*/{Protheus.doc} nomeStaticFunction

    @type  Static Function
    @author user
    @since 28/02/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function EndNFEnt(__cFilNF,__cSerie,__cNota,__cFornec,__cLoja)
Local aArea         := GetArea()
Local aAreaB1       := SB1->(GetArea())
Local aAreaBE       := SBE->(GetArea())
Local aCab          := {}
Local aItens        := {}
Local cEndereco     := "EXPEDICAO"
Local lRet          := .t.
Local aLastQuery    := ""
Local cLastQuery    := {}

Local _cAmz         := ""
local _cEndere      := ""

Private lMsErroAuto	:= .F.
Private cAliasDA    :=  GetNextAlias()

If IsInCallStack("u_RETSLDKI")  .And. cFilAnt == "01"
        _cAmz      := "NC"
        _cEndere   := "NCC"
    //ElseIf IsInCallStack("u_RETSLDKI")  .And. cFilAnt == "08"
    //    _cAmz      := "RT"
    //    _cEndere   := "RETORNO"

    Else //é uma devolucaoORM
        _cAmz      := "04"
        _cEndere   := "EXPEDICAO"    
EndIf


BeginSql Alias cAliasDA

    SELECT *
    FROM SDA040 SDA
    LEFT JOIN SDB040 SDB ON SDB.DB_FILIAL = SDA.DA_FILIAL AND SDA.DA_PRODUTO = SDB.DB_PRODUTO AND SDA.DA_DOC = SDB.DB_DOC AND SDA.DA_ORIGEM = SDB.DB_ORIGEM AND SDA.DA_DATA = SDB.DB_DATA  AND SDB.D_E_L_E_T_ = ''
    WHERE SDA.D_E_L_E_T_ = ''
    AND DA_FILIAL = %EXP:__cFilNF%
    AND DA_SERIE = %EXP:__cSerie%
    AND DA_DOC = %EXP:__cNota% 
    AND DA_CLIFOR =  %EXP:__cFornec% 
    AND DA_LOJA =  %EXP:__cLoja%
    AND DA_ORIGEM = 'SD1'
    AND DA_QTDORI = DA_SALDO

endsql

aLastQuery    := GetLastQuery()
cLastQuery    := aLastQuery[2]

DbSelectArea((cAliasDA))
(cAliasDA)->(DbGoTop())

While !(cAliasDA)->(EOF())

    DbSelectArea("SBE") //BE_FILIAL, BE_LOCAL, BE_LOCALIZ, BE_ESTFIS, R_E_C_N_O_, D_E_L_E_T_
    SBE->(DbSetOrder(1))
    SBE->(DbGoTop())
    If SBE->(DbSeek((cAliasDA)->DA_FILIAL + (cAliasDA)->DA_LOCAL + _cEndere))
        aCab := {}
        AAdd( aCab, {"DA_PRODUTO", (cAliasDA)->DA_PRODUTO	, nil} )
        AAdd( aCab, {"DA_NUMSEQ" , (cAliasDA)->DA_NUMSEQ	, nil} )

        aItens := {}
        AAdd( aItens, {"DB_ITEM"   , "0001"						    , nil} )
        AAdd( aItens, {"DB_ESTORNO", " "							, nil} )
        AAdd( aItens, {"DB_LOCALIZ", Padr(_cEndere, 15)			, nil} )
        AAdd( aItens, {"DB_QUANT"  , (cAliasDA)->DA_SALDO			, nil} )
        AAdd( aItens, {"DB_NUMSERI", Space(TamSx3("DB_NUMSERI")[01]), nil} )
        AAdd( aItens, {"DB_DATA"   , Date()							, nil} )

        lMsErroAuto	:= .F.

        MsExecAuto( {|x, y, z| mata265(x, y, z)}, aCab, {aItens}, 3 )

        If lMsErroAuto
            mostraerro()
            lRet := .f.
        Endif

    EndIf

    (cAliasDA)->(DbSkip())
EndDo 

(cAliasDA)->(DbCloseArea())

RestArea(aArea)    
Return(lRet)

/*
Static Function EnderTrf()
Local aArea         := GetArea()
Local aAreaB1       := SB1->(GetArea())
Local aAreaBE       := SBE->(GetArea())
Local aCab          := {}
Local aItens 
Local cEndereco     := "EXPEDICAO"
Local lRet          := .t.
Private lMsErroAuto	:= .F.
Private cAliasHC     :=  GetNextAlias()

DbSelectArea((cAliasF2))
(cAliasF2)->(DbGoTop())
       
If !BuscaDad()

        While !(cAliasHC)->(EOF())

            DbSelectArea("SBE") //BE_FILIAL, BE_LOCAL, BE_LOCALIZ, BE_ESTFIS, R_E_C_N_O_, D_E_L_E_T_
            SBE->(DbSetOrder(1))
            SBE->(DbGoTop())
            If SBE->(DbSeek((cAliasHC)->DA_FILIAL + (cAliasHC)->DA_LOCAL + cEndereco))
                aCab := {}
                AAdd( aCab, {"DA_PRODUTO", (cAliasHC)->DA_PRODUTO	, nil} )
                AAdd( aCab, {"DA_NUMSEQ" , (cAliasHC)->DA_NUMSEQ	, nil} )

                aItens := {}
                AAdd( aItens, {"DB_ITEM"   , "0001"						    , nil} )
                AAdd( aItens, {"DB_ESTORNO", " "							, nil} )
                AAdd( aItens, {"DB_LOCALIZ", Padr(cEndereco, 15)			, nil} )
                AAdd( aItens, {"DB_QUANT"  , (cAliasHC)->DA_SALDO			, nil} )
                AAdd( aItens, {"DB_NUMSERI", Space(TamSx3("DB_NUMSERI")[01]), nil} )
                AAdd( aItens, {"DB_DATA"   , Date()							, nil} )

                lMsErroAuto	:= .F.

                MsExecAuto( {|x, y, z| mata265(x, y, z)}, aCab, {aItens}, 3 )

                If lMsErroAuto
                    mostraerro()
                    lRet := .f.
                Endif
            
            EndIf

            (cAliasHC)->(DbSkip())
        EndDo 
    
    Else
        MsgAlert("Não existem enderecos para enderecar!")
         lRet := .f.
EndIf

(cAliasHC)->(DbCloseArea())

RestArea(aArea)    
Return(lRet)

Static Function BuscaDad()
Local cQry := ""

BeginSql Alias cAliasHC

    SELECT *
    FROM SDA040 SDA (NOLOCK)
    LEFT JOIN SDB040 SDB (NOLOCK) ON SDB.DB_FILIAL = SDA.DA_FILIAL AND SDA.DA_PRODUTO = SDB.DB_PRODUTO AND SDA.DA_DOC = SDB.DB_DOC AND SDA.DA_ORIGEM = SDB.DB_ORIGEM AND SDA.DA_DATA = SDB.DB_DATA  AND SDB.D_E_L_E_T_ = ''
    WHERE SDA.D_E_L_E_T_ = ''
    AND DA_FILIAL = '08'
    AND DA_DOC = %EXP:(cAliasF2)->F2_DOC% 
    AND DA_DATA =  %EXP:(cAliasF2)->F2_EMISSAO% 
    AND DA_ORIGEM = 'SD1'
    AND DA_QTDORI = DA_SALDO

endsql

DbSelectArea((cAliasHC))
(cAliasHC)->(DbGoTop())

Return((cAliasHC)->(EOF()))
*/
