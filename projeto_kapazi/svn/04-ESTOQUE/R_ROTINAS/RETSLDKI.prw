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
//	Programa: RETSLDKI 	|	Autor: Luis Paulo									|	Data: 04/03/2021//
//==================================================================================================//
//	Descrição: Rotina para retorno dos saldo para 0401(KI).					                        //
//																									//
//==================================================================================================//
User Function RETSLDKI(__cFilNF,__cSerie,__cNota,__cFornec,__cLoja)
Local aArea         := GetArea()

Local nRegPv        := 0
Local nRegNF	    := 0
Local nRegNFEn      := 0

Local lErro         := .f.

Local aLastQuery    := ""
Local cLastQuery    := {}

Private  cAliasF1	:= ""
Private cXIDTRFCD   := ""
Private cCRLF       := CRLF
Private cLog        := ""

Private lIncPV      := .f.

Default __cFilNF    := "" 
Default __cSerie    := "" 
Default __cNota     := "" 
Default __cFornec   := "" 
Default __cLoja     := "" 

cAliasF1	:= GetNextAlias()

BeginSql Alias cAliasF1

SELECT F1_TIPO,D1_ITEM,SF1.R_E_C_N_O_ RECOSF1,*
FROM %TABLE:SF1% SF1 (NOLOCK)
LEFT JOIN %TABLE:SD1% SD1 (NOLOCK) ON SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SD1.D_E_L_E_T_ = ''
WHERE SF1.D_E_L_E_T_ = ''
AND SF1.F1_FILIAL = '08'
AND SF1.F1_TIPO = 'D'
AND SF1.F1_STATUS = 'A'
AND SF1.F1_EMISSAO >= '20210201'
AND SF1.F1_DOC = %EXP:__cNota%
AND SF1.F1_SERIE = %EXP:__cSerie%
AND SF1.F1_FORNECE = %EXP:__cFornec%
AND SF1.F1_LOJA = %EXP:__cLoja%

EndSql

aLastQuery    := GetLastQuery()
cLastQuery    := aLastQuery[2]

DbSelectArea((cAliasF1))
(cAliasF1)->(DbGoTop())

If !(cAliasF1)->(EOF())
    cXIDTRFCD 	:= GetSx8Num("ZLG","ZLG_ID") 
    ConfirmSx8()
    
    If U_EndNFEnt(__cFilNF,__cSerie,__cNota,__cFornec,__cLoja)
            
            If CriPVRet(cXIDTRFCD,@nRegPv) 
                
                    If U_LibGerPv(nRegPv) 
                        
                        If U_LibCrEPv(nRegPv) 

                            If MATA455(nRegPv)
                                
                                    If U_GerNFR08(nRegPV,@nRegNF,cXIDTRFCD) 

                                        If u_TranNF08() 

                                                If !U_NFEntRKI(cXIDTRFCD,@nRegNFEn) 
                                                        MsgInfo("Transferencia de NF de retorno não incluida, informe o TI","KAPAZI")
                                                        lErro := .t.            
                                                    Else
                                                        Gravalog(cXIDTRFCD,nRegPV,nRegNF,nRegNFEn,__cNota) 
                                                        MsgInfo("Transferencia de NF de retorno concluída!!!","KAPAZI")
                                                EndIf
                                            
                                            EndIf

                                        Else
                                            MsgAlert("Não foi possível gerar a NF de saída com os produtos informados na NF, efetue a transferencia de forma manual")
                                            lErro := .t.
                                    EndIf 

                                Else 
                                    MsgAlert("Não foi possível liberar estoque do PV de saída com os produtos informados na NF, efetue a transferencia de forma manual")
                                    lErro := .t.
                            EndIf

                        EndIf

                    EndIf
                
                Else 
                    MsgAlert("Não foi possível criar o PV de saída com os produtos informados na NF, efetue a transferencia de forma manual")
                    lErro := .t.
            EndIf
        
        Else 
            MsgAlert("Não foi possível endereçar automaticamente os produtos informados na NF, efetue a transferencia de forma manual")
            lErro := .t.
    EndIf 

EndIf

If lErro
    If nRegNF > 0
        u_ExcNFSTF("08",nRegNF)
    EndIf

    If nRegPv > 0
        u_ExcPVSTF("08",nRegPv)
    EndIf

    If nRegNFEn > 0
        u_ExcNFETF("01",nRegNFEn)
    EndIf

EndIf

RestArea(aArea)
Return()


