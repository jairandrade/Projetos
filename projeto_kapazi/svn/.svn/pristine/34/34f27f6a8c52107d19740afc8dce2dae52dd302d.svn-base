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
//	Programa: TRFNFEKI 	|	Autor: Luis Paulo									|	Data: 04/03/2021//
//==================================================================================================//
//	Descrição: Funcao para criar NF da 0401 para 0408 - Transf 0401 -> 0408                         //
//																									//
//==================================================================================================//
User Function TRFNFEKI(nRegPV,nRegNF)
Local aArea     := GetArea()
Local lRet      := .f.
Private _nRegNF := 0

If CriaNFEN(nRegPV)
    nRegNF := _nRegNF

	Sleep(1000)
	
    aRetEnv := U_EnvNfESF(SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE,SF2->F2_LOJA) 

	If !aRetEnv[1]  
        Conout("")
		Conout(aRetEnv[2])
        Conout("")
	EndIf 
    
    lRet  := .t. 

EndIf 

RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} nomeStaticFunction
    Cria a NF de saida na 0401
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
Static Function CriaNFEN(nRegPV)
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
                SF2->F2_XIDTRFP := cXIdTrf
                SF2->(MsUnlock())

                lRet := .t.
                _nRegNF :=  SF2->(RECNO())

                Conout("NFe de transferencia gerada com sucesso!!! NF: "+cNumNFe + " -- Serie: " + Alltrim(SF2->F2_SERIE) + " -- ID: "+cXIdTrf)
            Else
                Conout("O pedido de venda de TRANSFERENCIA possui itens que nao foram liberados!!! ->"+ SC5->C5_NUM + "ID: "+cXIdTrf)
        EndIf
        
    Else
        conout("O pedido de venda de serviço possui itens que nao foram liberados!!! -> "+ SC5->C5_NUM + " -- ID: "+cXIdTrf)
EndIf
Conout("")

RestArea(aArea)
Return(lRet)

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
User Function EnvNfESF(cSerie, cNota, cCliente, cLoja)
Local cRetorno		:= ""	//mensagem de retorno
Local cIDEnt		:= ""
Local cAmbiente		:= ""
Local cModalidade	:= ""
Local cVersao		:= ""
Local lRetorno		:= .F.
Local lEnd			:= .F.
Local aRet 			:= {} 	//Retorno da funcao
Local aArea			:= GetArea()
Local aSF2Area		:= SF2->( GetArea() )
Local  cError		:= ""
Local lErro 		:= .f.
Local cMv01         := MV_PAR01
Local cMv02         := MV_PAR02
Local cMv03         := MV_PAR03
Default cSerie		:= ""
Default cNota		:= ""
Default cCliente	:= ""
Default cLoja		:= ""

Private bFiltraBrw	:= {||}	//usado por compatibilidade por causa do fonte SPEDNFE.PRX

MV_PAR01 := cSerie
MV_PAR02 := cNota
MV_PAR03 := cNota

//---------------------------
// Obtem o codigo da entidade
//---------------------------
cIDEnt := GetIdEnt() //LjTSSIDEnt("55") // //
If !Empty(cIDEnt)

			//------------------------------------
			// Obtem os parametros do servidor TSS
			//------------------------------------		
			//carregamos o array estatico com os parametros do TSS
			cAmbiente	:= getCfgAmbiente(@cError, cIdEnt, "55") //LjCfgTSS("55", "AMB")[2]
			lErro := !Empty(cError)

			If !lErro
					cModalidade := "1"//ColGetPar( "MV_MODALID", "1" )	//getCfgModalidade(@cError, cIdEnt, "55") //LjCfgTSS("55", "MOD")[2]
					lErro := !Empty(cError)
				Else
					lRetorno := .f.
					cRetorno := cError
			EndIf

			If !lErro
					cVersao		:= getCfgVersao(@cError, cIdEnt, "55" ) //LjCfgTSS("55", "VER")[2]
					lErro := !Empty(cError)
				Else
					lRetorno := .T.
					cRetorno := cError
			EndIf

			If !lErro
					//------------------------------
					// Realiza a transmissão da NF-e
					//------------------------------
					conout( "[IDENT: " + cIDEnt+"] - Iniciando transmissao NF-e de saida! - " + Time() )

					cRetorno := SpedNFeTrf(	"SF2"	, cSerie	, cNota			, cNota		,;
											cIDEnt	, cAmbiente	, cModalidade	, cVersao	,;
											@lEnd	, .F.		, .F.						)

					lRetorno := .T.

					conout( "[IDENT: " + cIDEnt+"] - Transmissao da NF-e de saida finalizada! - " + Time() )

					/*
					3 ULTIMOS PARAMETROS:
						lEnd - parametro não utilizado no SPEDNFeTrf
						lCte
						lAuto
					*/
				
				Else
					lRetorno := .T.
					cRetorno := cError
			EndIf 
			
	Else
		cRetorno += "Não foi possível obter o Código da Entidade (IDENT) do servidor TSS." + CRLF
		cRetorno += "Por favor, realize a transmissão através do Módulo FATURAMENTO." + CRLF
EndIf

MV_PAR01 := cMv01
MV_PAR02 := cMv02   
MV_PAR03 := cMv03

//restaura as areas
RestArea(aSF2Area)
RestArea(aArea)

aRet := {lRetorno,cRetorno}
Return aRet


Static Function GetIdEnt(lUsaColab)
local cIdEnt := ""
local cError := ""

Default lUsaColab := .F.

If !lUsaColab

	cIdEnt := getCfgEntidade(@cError)

	if(empty(cIdEnt))
		Aviso("Kapazi", cError, {"ok"}, 3)

	endif

else
	if !( ColCheckUpd() )
		Aviso("Kapazi","UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0",{"ok"},3)
	else
		cIdEnt := "000000"
	endif
endIf

Return(cIdEnt)
