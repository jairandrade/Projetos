#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
//==================================================================================================//
//	Programa: JBTRFPRD		|	Autor: Luis Paulo							|	Data: 27/02/2021	//
//==================================================================================================//
//	Descrição: Funcao para transferencia entre filiais												//
//																									//
//	Alterações:																						//
//	-																								//
//==================================================================================================//
User Function JBTRFPRD(__cXID,aRetProd)
Local aArea 		:= GetArea() 
Local nRet			:= 1

Local aRetPV		:= {}
Local bError 		:= {||}

Local nRPV0401		:= 0
Local nRNF0401		:= 0
Local nRNF0408		:= 0

Local cEmpNew 		:= "04"
Local cFilNew		:= "01"
Local lConec		:= .T.
Private lRet		:= .f.
Private cMsgErro 	:= ""
Private cXIdTrf		:= __cXID
Private cCRLF		:= CRLF 


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

		aRetPV :=  u_TRFPVKIE(aRetProd,cXIdTrf)

		nRegPV := aRetPV[2]
		If nRegPV > 0 .And. aRetPV[1]
			
				Sleep(1000)
				
				If !u_TRFNFEKI(nRegPV,@nRegNF) 
						Conout("")
						MsgAlert("Erro no processo de gerar NF de transferencia entre filiais kapazi")
						Conout("Erro no processo de gerar NF de transferencia entre filiais kapazi")
						Conout("")
					Else
						Conout("")
						Conout("NF na 0401..."+SF2->F2_FILIAL +"/"+ SF2->F2_SERIE +"/"+ SF2->F2_DOC)
						Conout("")
						lRet := .t.
				EndIf

			Else 
				lRet := .f.

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
        MsgStop( alltrim(oError:Description), 'KAPAZI - Geração de notas fiscais CD - Erro' )    
    endif
    Break

return
