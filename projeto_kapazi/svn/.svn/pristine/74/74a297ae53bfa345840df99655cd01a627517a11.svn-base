#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

//Alteração Andre/Rsac -- 04.08.2017 -- Adequação do fonte para novo processo Cnab
//Realizado validação no ambiente compilar -- 09.08.2017 -- Andre/Rsac 
//Ajustes realizado -- 16.08.2017 -- Compilado em produção -- Andre/rsac
user Function FA200_02()

	local cFPath	:= ''
	local aArea		:= GetArea()
	local cExt			:= ""
	local cFile		:= ""
	// Lista de empresas onde o envio de boleto é permitido
	local cListEmp	:= "01/02/03/04/05/07" //GetMV("KP_F200EMP", .f., "01/02/03/04/05/07")

	if FwCodEmp() $ cListEmp
		SplitPath(AllTrim(MV_PAR04), /*@cDrive*/, /*@cPath*/, @cFile, @cExt)

		cFile += cExt
		cFile := PadR(cFile, TamSX3("Z0A_FILE")[1])
		// titulo confirmado ja posicionado

		if !Empty(SE1->E1_NUMBCO)

			//Incluido 04.08.2017 -- Andre/Rsac
			RECLOCK("SE1",.F.)
			SE1->E1_VALBCO:= "S" // Flag para identificar se o titulo foi aceito no Banco, informação importante para a impressão do boleto na rotina RFIN002.
			SE1->(msUnlock())
			//fim

			//if SE1->E1_FILIAL == xFilial("Z0A")
			dbSelectArea("Z0A")
			Z0A->(dbSetOrder(1))
			if !Z0A->(dbSeek(SE1->E1_FILIAL+ALLTRIM(STR(SE1->(RECNO()))))) // Andre/Rsac  -- 07.02.2018 --//!Z0A->(dbSeek(xFilial("Z0A") + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_CLIENTE + SE1->E1_LOJA ))      //SE1->(E1_CLIENTE + E1_LOJA + E1_NUM + E1_PARCELA)
			
//			msgstop("entrou")
				//RecLock("Z0A", !Z0A->(Found())) 		
				RecLock("Z0A", .T.) //!Z0A->(Found()))
				Z0A->Z0A_FILIAL := SE1->E1_FILIAL // xFilial("Z0A") -- 07.02.2018 -- aNDRE/rSAC
				Z0A->Z0A_E1RECN := SE1->(RecNo())
				Z0A->Z0A_DATA   := dDatabase
				Z0A->Z0A_STATUS := 'N'
				Z0A->Z0A_STDESC := 'Sem tentativa de envio'
				Z0A->Z0A_FILE   := cFile
				Z0A->Z0A_CLIENT := SE1->E1_CLIENTE
				Z0A->Z0A_LOJA   := SE1->E1_LOJA
				Z0A->Z0A_NUM    := SE1->E1_NUM
				Z0A->Z0A_PARCEL := SE1->E1_PARCELA
				Z0A->Z0A_HORA   := Time()
				Z0A->Z0A_USER   := CUSERNAME
				MsUnlock()
			endif
		endif
	endif
	//endif

	RestArea(aArea)

return

