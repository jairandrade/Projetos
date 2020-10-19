#Include 'Protheus.ch'

/*/{Protheus.doc} PNA280MRC
Este Ponto de Entrada permite verificar o acesso das marcações na rotina Integrados.
@type function
@author luizf
@since 19/08/2016
/*/
User Function PNA280MRC()

DBSelectArea("ZAB")
DBSetOrder(01)//ZAB_FILIAL+ZAB_USER

Return !ZAB->(MSSeek(xFilial("ZAB")+__cUserID))

