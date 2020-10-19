#include 'protheus.ch'
#include "TOTVSWebSrv.ch"                          
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} wsEst010Product
WebService para incluir e alterar pelo WebFormat.

@author  Rafael Ricardo Vieceli
@since   11/06/2015
/*/
WsService wsEst010Product Description "Atualização cadastro de Produtos via WebFormat"

	wsData Products  as wfProducts
	wsData Results   as Array of wfResult

	//Declaração de métodos
	wsMethod Update Description "Inclui e altera (se existe) produtos"

EndWsService


/*/{Protheus.doc} Update
Método que processar a Inclusao de Movimento de Transferencia.

@author  Rafael Ricardo Vieceli e Luan D Oliveira Moreira
@since   25/09/2014
@param Transferencia, Objeto, Dados XML para incluir movimento.
@return  	Retorno, Objeto, Retorna se conseguiu incluir o movimento e o erro, caso ocorra.
/*/
wsMethod Update wsReceive Products wsSend Results wsService wsEst010Product

	Local lOk := .T.
	Local nLinha
	Local aResult := {}     
	Local cXml		:= ""
	cXML += ' <?xml version="1.0" encoding="utf-8"?>'
	cXML += ' <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://200.195.158.106:83/UPDATE"> '
	cXML += ' <soapenv:Header/>'
	cXML += ' 	<soapenv:Header/>'
	cXML += ' 	<soapenv:Body>'
	cXML += ' 		<ns:UPDATE>'
	cXML += ' 			<ns:PRODUCTS>'
	cXML += '			<ns:CPASSWORD>'+Self:Products:cPassword+'</ns:CPASSWORD>'
	cXML += '			<ns:CUSER>'+Self:Products:cUser+'</ns:CUSER>'
	cXML += '			<ns:PRODUCTS>'
               
	//pesquisa o usuario pelo login
	PSWOrder(2)                         

	//faz o decode e faz a busca
	PSWSeek( Decode64( Self:Products:cUser ), .T.)
	//valida a senha, tambem fazendo o decode
	
	
	bBlock1	:= {|| Type("Self:Products:Products[nLinha]:B1_QE") == 'N'}
	bBlock2	:= {|| Type("Self:Products:Products[nLinha]:B1_EMIN") == 'N'}
	bBlock3	:= {|| Type("Self:Products:Products[nLinha]:B1_LE") == 'N'}
	bBlock4	:= {|| Type("Self:Products:Products[nLinha]:B1_EMAX") == 'N'}
			
	
	IF PSWName( Decode64( Self:Products:cPassword ) )
		//passa por todas as linhas enviadas
		For nLinha := 1 to len(Self:Products:Products)

			aResult := AtualizaProduto(Self:Products:Products[nLinha])

			cXML += '			<ns:WFPRODUCT>'
			cXML += '				<ns:OPERATION>'+Self:Products:Products[nLinha]:OPERATION+'</ns:OPERATION>'
			cXML += '				<ns:WFM_COD/>'
			cXML += '				<ns:B1_COD>'+Self:Products:Products[nLinha]:B1_COD+'</ns:B1_COD>'
			cXML += '				<ns:B1_DESC>'+Self:Products:Products[nLinha]:B1_DESC+'</ns:B1_DESC>'
			cXML += '				<ns:B1_DESC>'+Self:Products:Products[nLinha]:B1_TIPO+'<ns:B1_TIPO/>'
			cXML += '				<ns:B1_UM>'+Self:Products:Products[nLinha]:B1_UM+'</ns:B1_UM>'
			cXML += '				<ns:B1_GRUPO>'+Self:Products:Products[nLinha]:B1_GRUPO+'<ns:B1_GRUPO/>'
			cXML += '				<ns:B1_POSIPI>'+Self:Products:Products[nLinha]:B1_POSIPI+'</ns:B1_POSIPI>'
			cXML += '				<ns:B5_CEME>'+Self:Products:Products[nLinha]:B5_CEME+'</ns:B5_CEME>'
			cXML += '				<ns:B5_DCOMPR>'+Self:Products:Products[nLinha]:B5_DCOMPR+'</ns:B5_DCOMPR>'
			cXML += '				<ns:B1_CC>'+Self:Products:Products[nLinha]:B1_CC+'</ns:B1_CC>'
			cXML += '				<ns:B1_ZITEMZ>'+Self:Products:Products[nLinha]:B1_ZITEMZ+'</ns:B1_ZITEMZ>'
			If Eval(bBlock1)
				cXML += '				<ns:B1_QE>'+Alltrim(Str(Self:Products:Products[nLinha]:B1_QE))+'</ns:B1_QE>'
			Else
				cXML += '				<ns:B1_QE>0</ns:B1_QE>'			
			EndIf

			If Eval(bBlock2)
				cXML += '				<ns:B1_EMIN>'+Alltrim(Str(Self:Products:Products[nLinha]:B1_EMIN))+'</ns:B1_EMIN>'
			Else
				cXML += '				<ns:B1_EMIN>0</ns:B1_EMIN>'
			EndIf

			If Eval(bBlock3)
				cXML += '				<ns:B1_LE>'+Alltrim(Str(Self:Products:Products[nLinha]:B1_LE))+'</ns:B1_LE>'
			Else          
				cXML += '				<ns:B1_LE>0</ns:B1_LE>'			
			EndIF

			If Eval(bBlock4)			
				cXML += '				<ns:B1_EMAX>'+Alltrim(Str(Self:Products:Products[nLinha]:B1_EMAX))+'</ns:B1_EMAX>'
			Else
				cXML += '				<ns:B1_EMAX>0</ns:B1_EMAX>'			
			EndIF
			cXML += '				<ns:B5_APLGER>'+Self:Products:Products[nLinha]:B5_APLGER+'</ns:B5_APLGER>'
			cXML += '				<ns:B5_APLESP>'+Self:Products:Products[nLinha]:B5_APLESP+'</ns:B5_APLESP>'
			cXML += '			</ns:WFPRODUCT>'

			//cria uma nova linha o objeto (array) de retorno com a instacia da classe de retorno
			aAdd(Self:Results,WsClassNew("wfResult"))
			//grava os registros
			Self:Results[nLinha]:WFM_COD := Self:Products:Products[nLinha]:WFM_COD
			Self:Results[nLinha]:B1_COD  := Self:Products:Products[nLinha]:B1_COD
			Self:Results[nLinha]:STATUS  := aResult[1]
			Self:Results[nLinha]:ERROR   := aResult[2]

		Next nLinha
	Else
		lOk := .F.
		//se tiver usuario ou senha invalida, retorna erro
		SetSoapFault('Acesso negado','Usuário ou Senha inválidos.')
	EndIF

	cXML += '			</ns:PRODUCTS>'
	cXML += '		</ns:PRODUCTS> '
	cXML += '	</ns:UPDATE> '
	cXML += '</soapenv:Body> '  
	cXML += '</soapenv:Envelope> '     
	
	MakeDir('\webformat')
	MemoWrite( "\webformat\" + DtoS(Date()) + RetNum(Time()) + ".XML", cXML )

Return lOk



/*/{Protheus.doc} wsEst010Products
Estrutura para Method Update, com todos os dados para manipular
Produtos

