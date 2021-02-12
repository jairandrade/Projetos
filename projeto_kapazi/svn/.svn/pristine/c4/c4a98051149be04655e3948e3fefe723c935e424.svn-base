#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"
//==================================================================================================//
//	Programa: MT681INC		|	Autor: Luis Paulo						|	Data: 06/08/2020		//
//==================================================================================================//
//	Descrição: Após a gravação dos dados na rotina de inclusão do ap de produção PCP Mod2.          //
//																									//
//==================================================================================================//
User Function MT681INC()
Local aArea         := GetArea()
Local aAreaB1       := SB1->(GetArea())
Local aAreaBE       := SBE->(GetArea())
Local aCab          := {}
Local aItens 
Local cEndereco     := ""
Private lMsErroAuto	:= .F.
Private cAliasHC     :=  GetNextAlias()

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
SB1->(DbGoTop())
If SB1->(DbSeek(xFilial("SB1") + SH6->H6_PRODUTO))

    If SB1->B1_XENDAUT == "S" .And.  !Empty(SB1->B1_XENDERE)
        
        If !BuscaDad()

            cEndereco := SB1->B1_XENDERE
            
            DbSelectArea("SBE") //BE_FILIAL, BE_LOCAL, BE_LOCALIZ, BE_ESTFIS, R_E_C_N_O_, D_E_L_E_T_
            SBE->(DbSetOrder(1))
            SBE->(DbGoTop())
            If SBE->(DbSeek(SH6->H6_FILIAL + (cAliasHC)->DA_LOCAL + SB1->B1_XENDERE))
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

                If !lMsErroAuto
                    
                    Else
                        DisarmTransactions()
                        mostraerro()
                        lRet := .F.
                Endif
            
            EndIf

        EndIf

    EndIf

EndIf

GerSobras()


RestArea(aArea)
Return()


/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 24/09/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function GerSobras()
Local cQry      := ""
Local aArea     := GetArea()
Local cAliasZB  := GetNextAlias()
Local nQtdBs    := RetFldProd(SH6->H6_PRODUTO,"B1_QB")
Local nQtdPrd   := SH6->H6_QTDPROD
Local nPerc     := 0
Local cAliasE1	 :=  GetNextAlias()
Local oTempTable := NIL
Private nEstru   := 0
Default dDataEnt := dDataBase

//regra de 3 para descobrir o percentual do que foi apontado e assim temos a razao correta
nPerc := ((100 * nQtdPrd) / nQtdBs) / 100

Estrut2(SH6->H6_PRODUTO,SH6->H6_QTDPROD,(cAliasE1),@oTempTable,.T.)

(cAliasE1)->(dbGoTop())
While !(cAliasE1)->(EOF())
	
    /*
    AADD(aCampos,{"NIVEL","C",6,0})
	AADD(aCampos,{"CODIGO","C",aTamSX3[1],0})
	AADD(aCampos,{"COMP","C",aTamSX3[1],0})
	AADD(aCampos,{"QUANT","N",Max(aTamSX3[1],18),aTamSX3[2]})
	AADD(aCampos,{"TRT","C",aTamSX3[1],0})
	AADD(aCampos,{"GROPC","C",aTamSX3[1],0})
	AADD(aCampos,{"OPC","C",aTamSX3[1],0})
	AADD(aCampos,{"REGISTRO","N",14,0})
    */
    
    cQry := " SELECT *
    cQry += " FROM "+RetSqlName("SG1")+" SG1
    cQry += " LEFT JOIN "+RetSqlName("ZB2")+" ZB2 ON SG1.G1_COD = ZB2.ZB2_COD AND ZB2.ZB2_PROD = '"+Alltrim((cAliasE1)->COMP)+"' AND ZB2.D_E_L_E_T_ = '' AND ZB2.ZB2_QTDCNV > 0
    cQry += " WHERE SG1.D_E_L_E_T_ = ''
    cQry += " AND SG1.G1_COD = '"+SH6->H6_PRODUTO+"'
    cQry += " AND SG1.G1_FIM >= '"+DTOS(Date())+"'  
    cQry += " AND G1_PERDA > 0

    TcQuery cQry New Alias (cAliasZB)

    DbSelectArea((cAliasZB))
    (cAliasZB)->(DbGoTop())

    While !(cAliasZB)->(EOF())

        //nSobra := ( ((cAliasZB)->ZB2_QTDCNV * nPerc) * ((cAliasZB)->G1_PERDA/100) ) //Quantidade de convercao * percentual apontado * percentual de perda

        nSobra := ( ((cAliasZB)->ZB2_QTDCNV * nPerc) )

        CriaMvInt((cAliasZB)->ZB2_PRDGER,nSobra)

        (cAliasZB)->(DbSkip())   
    EndDo

    (cAliasZB)->(DbCloseArea())
     
    (cAliasE1)->(dbSkip())
