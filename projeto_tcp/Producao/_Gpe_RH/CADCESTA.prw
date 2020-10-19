/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DEPARAUSR ºAutor  ³ Alessandro Bueno   º Data ³ 01/12/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de cadastro de cestas para desempenho RH              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CADCESTA()

Local cAlias  := "ZCE"
Local cTitulo := "Relacionamento Função por Cesta"


AxCadastro(cAlias, cTitulo)


Return

User Function REG02B

Local lRet := .F.
Local cMsg := ""


If INCLUI  
	lRet := .T.
EndIf

Return lRet

User Function jaexist

Local lRetorno := .T.
Local Mensagem := "Este registro já existe em base, favor utilizar outro código!"
DBSelectArea("ZCE")
ZCE->(DbSetOrder(2))
ZCE->(DBGoTop()) 
		
If INCLUI      
   
	While ZCE->(!EoF())
		If (AllTrim(ZCE->ZCE_CESTA) == AllTrim(M->ZCE_CESTA)).and. (AllTrim(ZCE->ZCE_FUNCAO) == AllTrim(M->ZCE_FUNCAO))
			Alert(Mensagem)
			lRetorno := .F. 		
		EndIf
     	ZCE->(DbSkip())
	EndDo
EndIf

Return lRetorno