@author  Rafael Ricardo Vieceli
@since   11/06/2015
/*/
wsStruct wfProducts

	wsData cUser     as String
	wsData cPassword as String

	wsData Products as Array of wfProduct

EndWsStruct


wsStruct wfProduct

	wsData B1_COD    as String
	wsData B1_DESC   as String
	wsData B1_TIPO   as String
	wsData B1_UM     as String
	wsData B1_GRUPO  as String
	wsData B1_POSIPI as String
	wsData B1_CC     as String  Optional
	wsData B1_ZITEMZ as String  Optional
	wsData B1_QE     as Integer Optional
	wsData B1_EMIN   as Integer Optional
	wsData B1_LE     as Integer Optional
	wsData B1_EMAX   as Integer Optional

	wsData B5_CEME   as String
	wsData B5_DCOMPR as String
	wsData B5_APLGER as String  Optional
	wsData B5_APLESP as String  Optional

	wsData WFM_COD   as String
	wsData OPERATION as String

EndWsStruct


/*/{Protheus.doc} wfResult
Estrutura para Retorno do Method Update

@author  Rafael Ricardo Vieceli
@since   11/06/2015
/*/
wsStruct wfResult

	wsData WFM_COD  as String
	wsData B1_COD   as String
	wsData STATUS   as Boolean
	wsData ERROR    as String

EndWsStruct

Static Function AtualizaProduto(Product)

	Local nOpcao
	Local cError := ""

	Local aMata010 := {}
	Local aMata180 := {}

	//controle de erros nas rotinas automaticas
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	IF Product:OPERATION == "CREATE"
		nOpcao := 3
	ElseIF Product:OPERATION == "UPDATE"
		nOpcao := 4
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( xFilial("SB1") + Product:B1_COD ) )
	EndIF

	aAdd( aMata010, { "B1_COD"    , Product:B1_COD    , Nil })
	aAdd( aMata010, { "B1_DESC"   , Product:B1_DESC   , Nil })
	aAdd( aMata010, { "B1_UM"     , Product:B1_UM     , Nil })
	aAdd( aMata010, { "B1_LOCPAD" , IIF(nOpcao==3,"01",SB1->B1_LOCPAD) , Nil })
	aAdd( aMata010, { "B1_TIPO"   , IIF(nOpcao==4 .And.  Empty(Product:B1_TIPO  ),SB1->B1_TIPO  ,Product:B1_TIPO)   , Nil })
	aAdd( aMata010, { "B1_GRUPO"  , IIF(nOpcao==4 .And.  Empty(Product:B1_GRUPO ),SB1->B1_GRUPO ,Product:B1_GRUPO)  , Nil })
	aAdd( aMata010, { "B1_POSIPI" , IIF(nOpcao==4 .And.  Empty(Product:B1_POSIPI),SB1->B1_POSIPI,Product:B1_POSIPI) , Nil })
	IF !Empty(Product:B1_CC)    
		aAdd( aMata010, { "B1_CC"     , Product:B1_CC     , Nil }) 
	EndIF
	IF !Empty(Product:B1_ZITEMZ)
		aAdd( aMata010, { "B1_ZITEMZ" , Product:B1_ZITEMZ , Nil })
	EndIF	
	IF !Empty(Product:B1_QE)
		aAdd( aMata010, { "B1_QE"     , Product:B1_QE     , Nil })
	EndIF
	IF !Empty(Product:B1_LE) .AND. !Empty(Product:B1_EMAX) .AND. Empty(Product:B1_EMIN)
		aAdd( aMata010, { "B1_EMIN"   , 0.01   , Nil })
	EndIF
	IF !Empty(Product:B1_EMIN)
		aAdd( aMata010, { "B1_EMIN"   , Product:B1_EMIN   , Nil })
	EndIF
	IF !Empty(Product:B1_LE)
		aAdd( aMata010, { "B1_LE"     , Product:B1_LE     , Nil })
	EndIF
	IF !Empty(Product:B1_EMAX)
		aAdd( aMata010, { "B1_EMAX"   , Product:B1_EMAX   , Nil })
	EndIF
	Begin Transaction
		MSExecAuto({ |x,y| Mata010(x,y)}, aMata010, nOpcao)
		IF !lMSErroAuto   
			cTextoAux := "FEZ A ATUALIZAÇÃO DO PRODUTO "+Product:B1_COD

			RecLock('SB1',.F.)   
			IF !Empty(Product:B1_LE) .AND. !Empty(Product:B1_EMAX) .AND. Empty(Product:B1_EMIN)
				SB1->B1_EMIN := 0.01
			EndIF
			IF !Empty(Product:B1_EMIN)
				SB1->B1_EMIN :=  Product:B1_EMIN  
				cTextoAux += "  PONTO DE PEDIDO VEIO COM "+Alltrim(STR(Product:B1_EMIN))
			EndIF
			IF !Empty(Product:B1_LE)
				SB1->B1_LE := Product:B1_LE    
			EndIF
			IF !Empty(Product:B1_EMAX)
				SB1->B1_EMAX :=  Product:B1_EMAX   
			EndIF		    		
			IF Empty(Product:B1_ZITEMZ)
				SB1->B1_ZITEMZ :=  Product:B1_ZITEMZ 
			EndIF	

			MsUnlock()		    
			
             cTextoAux += "  REALIZADO RECLOCK PRODUTO "+Product:B1_COD
			 MemoWrit("\AFS\LOG\_"+DtoS(dDatabase)+"_"+StrTran(time(),":","")+"WEBFORMAT.TXT", cTextoAux )

			//pesquisa se existe complemento
			SB5->( dbSetOrder(1) )
			If SB5->( dbSeek( xFilial("SB5") + SB1->B1_COD ) )
				RecLock('SB5',.F.)
				SB5->B5_CEME	= Product:B5_CEME   
				SB5->B5_DCOMPR 	:= Product:B5_DCOMPR 
				SB5->B5_APLGER	:= Product:B5_APLGER 
				SB5->B5_APLESP	:= Product:B5_APLESP 
				MsUnlock()			
			Else     
				RecLock('SB5',.T.)
				SB5->B5_FILIAL	:= xFilial("SB5")
				SB5->B5_COD		:= SB1->B1_COD   				
				SB5->B5_CEME	:= Product:B5_CEME   
				SB5->B5_DCOMPR 	:= Product:B5_DCOMPR 
				SB5->B5_APLGER	:= Product:B5_APLGER 
				SB5->B5_APLESP	:= Product:B5_APLESP 				
				MsUnlock()
			EndIf
			//se encontrar é opcao 4=alterar, se não 3=incluir

/*
			nOpcao := IIF( SB5->( Found() ), 4 , 3)

			aAdd( aMata180, { "B5_COD"    , SB1->B1_COD       , Nil })
			aAdd( aMata180, { "B5_CEME"   , Product:B5_CEME   , Nil })
			aAdd( aMata180, { "B5_DCOMPR" , Product:B5_DCOMPR , Nil })
			aAdd( aMata180, { "B5_APLGER" , Product:B5_APLGER , Nil })
			aAdd( aMata180, { "B5_APLESP" , Product:B5_APLESP , Nil })
*/			

		//	MSExecAuto({ |x,y| Mata180(x,y)}, aMata180, nOpcao)

		EndIF

		//se deu erro (produto ou complemento)
		IF lMsErroAuto
			//se deu erro, volta que deu errado
			//exemplo, se incluiu o produto e deu erro no complemento
			//não pode incluir o produto, tem que voltar
			DisarmTransaction()
			//trata o erro do execAuto
			cError := GetErroAuto(Product:B1_COD)
		EndIF

	End Transaction

