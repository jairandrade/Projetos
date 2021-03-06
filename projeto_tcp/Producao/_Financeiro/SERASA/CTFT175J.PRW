#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CTFT175J �Autor  � - Kaique Sousa  -  � Data �  02/20/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � FUNCAO AUXILIAR PARA MANIPULAR PARAMETROS.                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CTFT175J(_cPar)

Local cUsuario		:= ""						// Nome do Usuario.
Local cSenhaLoja	:= ""						// Senha digitada pelo usuario. Valida se eh a senha do Administrador. 
Local lPswSeek   	:= .F.					// Verifica se a senha foi encontrada
Local lRet       	:= .F.        			// Retorno da funcao: senha administrador OK
Local cNomUsu		:= AllTrim(cUserName)
Local _aUsr			:= {}
Local cMsg			:= ""
Local aBox			:= {}
Local CR				:= Chr(13)+Chr(10)
Local lTemPar		:= !Empty(GetNewPar(_cPar,''))

While .T.

	_cVlrAtu := GetNewPar(_cPar,'*Par�metro n�o existe*')
	_cVlrAtu := If(Len(_cVlrAtu) > 40,Substr(_cVlrAtu,1,38)+'(...)',_cVlrAtu)
	
	cMsg		:= 'Par�metro....: ' + _cPar + CR
	If __cUserID $ U_XUSERTI()
		cMsg		+= 'Valor........: ' + _cVlrAtu + CR + CR
	EndIf
	cMsg		+= 'Seu usu�rio..: ' + __cUserID

	If Aviso('Dados T�cnicos',cMsg,{If(lTemPar,'Editar','Criar'),'OK'},,'Ol� ' + cNomUsu) = 2
		Exit
	EndIf

	If GetPass( @cUsuario , @cSenhaLoja )

		PswOrder(1)
		If lPswSeek := PswSeek(cUsuario)
			If lPswSeek := ( PswAdmin(PswRet()[1][1],cSenhaLoja)= 0 )
				cNomUsu 	:= PswRet()[1][2]
			Else
				//Mais uma tentativa com o parametro
				PswOrder(2)
				If PswSeek(AllTrim(cUsuario),.T.)
					If lPswSeek := PswName( cSenhaLoja )
						_aUsr := PswRet()
						If lPswSeek := (_aUsr[1][1] $ GetNewPar('MV_EQUIADM','000203'))
							cNomUsu 	:= _aUsr[1][2]
						EndIf
					EndIf
				EndIF
			EndIf
			
		EndIf

		If lPswSeek
			aBox := {{1,'Valor:',PadR(GetNewPar(_cPar,''),200),'@!','AllWaysTrue()',,,120,.F. }}
			If ParamBox( aBox , "Edi��o do par�metro "+_cPar,{})
				U_XPUTMV(_cPar,MV_PAR01)
				lRet := .T.
			EndIf
			cNomUsu := AllTrim(cUserName)
		Else
			Aviso('Aten��o ' + cNomUsu,'S� Administradores !',{'OK'})
			cNomUsu := AllTrim(cUserName)
		Endif	  

	EndIf

EndDo

Return( lRet )  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � GetPass  � Autor � - Kaique Sousa  -     � Data � 20/02/12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Tela Simples para colher uma senha                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetPass( cUser , cSenha )

Local oDlgSenha,oGetSenha
Local nOpc := 0
Local lRet := .F.

cUser		:= Space(40)
cSenha   := Space(30)

DEFINE DIALOG oDlgSenha Of GetWndDefault() TITLE OemToAnsi("Informe sua senha") FROM 12, 20 TO 19,45

@ .5,1 SAY "Usu�rio:
@ .5,4 MSGET oGetUser VAR cUser SIZE 60,09 

@ 1.5,1 SAY "Senha..:
@ 1.5,4 MSGET oGetSenha VAR cSenha PASSWORD SIZE 60,09 

DEFINE SBUTTON FROM 38,40 TYPE 1 ACTION (lRet:=.T.,oDlgSenha:End())	ENABLE OF oDlgSenha
DEFINE SBUTTON FROM 38,70 TYPE 2 ACTION (oDlgSenha:End())				ENABLE OF oDlgSenha

ACTIVATE MSDIALOG oDlgSenha CENTERED

cUser		:= AllTrim(cUser)
cSenha 	:= AllTrim(cSenha)

Return( lRet )