/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 21/02/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MATA455(nRegPv)
// variaveis auxiliares
Local aArea     := GetArea()
Local lEnd      := .F.
Local cPerg     :="LIBAT2"
Local lRet      := .F.
Local cAlias    :="SC9"  
Local cNumPed   := ""

DbSelectArea("SC5")
SC5->(dbGoTop())
SC5->(dbGoTo(nRegPv))

cNumPed := SC5->C5_NUM


//inicializa as variaveis
cMsgErro :=""
DbSelectArea("SC9")
SC9->(DbSetOrder(1))

//preenche os parametros de liberação
Pergunte(cPerg, .F.)
mv_par01 := cNumPed
mv_par02 := cNumPed
mv_par03 := Space(6)
mv_par04 := Replicate("Z", 6)
mv_par05 := Stod("")
mv_par06 := Stod("20491231")
mv_par07 = 1

//chama a rotina para liberar o estoque
Processa({|lEnd| Ma450Processa(cAlias, .F., .T., @lEnd, Nil, MV_PAR07 == 2)}, Nil, Nil, .T.)
                    
//restaura a area
RestArea(aArea)

//valida se o pedido foi totalmente liberado
if IsPedLib(cNumPed)
    // procedimento concluido
    lRet := .T.

else
    // procedimento concluido
    lRet := .F.
    cMsgErro :="Produtos sem saldos no pedido de produto, informe o setor responsável pela liberação de estoque!"  //Alterado por Marcellus mensagem retorno 01/04/2016
    Conout(cMsgErro)
endIf
 
Return(lRet)



//-------------------------------------------------
/*/{Protheus.doc} IsPedLib
retorna se o pedido foi liberado estoque 

@type function
@version 1.0
@author Desconhecido

@since 21/07/2016

@param cNumPed, character, Número do Pedido de Vendas

@return Logical, True or False

@protected
/*/  
//-------------------------------------------------   
static function IsPedLib(cNumPed)

// variaveis auxiliares
local cAliasEs  := getNextAlias()
local lRet      := .t.

BeginSql Alias cAliasEs
    SELECT 
        COUNT(*) AS C9_TOTAL, C9_PRODUTO
    FROM
        %TABLE:SC9% SC9
    WHERE 
        C9_FILIAL = '08'
        AND SC9.C9_PEDIDO = %EXP:cNumPed%
        AND SC9.C9_BLEST <> ''
        AND %NOTDEL%
    GROUP BY 
        C9_PRODUTO
endsql

while !(cAliasEs)->(EOF()) .And. lRet
    lRet := ((cAliasEs)->C9_TOTAL == 0)

    (cAliasEs)->(dbSkip())
enddo

(cAliasEs)->(dbCloseArea())

return lRet

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 04/03/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function CriPVRet(cXIDTRFCD,nRegPv)
Local aArea := GetArea()
Local   lRet        := .f.
Local 	aCabec 		:= {}
Local	aItens 		:= {}
Local 	aLinha 		:= {}
Local 	cOP			:= Alltrim( SuperGetMV("KP_OPPVTRF"	,.F. ,"06")) //TRANSFERENCIA
Local 	nCount		:= 0
Local cConFor       := Alltrim( SuperGetMV("KP_FCONTRF"	,.F. ,"001"))
Local nValProd      := 0

Private cCliCD08	:=  Alltrim( SuperGetMV("KP_CLICD08"	,.F. ,"007484"))
Private cCliLJ08	:=  Alltrim( SuperGetMV("KP_CLILJ08"	,.F. ,"20"))

Private lMsErroAuto	:= .F.

DbSelectArea("SC5")

