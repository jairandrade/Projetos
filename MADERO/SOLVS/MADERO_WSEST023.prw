#INCLUDE 'protheus.ch' 
#INCLUDE "restful.ch"

/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GetProdutos                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do WebService de cadastro de produtos                              !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Marcio A. Zaguetti                                                            !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 16/06/2020                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
WSRESTFUL GetConsultarProdutos DESCRIPTION "Madero - Cadastro de produtos"

	WSMETHOD GET DESCRIPTION "Cadastro de Produtos" WSSYNTAX "/GetConsultarProdutos"

End WSRESTFUL

 /*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GET                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do Metodo GetConsultarProdutos                                     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio A. Zaguetti                                                            !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 16/06/2020                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
WSMETHOD GET WSRECEIVE WSSERVICE GetConsultarProdutos
Local cXml		:= ""
Local nThrdID   := ThreadId()

	ConOut(AllTrim(Str(nThrdID))+": Requisitando metodo GetConsultarProdutos em " + DtoC(Date()) + " as " + Time())
	
	::SetContentType("application/xml")
	
	cXml := WSEST023(nThrdID)

	::SetResponse(cXML)

    ConOut(AllTrim(Str(nThrdID))+": Fim da requisicao do metodo GetConsultarProdutos em " + DtoC(Date()) + " as " + Time())

Return .T.



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ProtheusGetProdutos                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração das classe para gerar o XML                                        !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
Class ProtheusGetProdutos From ProtheusMethodAbstract

	Method new(cMethod) constructor
	Method makeXml(cAlQry)

EndClass


/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! New                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo Inicializados da Classe ProtheusGetProdutos                            !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
Method New(cMethod) Class ProtheusGetProdutos
	::cMethod := cMethod
Return



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! makeXml                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo para gerar XML do WS ProtheusGetProdutos                                 !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 17/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
Method makeXml(cAlQry) Class ProtheusGetProdutos
Local cXml := ''

	cXml += '<?xml version="1.0" encoding="ISO-8859-1"?>'	
	cXml += '<retorno>'	

	
	cXml += '<produtos>'	

	While !(cAlQry)->(Eof())
	
		cXml += '<produto'			
		cXml += ::tag('b1cod'		,(cAlQry)->B1_COD)		
		cXml += ::tag('b1desc'		,(cAlQry)->B1_DESC)	
		cXml += '/>'
	
		(cAlQry)->(dbSkip())
	
	EndDo
	
	cXml += '</produtos>'	
	cXml += '<confirmacao>'
	cXml += '<confirmacao'
	cXml += ::tag('integrado',"true")			
	cXml += ::tag('mensagem',"Consulta ok.")
	cXml += ::tag('data'	,DtoS(Date()))		
	cXml += ::tag('hora'	,Time())	
	cXml += '/>'
	cXml += '</confirmacao>'
	cXml += '</retorno>'

Return cXml


/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! WSEST001                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para executar WS GetAcesso                                             !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 17/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
Static Function WSEST023(nThrdID)
Local cQuery	:= ""
Local cAlQry	:= ""
Local cXml		:= ""
Local oTag		:= Nil

	ConOut(AllTrim(Str(nThrdID))+": Selecionando produtos...")
	// -> Verifica se foram passados os parâmetros de empresa e filial
	cQuery := "SELECT DISTINCT B1_COD, B1_DESC FROM SB1010 WHERE D_E_L_E_T_ <> '*' "
	cQuery += "UNION "
	cQuery += "SELECT DISTINCT B1_COD, B1_DESC FROM SB1020 WHERE D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	cAlQry := MPSysOpenQuery(cQuery)

	ConOut(AllTrim(Str(nThrdID))+": Enviando dados...")
	If !(cAlQry)->(Eof())
    	oTag := ProtheusGetProdutos():New("Tag")
		cXml := oTag:MakeXml(cAlQry)
	Else
		cXml:='<?xml version="1.0" encoding="ISO-8859-1"?>'
		cXml+='<retorno>'
		cXml+='<produtos>'
        cXml+='</produtos>'
		cXml+='<confirmacao>'
		cXml+='<confirmacao integrado="false" mensagem="Erro: Produtos nao encontrado." data="' + DtoS(Date()) + '" hora="' + Time() + '"/>'
        cXml+='</confirmacao>'
		cXml+='</retorno>'
	EndIf	

Return cXml