Return { !lMSErroAuto , cError }


Static Function GetErroAuto(cProduto)

	Local aErro := GetAutoGRLog()
	Local cError := ""
	Local cErrorFile := ""
	Local n1
	Local cAux := "HELP"

	cErrorFile := FormDate(Date()) + " " + Time() + CRLF
	cErrorFile += "Produto: " + cProduto + CRLF

	//percorre o erro do execAuto
	For n1 := 1 to len(aErro)
		cErrorFile += aErro[n1] + CRLF
		//tira todos os campos, para filtrar só o Help
		IF "Tabela SB" $ aErro[n1] .And. len(aErro) > 5
			cAux := "CAMPO"
		EndIF
		//enquando estiver com help vai adicionando
		IF cAux == "HELP"
			cError += " " + aErro[n1]
		EndIF
		//tambem coloca o campo invalido
		IF "< -- Invalido" $ aErro[n1]
			cError += " " + substr(aErro[n1],1,At("< -- Invalido",aErro[n1])-1)
		EndIF
	Next n1
	//tira ENTER
	cError := StrTran(cError,CRLF,"")
	cError := StrTran(cError,Chr(13),"")
	cError := StrTran(cError,Chr(10),"")
	cError := StrTran(cError,"--","")
	//tira espaços demais, de alinhamento quando tem varios campos
	aErro := StrTokArr(cError," ")
	//limpa a variavel de erro
	cError := ""
	//se adiciona novamente
	For n1 := 1 to len(aErro)
		cError += aErro[n1]+" "
	Next n1
	//tira espaço que ficou no final
	cError := alltrim(cError)

	MakeDir('\webformat')
	MemoWrite( "\webformat\" + DtoS(Date()) + RetNum(Time()) + "_" + cProduto + ".txt", cErrorFile )

Return cError