aadd(aCabec,{"C5_TIPO" 		,"N"			                            ,Nil})
aadd(aCabec,{"C5_CLIENTE"	,Padr(cCliCD08  , TamSx3("C5_CLIENTE")[01]) ,Nil})
aadd(aCabec,{"C5_LOJACLI"	,Padr(cCliLJ08  , TamSx3("C5_LOJACLI")[01]) ,Nil})
aadd(aCabec,{"C5_LOJAENT"	,Padr(cCliLJ08  , TamSx3("C5_LOJAENT")[01]) ,Nil})
aadd(aCabec,{"C5_CONDPAG"	,Padr(cConFor   , TamSx3("C5_CONDPAG")[01]) ,Nil})
aadd(aCabec,{"C5_TPFRETE"	,Padr("S"       , TamSx3("C5_TPFRETE")[01]) ,Nil})
aadd(aCabec,{"C5_K_TPCL"	,Padr("000055"  , TamSx3("C5_K_TPCL")[01])  ,Nil})
aadd(aCabec,{"C5_TIPOCLI"	,Padr("R"       , TamSx3("C5_TIPOCLI")[01]) ,Nil})
aadd(aCabec,{"C5_VEND1"		,Padr("000147"  , TamSx3("C5_VEND1")[01])   ,Nil})
aadd(aCabec,{"C5_USER"		,Padr("Sistema" , TamSx3("C5_USER")[01])    ,Nil})
aadd(aCabec,{"C5_K_OPER"	,Padr(cOP       , TamSx3("C5_K_OPER")[01])  ,Nil})
aadd(aCabec,{"C5_XSITLIB"	,Padr("6"       , TamSx3("C5_XSITLIB")[01]) ,Nil})
aadd(aCabec,{"C5_XGERASV"	,Padr("N"       , TamSx3("C5_XGERASV")[01]) ,Nil})
aAdd(aCabec,{'C5_XTPPED' 	,Padr("014"     , TamSx3("C5_XTPPED")[01])  , Nil})
aAdd(aCabec,{'C5_INDPRES' 	,Padr("0"       , TamSx3("C5_INDPRES")[01])  , Nil})
aAdd(aCabec,{'C5_XIDTRFP' 	,Padr(cXIDTRFCD , TamSx3("C5_XIDTRFP")[01])  , Nil})

aCabec := FWVetByDic(aCabec,'SC5',.f.,1)

While !(cAliasF1)->(Eof())
    
    nValProd := u_RetVlrCm((cAliasF1)->D1_COD)

    If nValProd == 0
        MsgStop("O produto "+(cAliasF1)->D1_COD+" nao possui seu custa na tabela T01, favor verificar!!","Kapazi")
        return .f.
    EndIf 

    DbSelectArea("SB1")
    SB1->(dbSetOrder(1))
    SB1->(dbGoTop())
    If SB1->(DbSeek(xFilial("SB1")+(cAliasF1)->D1_COD))

        nCount++
        aLinha := {}
        aadd(aLinha,{"C6_ITEM"	 , StrZero(nCount,2)               , Nil})
        aadd(aLinha,{"C6_PRODUTO", (cAliasF1)->D1_COD	           , Nil})		
        
        aadd(aLinha,{"C6_QTDVEN" , (cAliasF1)->D1_QUANT            , Nil})

        // se usa m2
        If Alltrim((cAliasF1)->D1_UM) == "M2"
            aAdd( aLinha , { "C6_XLARG"  	, 1			            , NIL } ) //Adicionado Posteriormente
            aAdd( aLinha , { "C6_XCOMPRI"  	, 1		                , NIL } ) //Adicionado Posteriormente
            aAdd( aLinha , { "C6_XQTDPC"  	, (cAliasF1)->D1_QUANT	, NIL } ) //Adicionado Posteriormente
        EndIf

        aadd(aLinha,{"C6_OPER"	 , cOP			                   , Nil})
        aadd(aLinha,{"C6_PRCVEN" , nValProd            , Nil}) //(cAliasF1)->D1_VUNIT
        aadd(aLinha,{"C6_PRUNIT" , nValProd            , Nil})
        aadd(aLinha,{"C6_LOCAL" , "04"                  , Nil})
        
        aadd(aLinha,{"C6_CC"    , SB1->B1_XCCTRF        , Nil})
        
        aadd(aItens,aLinha)

    EndIf 
    
    (cAliasF1)->(DbSKip())
EndDo

DbSelectArea("SFM")
SFM->(dbSetOrder(1))

Conout("")

BeginTran()
    MATA410(aCabec,aItens,3)
    If lMsErroAuto
            lIncPV	:= .F.
            MostraErro()

        Else 
            Reclock("SC5",.F.)
            SC5->C5_XIDTRFP := cXIDTRFCD
            SC5->(MsUnlock())
            
            lIncPV  := .T.
            nRegPv := SC5->(RECNO())

            Conout("Pedido de venda de transferencia gerado com sucesso!!!! >>> " + SC5->C5_NUM )
    EndIf
EndTran()

Conout("")

RestArea(aArea)
Return(lIncPV)

