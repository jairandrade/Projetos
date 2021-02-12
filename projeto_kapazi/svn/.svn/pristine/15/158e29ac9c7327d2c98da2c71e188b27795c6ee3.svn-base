#include 'protheus.ch'

user function AFIN001XC()
	local aFix						:= {}
	private cCadastro		:=	'Log de envio de boletos"
	private cAls	:= "Z0A"
	private aRotina:= {}
 
 aAdd(aFix, {'Cliente'		, 'Z0A_CLIENT'})
 aAdd(aFix, {'Loja'		, 'Z0A_LOJA'})
 aAdd(aFix, {'Numero NF', 'Z0A_NUM'})
 aAdd(aFix, {'Parcela'		, 'Z0A_PARCEL'})
 aAdd(aFix, {'Status'		, 'Z0A_STDESC'})
 
	aAdd(aRotina, {"Enviar e-mail", "u_afin01sm" , 0, 4 })
	//aAdd(aRotina, {"Visualizar", "u_Mod3manut", 0, 2 })
	//aAdd(aRotina, {"Incluir", "u_Mod3manut", 0, 3 })
	//aAdd(aRotina, {"Alterar", "u_Mod3manut", 0, 4 })
	//aAdd(aRotina, {"Excluir", "u_Mod3manut", 0, 5 })
 
 
	dbselectarea(cAls)
	(cAls)->(dbsetorder(1))
	(cAls)->(dbGoTop())
	mBrowse(,,,,cAls, aFix)
	
return

user function AFIN01SM(cAls, nReg, nOpc)
	local aParcela := {}
	local cChave		:= ""
	local aArea			:= GetArea()
	
	if MsgYesNo('Envia todas as parcelas?')
		cChave := Z0A->(Z0A_FILIAL + Z0A_FILE + Z0A_CLIENT + Z0A_LOJA + Z0A_NUM)
		while cChave == Z0A->(Z0A_FILIAL + Z0A_FILE + Z0A_CLIENT + Z0A_LOJA + Z0A_NUM)
			SE1->(dbGoTo(Z0A->Z0A_E1RECN))
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			if SA1->(dbSeek(xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA)))
				aAdd(aParcela, {SE1->(RecNo()), SA1->(RecNo()), Z0A->(RecNo())})
			endif
			Z0A->(dbSkip())
		enddo
	else
		SE1->(dbGoTo(Z0A->Z0A_E1RECN))
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		if SA1->(dbSeek(xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA)))
			aAdd(aParcela, {SE1->(RecNo()), SA1->(RecNo()), Z0A->(RecNo())})
		endif
	endif
	
	if Len(aParcela) > 0
		cFPath := U_RFIN001X(aParcela)
		if !Empty(cFPath)
			lRet := StaticCall(F200FIM, fSendBol, cFPath, aParcela)
			for nI := 1 to Len(aParcela)
				Z0A->(dbGoTo(aParcela[nI,3]))
				RecLock("Z0A", .f.)
				Z0A->Z0A_STATUS := IIF(lRet, 'E', 'N')
				Z0A->Z0A_STDESC := IIF(lRet, 'Email enviado com sucesso', 'Erro ao enviar email')
				MsUnlock()
			next nI
			//FErase(cFPath)
		endif
	endif
	
	RestArea(aArea)
return

