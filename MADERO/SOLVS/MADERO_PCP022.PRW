#INCLUDE 'TOTVS.CH' 

#DEFINE ENTER   CHR(13) + CHR(10)

/*-----------------+---------------------------------------------------------+
!Nome              ! VlRotOpe - Cliente: Madero                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Valida roteiro e opecacao      	                     !
+------------------+---------------------------------------------------------+
!Autor             ! Thiago Berna                                            !
+------------------+---------------------------------------------------------!
!Data              ! 03/10/2019                                              !
+------------------+--------------------------------------------------------*/

User Function VlRotOpe(cCampo)

Local cRetorno  := ''
Local aArea     := GetArea()
Default cCampo  := ''

DbSelectArea('SG2')
SG2->(DbSetOrder(1))
If SG2->(DbSeek(xFilial('SG2')+SC2->C2_PRODUTO+SC2->C2_ROTEIRO))

    While SG2->(!Eof()) .And. SG2->G2_FILIAL == xFilial('SG2') .And. SG2->G2_PRODUTO == SC2->C2_PRODUTO .And. SG2->G2_CODIGO == SC2->C2_ROTEIRO
        // -> Seleciona roteiro de operação
        If !(SG2->G2_OPERAC $ 'XB|XA|')        
            If cCampo == 'H6_OPERAC'
                cRetorno := SG2->G2_OPERAC
            ElseIf cCampo == 'H6_RECURSO'
                cRetorno := SG2->G2_RECURSO
            EndIf
            Exit
        EndIf
        SG2->(DbSkip())
    EndDo

EndIf

RestArea(aArea)

Return cRetorno

/*-----------------+---------------------------------------------------------+
!Nome              ! VlDtHrIn - Cliente: Madero                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Valida data e hora inicial e final                      !
+------------------+---------------------------------------------------------+
!Autor             ! Thiago Berna                                            !
+------------------+---------------------------------------------------------!
!Data              ! 03/10/2019                                              !
+------------------+--------------------------------------------------------*/

User Function VlDtHrIn(cCampo)

Local cRetorno  := ''
Local aCalend   :={}

Default cCampo  := ''

DbSelectArea('SG2')
SG2->(DbSetOrder(1))
If SG2->(DbSeek(xFilial('SG2')+SC2->C2_PRODUTO+SC2->C2_ROTEIRO))

    While SG2->(!Eof()) .And. SG2->G2_FILIAL == xFilial('SG2') .And. SG2->G2_PRODUTO == SC2->C2_PRODUTO .And. SG2->G2_CODIGO == SC2->C2_ROTEIRO
        // -> Seleciona roteiro de operação
        If !(SG2->G2_OPERAC $ 'XB|XA|')   
            aCalend := U_AGRHCA(Posicione('SH1',1,xFilial('SH1')+SG2->G2_RECURSO,'H1_CALEND'),xFilial('SH7'),dDataBase)     
            If cCampo == 'H6_DATAINI'
                cRetorno := dDataBase
            ElseIf cCampo == 'H6_DATAFIN'
                cRetorno := dDataBase
            ElseIf cCampo == 'H6_HORAINI'
                cRetorno := aCalend[2]
            ElseIf cCampo == 'H6_HORAFIN'
                cRetorno := StrTran(Transform(SomaHoras(aCalend[2],u_Val2Hora((M->H6_QTDPROD / SG2->G2_LOTEPAD) * SG2->G2_TEMPAD)),'@E 99.99'),',',':')
            EndIf
            Exit
        EndIf
        SG2->(DbSkip())
    EndDo

EndIf

Return cRetorno

/*-----------------+---------------------------------------------------------+
!Nome              ! AGRHCA - Cliente: Madero                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Identifica a hora inicial do calendario                 !
+------------------+---------------------------------------------------------+
!Autor             ! Thiago Berna                                            !
+------------------+---------------------------------------------------------!
!Data              ! 03/10/2019                                              !
+------------------+--------------------------------------------------------*/