/*/{Protheus.doc} nomeStaticFunction
    Função para gerar NF
    @author Luis
    @since 04/03/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/   
User Function GerNFR08(nRegPV,nRegNF,cXIDTRFCD)
Local aPvlNfs		:= {}
Local cSerie		:= '2'
Local lMostraCtb	:= .F.
Local lAglutCtb		:= .F.
Local lCtbOnLine	:= .F.
Local lCtbCusto		:= .F.
Local lReajuste		:= .F.
Local nCalAcrs		:= 1
Local nArredPrcLis	:= 1
Local lAtuSA7		:= .F.
Local lECF			:= .F.
Local cEmbExp		:= nil
Local bAtuFin		:= {|| .T.}
Local bAtuPGerNF	:= {||}
Local bAtuPvl		:= {||}
Local bFatSE1		:= {|| .T. }
Local dDataMoe		:= dDatabase

Local aBloqueio		:= {}
Local aParam460		:= Array(30)
Local aArea 		:= GetArea()
Local lPedSpp		:= .F.

Local cNumNFe       := "" 
Local lRet          := .f.

/*
Parametros³ExpA1: Array com os itens a serem gerados                   
          ³ExpC2: Serie da Nota Fiscal                                 
          ³ExpL3: Mostra Lct.Contabil                                  
          ³ExpL4: Aglutina Lct.Contabil                                
          ³ExpL5: Contabiliza On-Line                                  
          ³ExpL6: Contabiliza Custo On-Line                            
          ³ExpL7: Reajuste de preco na nota fiscal                     
          ³ExpN8: Tipo de Acrescimo Financeiro                         
          ³ExpN9: Tipo de Arredondamento                               
          ³ExpLA: Atualiza Amarracao Cliente x Produto                 
          ³ExplB: Cupom Fiscal                                         
          ³ExpCC: Numero do Embarque de Exportacao                     
          ³ExpBD: Code block para complemento de atualizacao dos titulos financeiros.                                     
          ³ExpBE: Code block para complemento de atualizacao dos dados apos a geracao da nota fiscal.                       
          ³ExpBF: Code Block de atualizacao do pedido de venda antes da geracao da nota fiscal                            
*/
//Posiciona no pedido para liberação
DbSelectArea("SC5")
SC5->(DbGoTop())
SC5->(DbGoTo(nRegPV))

		
// Liberacao de pedido
Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
// Checa itens liberados
Ma410LbNfs(1,@aPvlNfs,@aBloqueio)

Conout("")		
// Caso tenha itens liberados manda faturar
If Empty(aBloqueio) .And. !Empty(aPvlNfs)
        cNumNFe := MaPvlNfs(aPvlNfs,cSerie,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajuste,nCalAcrs,nArredPrcLis,lAtuSA7,lECF,cEmbExp,bAtuFin,bAtuPGerNF,bAtuPvl,bFatSE1,dDataMoe)
        
        If !Empty(cNumNFe)
                Reclock("SF2",.F.)
                SF2->F2_XIDTRFP := cXIDTRFCD
                SF2->(MsUnlock())

                nRegNF :=  SF2->(RECNO())

                lRet := .t.

                Conout("NFe de transferencia gerada com sucesso!!! NF: "+cNumNFe + " -- Serie: " + Alltrim(SF2->F2_SERIE) + " -- ID: "+cXIDTRFCD)
            Else
                Conout("O pedido de venda de TRANSFERENCIA possui itens que nao foram liberados!!! ->"+ SC5->C5_NUM + "ID: "+cXIDTRFCD)
        EndIf
        
    Else
        conout("O pedido de venda de serviço possui itens que nao foram liberados!!! -> "+ SC5->C5_NUM + " -- ID: "+cXIDTRFCD)
EndIf
Conout("")

RestArea(aArea)
Return(lRet)



/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 04/03/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TranNF08()
Local lRet      := .T. 
Local aRetEnv   := {}

aRetEnv := U_EnvNfESF(SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE,SF2->F2_LOJA) //Envia a NF para o sefaz

If !aRetEnv[1]  
    Conout("")
    Conout(aRetEnv[2])
    Conout("")
    lRet  := .F. 
EndIf 

       
Return(lRet)


/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 04/03/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function NFEntRKI(cXIDTRFCD,nRegNFEn)
Local aArea 		:= GetArea() 
Local nRet			:= 1

Local nRegPV		:= 0
Local nRegNF		:= 0
Local aRetPV		:= {}
Local bError 		:= {||}

Local nRPV0401		:= 0
Local nRNF0401		:= 0
Local nRNF0408		:= 0