EndDo

oTempTable:Delete()

RestArea(aArea)
Return()


/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 25/09/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function CriaMvInt(cProdGer,nSobra)
Local cFilAtu           := xFilial("SD3")
Local cTmMv             := Alltrim( SuperGetMV("KP_XTMSBRS"	,.F. ,"001")) 
Local cUM               := POSICIONE("SB1", 1, xFilial("SB1") + cProdGer, "B1_UM")
Local cAmzSbr           := Alltrim( SuperGetMV("KP_XAMZBRS"	,.F. ,"02"))
Local dEmis             := dDataBase
Local cDoc	            := GetSxENum("SD3","D3_DOC",1)
Local aItem             := {}
Local nOpc              := 3
Private lAutoErrNoFile  := .T.
Private lMsErroAuto     := .F.
 
ConOut(Repl("-",80))
ConOut(PadC("Teste de Movimentacoes Internas",80))
ConOut("Inicio: "+Time())

aadd(aItem,{"D3_FILIAL"     ,cFilAtu    ,NIL})
aadd(aItem,{"D3_TM"         ,cTmMv      ,NIL})
aadd(aItem,{"D3_COD"        ,cProdGer   ,NIL})
aadd(aItem,{"D3_UM"         ,cUM        ,NIL})
aadd(aItem,{"D3_QUANT"      ,nSobra     ,NIL})
aadd(aItem,{"D3_LOCAL"      ,cAmzSbr    ,NIL}) //02 PROCESSO
aadd(aItem,{"D3_CONTA"      ,""         ,NIL})
aadd(aItem,{"D3_DOC"        ,cDoc       ,NIL})
aadd(aItem,{"D3_EMISSAO"    ,dEmis      ,NIL})
//aadd(aItem,{"D3_NUMSEQ"     ,"000017"   ,NIL})
aadd(aItem,{"D3_LOCALIZ"    ,"PROCESSO       " ,NIL})
//aadd(aItem,{"D3_LOTECTL "   ,"1012 "    ,NIL})
//aadd(aItem,{"D3_DTVALID "   ,dDatav     ,NIL})

MSExecAuto({|x,y| mata240(x,y)},aItem,nOpc)
if lMsErroAuto
    mostraerro()
endIf

Return()


Static Function BuscaDad()
Local cQry := ""

cQry += " SELECT *
cQry += " FROM SDA040 SDA
cQry += " LEFT JOIN SDB040 SDB ON SDB.DB_FILIAL = SDA.DA_FILIAL AND SDA.DA_PRODUTO = SDB.DB_PRODUTO AND SDA.DA_DOC = SDB.DB_DOC AND SDA.DA_ORIGEM = SDB.DB_ORIGEM AND SDA.DA_DATA = SDB.DB_DATA  AND SDB.D_E_L_E_T_ = ''
cQry += " WHERE SDA.D_E_L_E_T_ = ''
cQry += " AND DA_FILIAL = '"+SH6->H6_FILIAL+"'
cQry += " AND DA_DOC = '"+Substr(SH6->H6_OP,1,6)+"'
cQry += " AND DA_PRODUTO = '"+SH6->H6_PRODUTO+"'
cQry += " AND DA_QTDORI = "+ Str(SH6->H6_QTDPROD,12,4)+""
cQry += " AND DA_DATA = '"+DTOS(SH6->H6_DTAPONT)+"'
cQry += " AND DA_ORIGEM = 'SD3'
//cQry += " AND DA_NUMSEQ = '"+SH6->H6_IDENT+"'"
cQry += " AND DA_QTDORI = DA_SALDO "

//597899
TcQuery cQry New Alias (cAliasHC)

DbSelectArea((cAliasHC))
(cAliasHC)->(DbGoTop())

Return((cAliasHC)->(EOF()))