User Function AGRHCA(cCalenda,cFil,dDtIni)
	Local aAreaAt  := GetArea()
	Local aDISPBIN := {}, aMATRET := {},aAHDISP := {}
	Local nTAMAN,X,Y,nTOTHORA,nPOS1C,nPOS2C
	Local cALOC,cHORAFCA,cHORAICA
	Local cFilSH7 := If(cFil <> Nil,xFilial("SH7"),cFIL)
    Local dDinV := dDtini
	Local aVetR := {Ctod("  /   /   "),Space(5)}

	If !AGRIFDBSEEK("SH7",cCalenda,1,.f.,cFilSH7)
		RestArea(aAreaAt)
		Return(aVetR)
	Endif

	cALOC  := SH7->H7_ALOC
	nTAMAN := Len(cALOC) / 7
	Aadd(aDISPBIN, "")
	While Len(cALOC) > 0
		Aadd(aDISPBIN, SubStr(cALOC,1,nTAMAN) + " ")
		cALOC := SubStr(cALOC,nTAMAN + 1)
	End

	aDISPBIN[1] := aDISPBIN[8]
	aDel(aDISPBIN,8)
	aSize(aDISPBIN,7)

	For X := 1 to Len(aDISPBIN)
		Store 0 To nPOS1C,nPOS2C,nTOTHORA
		aAHDISP := {}
		For Y := 1 to Len(aDISPBIN[X])
			If substr(aDISPBIN[X],Y,1) == "X" .and. nPOS1C = 0
				nPOS1C := Y
			ElseIf substr(aDISPBIN[X],Y,1) == " " .And. nPOS1C # 0
				nPOS2C   := Y
				cHORAICA := Substr(Bit2Tempo(nPOS1C-1),3)
				cHORAFCA := SubStr(Bit2Tempo(nPOS2C-1),3)
				nTOTHORA := nTOTHORA + AGRHTOM(cHORAFCA)-AGRHTOM(cHORAICA)
				nPOS1C   := 0
				Aadd(aAHDISP,{cHORAICA,cHORAFCA})
			Endif
		Next
		Aadd(aMATRET,{AGRMTOH(nTOTHORA),aAHDISP})
	Next

    
	If !Empty(aMATRET)
		While .t.
			If aMATRET[Dow(dDinV),1] <> "00:00"
				aVetR := {dDinV,aMATRET[Dow(dDinV),2,1,1]}
				Exit
			EndIf
			dDinV ++
		End
	EndIf

	RestArea(aAreaAt)
Return(aVetR)

/*-----------------+---------------------------------------------------------+
!Nome              ! Val2Hora - Cliente: Madero                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Converte decimal em hora                                !
+------------------+---------------------------------------------------------+
!Autor             ! Thiago Berna                                            !
+------------------+---------------------------------------------------------!
!Data              ! 03/10/2019                                              !
+------------------+--------------------------------------------------------*/

User Function Val2Hora(nValor, cSepar)
    Local cHora := ""
    Local cMinutos := ""
    Default cSepar := ":"
    Default nValor := -1
     
    //Se for valores negativos, retorna a hora atual
    If nValor < 0
        cHora := SubStr(Time(), 1, 5)
        cHora := StrTran(cHora, ':', cSepar)
         
    //Senão, transforma o valor numérico
    Else
        cHora := Alltrim(Transform(nValor, "@E 99.99"))
         
        //Se o tamanho da hora for menor que 5, adiciona zeros a esquerda
        If Len(cHora) < 5
            cHora := Replicate('0', 5-Len(cHora)) + cHora
        EndIf
         
        //Fazendo tratamento para minutos
        cMinutos := SubStr(cHora, At(',', cHora)+1, 2)
        cMinutos := StrZero((Val(cMinutos)*60)/100, 2)
         
        //Atualiza a hora com os novos minutos
        cHora := SubStr(cHora, 1, At(',', cHora))+cMinutos
         
        //Atualizando o separador
        cHora := StrTran(cHora, ',', cSepar)
    EndIf
     
Return cHora