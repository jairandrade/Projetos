/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矰EPARAUSR 篈utor  � Alessandro Bueno   � Data � 01/12/2015  罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Tela de cadastro de cestas para desempenho RH              罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       �                                                            罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
User Function CADCESTA()

Local cAlias  := "ZCE"
Local cTitulo := "Relacionamento Fun玢o por Cesta"


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
Local Mensagem := "Este registro j� existe em base, favor utilizar outro c骴igo!"
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