Local cEmpNew 		:= "04"
Local cFilNew		:= "01"
Local lConec        := .t.
Private lRet		:= .f.
Private cMsgErro 	:= ""
Private cXIdTrf		:= cXIDTRFCD
Private cCRLF		:= CRLF 
Private __nRegNE    := 0


cFilant		:= 	"01"			
DbSelectArea("SM0")
SM0->(DbGoTop())
SM0->(DbSeek( "04" + "01" ) )

Conout("")
ConOut(SM0->M0_CODIGO+" - "+SM0->M0_CODFIL)
Conout("")

If lConec
    bError := ErrorBlock( { |oError| TrataErro( oError ) } )
		Begin SEQUENCE

        If !CriaNfEnt(cXIdTrf)
                //estorna todos os processos
            Else 
                lRet := .t.
                
                nRegNFEn := __nRegNE

                Conout("NF Entrada na 0401..."+SF1->F1_FILIAL +"/"+ SF1->F1_SERIE +"/"+ SF1->F1_DOC)
        EndIf 

	    End SEQUENCE
		ErrorBlock( bError )

	Else
		Conout("")
		Conout("Nao foi possivel conectar o usuario na 0401 para fazer a transferencia")
		Conout("")
EndIf 

cFilant		:= 	"08"			
DbSelectArea("SM0")
SM0->(DbGoTop())
SM0->(DbSeek( "04" + "08" ) )

Conout("")
ConOut(SM0->M0_CODIGO+" - "+SM0->M0_CODFIL)
Conout("")
	
Return(lRet)


/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 04/03/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function CriaNfEnt(cXIdTrf)
Local aArea         := GetArea()

Local cFornec       := Alltrim( SuperGetMV("KP_FORCD08"	,.F. ,"338616"))
Local cLojFor       := Alltrim( SuperGetMV("KP_FORLJ08"	,.F. ,"09"))

Local cConFor       := Alltrim( SuperGetMV("KP_FCONTRF"	,.F. ,"001"))
Local 	cOP			:= Alltrim( SuperGetMV("KP_OPPVTRF"	,.F. ,"06")) //TRANSFERENCIA
Local cTESF4        := ""
Local aLastQuery    := {}
Local cLastQuery    := ""
Local aCabec        := {}
Local aLinha        := {}
Local aItens        := {}
Local lRet          := .f.
Local _cAmz         := ""
local _cEndere      := ""

Private lMsErroAuto := .f.
Private cAliasF2    := GetNextAlias()

BeginSql Alias cAliasF2
    SELECT *
    FROM %TABLE:SF2% SF2
    INNER JOIN %TABLE:SD2% SD2 ON SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_DOC = SD2.D2_DOC AND SD2.%NOTDEL%
    WHERE SF2.F2_XIDTRFP = %EXP:cXIdTrf%
        AND SF2.F2_FILIAL = '08'
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
aadd(aCabec,{"F1_XIDTRFP"	,cXIdTrf                })

nItem := 1

If IsInCallStack("u_RETSLDKI")  .And. cFilAnt == "01"
        _cAmz      := "NC"
        _cEndere   := "NCC"

    Else //é uma devolucao
        _cAmz      := "04"
        _cEndere   := "EXPEDICAO"    
EndIf

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
    If SB2->(DbSeek( xFilial("SB2") + (cAliasF2)->D2_COD + _cAmz)) //Busca qqr residuo de saldo que possa haver na origem
        CriaSB2((cAliasF2)->D2_COD,_cAmz)
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
        aadd(aLinha,{"D1_LOCAL"	,_cAmz                  ,Nil})
        aadd(aLinha,{"D1_CC"	, SB1->B1_XCCTRF        ,Nil})         //VERIFICAR
        
        aadd(aLinha,{"D1_OPER",cOP                      ,Nil})
        aadd(aLinha,{"D1_TES",cTESF4                    ,Nil})
        
        aadd(aItens,aLinha)
        
        nItem++
    
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
            __nRegNE := SF1->(RECNO())
            
            Reclock("SF1",.F.)
            SF1->F1_XIDTRFP := cXIdTrf
            SF1->(MsUnlock())
            
            If U_EndNFEnt(SF1->F1_FILIAL,SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_FORNECE,SF1->F1_LOJA)
                lRet := .t.
            EndIf 
    EndIf

EndIf

(cAliasF2)->(DbCloseArea())

RestArea(aArea)
Return(lRet)

