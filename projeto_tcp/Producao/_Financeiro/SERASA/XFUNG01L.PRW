#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � xGetMV   �Autor  � - Kaique Sousa  -  � Data �  03/28/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � PESQUISA UM PARAMETRO, SEMPRE BUSCANDO NA TABEL SX6 OU     ���
���          � RETORNA UM VALOR PADRAO.                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*User Function xGetMV(cMvPar,_cDef)

Local lExist		:= .F.

Local _nRecSX6		:= SX6->(Recno())
Local _nOrdSX6		:= SX6->(IndexOrd())

Local xConteud		:= ""
Local xTipo			:= ""

Default _cDef		:= ""

SX6->(DbSetOrder(1))
SX6->(DbGoTop())

If !SX6->(DbSeek(cFilAnt + Subs( cMvPar, 1, 10)))
	If SX6->(DbSeek( Space(Len(AllTrim(cFilAnt)))+Subs(cMvPar,1,10)))
		lExist	:= .T.
	EndIf
Else
	lExist := .T.
EndIf

If lExist

	xConteud := StrTran(StrTran(SX6->X6_CONTEUD,'"',''),"'","")
	xTipo		:= SX6->X6_TIPO

	//Volta o ponteiro para o local original
	SX6->(DbSetOrder(_nOrdSX6))
	SX6->(DbGoTo(_nRecSX6))

	Do Case
		Case xTipo = 'C'
			Return( AllTrim(xConteud) )

		Case xTipo = 'N'
			If Empty(xConteud)
				Return( 0 )
			Else
				Return( Val(AllTrim(xConteud)) )
			EndIf

		Case xTipo = 'L'
			If Upper(AllTrim(xConteud)) $ '.T.|S|VERDADEIRO|TRUE'
				Return( .T. )
			ElseIf Upper(AllTrim(xConteud)) $ '.F.|N|FALSO|FALSE'
				Return( .F. )
			Else
				Return( Nil )
			EndIf

		Case xTipo = 'D'
			If Empty(xConteud)
				Return( CtoD("  /  /    ") )
			ElseIf '/' $ xConteud
				Return( CtoD(AllTrim(xConteud)) )
			Else
				Return( StoD(AllTrim(xConteud)) )
			EndIf

		OtherWise
			Return( Nil )

	EndCase			

Else

	//Volta o ponteiro para o local original
	SX6->(DbSetOrder(_nOrdSX6))
	SX6->(DbGoTo(_nRecSX6))

	Return( _cDef )

EndIf

Return( Nil )*/  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SONUMEROS �Autor  �Kaique SOusa        � Data �  10/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �RETIRA OU ANALISA OS CARACTERES NAO NUMERICOS DE UMA STRING.���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
���   Entrada�_cStrin - Codigo a ser analisado - Caracter                 ���
���          �_nAcao  - 0 - Retorna somente os caracteres numericos       ���
���          �        - 1 - Retorno .T. OU .F. conforme analise           ���
���          �                                                            ���
���     Saida�_xRet   - _nAcao = 0 - Retorna os caracteres numericos      ���
���          �          _nAcao = 1 - .T. se so houver caracteres numericos���
���          �                       .F. se houver algum nao numerico     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SONUMERO(_cString,_nAcao)

Local _xRet
Local _cRetorno	:= ''
Local _nI       	:= 0

Default _nAcao		:= 0

For _nI := 1 to Len(AllTrim(_cString))

	If Substr(_cString,_nI,1) $ '0123456789'
		_cRetorno += Substr(_cString,_nI,1)
	EndIF

Next _nI

Do Case
	Case _nAcao = 0		//Retorna string somente com os numeros
		_xRet := _cRetorno
	Case _nAcao = 1		//Retorna .T. se a string passada so tinha numerou, .f. se havia outros caracteres.
		_xRet := Len(AllTrim(_cString)) == Len(AllTrim(_cRetorno))
EndCase

Return( _xRet )    



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � XUSERTI  �Autor  � Luciano Maia       � Data �  04/01/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorno os Codigos dos Usuarios do Grupo TI.                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function XUSERTI(_nFun)

Local _xRet
Local _cUsers		:=	""
Local _cMail		:= ""

Private _aEquipe	:=	{}
Private _nPNome		:= 0
Private _nPID			:= 0
Private _nPMail		:= 0

Default _nFun		:= 0

aAdd( _aEquipe , {"Adm"			, "000000" , ""												} )
aAdd( _aEquipe , {"Maia"		, "000203" , "luciano@sismaia.com.br"					} )
aAdd( _aEquipe , {"Renato" 	, "000305" , "renato.wesley@palusa.com.br"			} )
aAdd( _aEquipe , {"Wallace" 	, "000305" , "wallace.dutra@palusa.com.br"			} )

_nPNome		:= 1
_nPID			:= 2
_nPMail		:= 3

Do Case
	Case _nFun = 0		//Usuarios
		_xRet := _cUsers := RetEqp(0)
	Case _nFun = 1		//Emails do Time TI
		_xRet := _cMail := RetEqp(1)
	Case _nFun = 2		//Se usuario corrente e da equipe de TI
		_cUsers := RetEqp(0)
		_xRet := (__cUserId $ _cUsers)
EndCase

Return( _xRet )



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TICASTRI  �Autor  �Microsiga           � Data �  11/16/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � FUNCAO AUXILIAR									                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RetEqp( _nI )

Local _cRet	:= ""

Do Case
	Case _nI = 0	//ID dos Usuarios
		aScan( _aEquipe , {|x| If(Empty(x[_nPID])	,Nil,_cRet+='|'+x[_nPID]) 	} )
	Case _nI = 1	//Emails dos Usuarios
		aScan( _aEquipe , {|x| If(Empty(x[_nPMail])	,Nil,_cRet+=';'+x[_nPMail]) 	} )
EndCase                                           	

Return( _cRet )