/*
Static Function EnderTrf()
Local aArea         := GetArea()
Local aAreaB1       := SB1->(GetArea())
Local aAreaBE       := SBE->(GetArea())
Local aCab          := {}
Local aItens        := {}
Local lRet          := .t.
Private lMsErroAuto	:= .F.
Private cAliasHC    :=  GetNextAlias()

DbSelectArea((cAliasF2))
(cAliasF2)->(DbGoTop())

If !BuscaDad()

        While !(cAliasHC)->(EOF())
        
            DbSelectArea("SBE") //BE_FILIAL, BE_LOCAL, BE_LOCALIZ, BE_ESTFIS, R_E_C_N_O_, D_E_L_E_T_
            SBE->(DbSetOrder(1))
            SBE->(DbGoTop())
            If SBE->(DbSeek((cAliasHC)->DA_FILIAL + _cAmz + _cEndere))
                aCab := {}
                AAdd( aCab, {"DA_PRODUTO", (cAliasHC)->DA_PRODUTO	, nil} )
                AAdd( aCab, {"DA_NUMSEQ" , (cAliasHC)->DA_NUMSEQ	, nil} )

                aItens := {}
                AAdd( aItens, {"DB_ITEM"   , "0001"						    , nil} )
                AAdd( aItens, {"DB_ESTORNO", " "							, nil} )
                AAdd( aItens, {"DB_LOCALIZ", Padr(_cEndere, 15)			, nil} )
                AAdd( aItens, {"DB_QUANT"  , (cAliasHC)->DA_SALDO			, nil} )
                AAdd( aItens, {"DB_NUMSERI", Space(TamSx3("DB_NUMSERI")[01]), nil} )
                AAdd( aItens, {"DB_DATA"   , Date()							, nil} )

                lMsErroAuto	:= .F.

                MsExecAuto( {|x, y, z| mata265(x, y, z)}, aCab, {aItens}, 3 )

                If lMsErroAuto
                        mostraerro()
                        lRet := .f.
                    Else 
                        lRet := .t.
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
Local cQry          := ""
Local aLastQuery    := ""
Local cLastQuery    := {}

BeginSql Alias cAliasHC

    SELECT *
    FROM SDA040 SDA
    LEFT JOIN SDB040 SDB ON SDB.DB_FILIAL = SDA.DA_FILIAL AND SDA.DA_PRODUTO = SDB.DB_PRODUTO AND SDA.DA_DOC = SDB.DB_DOC AND SDA.DA_ORIGEM = SDB.DB_ORIGEM AND SDA.DA_DATA = SDB.DB_DATA  AND SDB.D_E_L_E_T_ = ''
    WHERE SDA.D_E_L_E_T_ = ''
    AND DA_FILIAL = '01'
    AND DA_DOC = %EXP:(cAliasF2)->F2_DOC% 
    AND DA_DATA =  %EXP:(cAliasF2)->F2_EMISSAO% 
    AND DA_ORIGEM = 'SD1'
    AND DA_QTDORI = DA_SALDO

endsql

aLastQuery    := GetLastQuery()
cLastQuery    := aLastQuery[2]

DbSelectArea((cAliasHC))
(cAliasHC)->(DbGoTop())

Return((cAliasHC)->(EOF()))
*/

//-------------------------------------------------
/*/{Protheus.doc} TrataErro
Rotina para tratamento de erros.

@type function
@version 1.0
@author Lucas José Corrêa Chagas

@since 21/12/2020

@param oError, object, Objeto com informações do erro.

@protected
/*/
//-------------------------------------------------
Static Function TrataErro( oError as Object )

    if InTransact() // se estiver em uma transação de banco, aborta a mesma
        DisarmTransaction()
        EndTran()
    endif

    if !isBlind()
        MsgStop( alltrim(oError:Description), 'KAPAZI - Geração de notas fiscais RETORNO CD - Erro' )    
    endif
    Break

return

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 27/02/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function Gravalog(cXIDTRFCD,nRegPV,nRegNF,nRegNFEn,__cNota)
Local aArea := GetArea()

DbSelectArea("ZLG")

Reclock("ZLG",.T.)
ZLG->ZLG_FILIAL	:= xFilial("ZLG")
ZLG->ZLG_ID		:= cXIDTRFCD
ZLG->ZLG_RETPVS := nRegPV
ZLG->ZLG_RETNFS := nRegNF
ZLG->ZLG_RETNFE := nRegNFEn
ZLG->ZLG_NFERET := __cNota
ZLG->(MsUnlock())

RestArea(aArea)
Return() 
