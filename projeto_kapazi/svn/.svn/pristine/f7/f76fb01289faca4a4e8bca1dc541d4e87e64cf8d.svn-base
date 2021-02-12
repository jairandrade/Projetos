#Include "Protheus.ch"
#include "rwmake.ch"
#include "TbiConn.ch"
//==================================================================================================//
//	Programa: GATHRIOP		|	Autor: Luis Paulo						|	Data: 04/08/2020		//
//==================================================================================================//
//	Descrição: Gatilho do campo H6_HORAINI                  										//
//																									//
//==================================================================================================//
User Function GATHRIOP()
Local lRet      := .t.

Local cHrIni    := ""
Local dDatIni   := "" 
Local nQtdApt   := 0 

Local nMinFiMM  := 0
Local aRet1     := {0,0}
Local aRet2     := {ddatabase,"09:10"}
Local cProdto   := M->H6_PRODUTO
Local _nMiAtu   := 0

If Empty(M->H6_QTDPROD)
    MsgInfo("Informe a quantidade a ser apontada para que o sistema calcule o tempo fim de apontamento","Kapazi")
    return .t.
EndIf

If Empty(M->H6_DATAINI)
    //MsgInfo("Informe a quantidade a ser apontada para que o sistema calcule o tempo fim de apontamento","Kapazi")
    return .t.
EndIf

If Empty(M->H6_HORAINI)
    //MsgInfo("Informe a quantidade a ser apontada para que o sistema calcule o tempo fim de apontamento","Kapazi")
    return .t.
EndIf

cHrIni    := M->H6_HORAINI
dDatIni   := M->H6_DATAINI
nQtdApt   := M->H6_QTDPROD

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
SB1->(DbGoTop())
If SB1->(DbSeek( xFilial("SB1") + cProdto)) 
    If SB1->B1_XUCALOP == 'S'
        If !Empty(SB1->B1_XTMPIDE)
            aRet1 := BuscaHrPr(cProdto)
            // aRet1[1] //minutos
            // aRet1[2] //razao

            nMinFiMM   :=  (aRet1[1] * nQtdApt) //Quantidade Final de minutos

            aRet2 := CalcHrFIm(dDatIni,cHrIni,nMinFiMM)
            // aRet2[1] //Data Final
            // aRet2[2] //Hora Final

            If M->H6_DATAINI ==  aRet2[1] .And. M->H6_HORAINI ==  aRet2[2]  

                    _nMiAtu := (Val(Substr(aRet2[2],4,2))) + 1

                    If _nMiAtu <= 59 //muda a hora
                            _nMiAtu := StrZero(_nMiAtu,2)
                        
                            M->H6_DATAFIN := aRet2[1]
                            M->H6_HORAFIN := Substr(aRet2[2],1,3) + _nMiAtu
                        Else 
                            _nMiAtu := "00" //Passa para proxima hora
                            
                            //aumenta uma hora
                            If Val(Substr(aRet2[2],1,2)) == 23 //23hs
                                     M->H6_DATAFIN := (aRet2[1] + 1)
                                     M->H6_HORAFIN := "00:00"
                                Else 
                                    // M->H6_DATAFIN := aRet2[1]
                                    // M->H6_HORAFIN := StrZero( (Val(Substr(aRet2[2],1,2)) + 1) ,2) + ":" + _nMiAtu
                            EndIf
                    EndIf
                   

                Else 
                    M->H6_DATAFIN := aRet2[1]
                    M->H6_HORAFIN := aRet2[2]
            EndIf
        EndIf

    EndIf 
    
EndIf

Return(lRet)

Static Function CalcHrFIm(_cDatIni,_cHrIni,_nMinFiMM)
Local aRet      := {}
Local nHrIni    := ((Val(Substr(_cHrIni,1,2))) * 60)    //Hora
Local nMiIni    := Val(Substr(_cHrIni,4,2))             //minutos

Local nMinTot   := (nHrIni + nMiIni) + _nMinFiMM    //Total de minutos a partir da zero hr da data + tempo previsto
Local nHrs      := nMinTot / 60                     //Horas totais do dia + o inclemento de minutos calculados oriundos do produto   
Local nDiSum    := Int((nMinTot / 60)/24)           //Dias a mais que serão somados na data base atual inicial

Local DiaFinal  := _cDatIni + nDiSum                 //Data Final a ser acrescentada na data inicial   

Local cHrFinal  := StrZero((INT((nMinTot / 60) - (nDiSum * 24))),2) //Quantidade de horas final
Local cMiFinal  := StrZero( ( ((nMinTot / 60) - (nDiSum * 24)) - Val(cHrFinal) ) * 60 ,2) 

aRet := {DiaFinal,cHrFinal + ":"+ cMiFinal}

//1570 minutos -- 1425
//1425 + 5 Dias(7200) + 130  = 8755
//8625 minutos / 60 = 145,9166666666667
//Pega a quantidade de dias e multiplica por 24
// 6 * 24 = 144 ///////////145,9166666666667 - 144 = 
//0,9166666666667

Return(aRet)

Static Function VldHoraSPB(cHora)
Local lRet		:= .F.
Local cHoras	:= Substr(cHora,1,2)
Local cMinutos := Substr(cHora,4,2)

If cHoras >= "00" .And. cHoras < "24" .And. cMinutos >= "00" .And. cMinutos < "60"
    lRet := .T.
EndIf
If ( !lRet)
    Help(" ",1,"VLDHORA")
EndIf

Return(lRet)


Static Function BuscaHrPr(cProdto)
Local aArea     := GetArea()
Local nRazao    := 0
Local aRet      := {0,0}

nRazao := (((100 * SB1->B1_XTMPIDE) / 60) /100) //razao mi
Reclock("SB1",.F.)
SB1->B1_XFRAHRS := nRazao
SB1->(MsUnlock())

aRet := {SB1->B1_XTMPIDE,SB1->B1_XFRAHRS}

RestArea(aArea)
Return(aRet)


User Function AtuHora()
Local lRet   := .T.
Local cCampo := "M->H6_HORAINI"
Local nEndereco
Local nHora,nMinutos
Local nPos
Local cHoraIni  := ""

If Empty(M->H6_DATAINI)
    //MsgInfo("Informe a quantidade a ser apontada para que o sistema calcule o tempo fim de apontamento","Kapazi")
    return .t.
EndIf

If Empty(M->H6_HORAINI)
    //MsgInfo("Informe a quantidade a ser apontada para que o sistema calcule o tempo fim de apontamento","Kapazi")
    return .t.
EndIf

//Substitui espacos em branco por "0"
If ReadVar() == "M->H6_HORAFIN" .Or. ReadVar() == "M->H6_HORAINI" .Or. ReadVar() == "M->H6_QTDPROD"
    cHoraIni  :=  StrTran(M->H6_HORAINI," ", "0")  //StrTran(cHoraIni," ", "0")
EndIf

If cCampo == "M->H6_HORAFIN" .Or. cCampo == "M->H6_HORAINI" .Or. cCampo == "M->H6_OP" .And. lRet
        If cCampo == "M->H6_HORAFIN"
                nPos:=AT(":",M->H6_HORAFIN)
            Else
                nPos:=AT(":",cHoraIni)
        EndIf
        
        If mv_par03 == 1
                If (cCampo == "M->H6_HORAFIN" .Or. cCampo == "M->H6_HORAINI") .And. (Val(Substr(cHoraIni,nPos-2,2)) > 24 .Or. Val(Substr(cHoraIni,nPos+1,2)) > 59)
                    Help(" ",1,"A680HRINVL")
                    lRet := .f.
                ElseIf (cCampo == "M->H6_HORAFIN" .Or. cCampo == "M->H6_HORAINI") .And. (Val(Substr(cHoraIni,nPos-2,2)) == 24 .And. Val(Substr(cHoraIni,nPos+1,2)) > 0)
                    Help(" ",1,"A680HRINVL")
                    lRet := .f.
                Else
                    If (cCampo == "M->H6_HORAFIN" .Or. cCampo == "M->H6_HORAINI")
                        nHora:=Val(Substr(  cHoraIni ,1,nPos-1))
                        nMinutos:=Val(Substr( cHoraIni ,nPos+1,2))
                        If nHora != 0 .And. nMinutos != 0 .And. nPos != 0
                            cHoraIni := StrZero(nHora,nPos-1)+":"+StrZero(nMinutos,2)
                        EndIf
                        nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == cCampo } )
                        If nEndereco > 0
                            aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := cHoraIni
                        EndIf
                    EndIf
                EndIf
            Else
                If (cCampo == "M->H6_HORAFIN" .Or. cCampo == "M->H6_HORAINI") .And. (Val(Substr(cHoraIni,nPos-2,2)) > 24 .Or. (Val(Substr(cHoraIni,nPos-2,2)) == 24 .And. Val(Substr(cHoraIni,nPos+1,2)) > 0))
                    Help(" ",1,"A680HRINVL")
                    lRet := .f.
                EndIf
        EndIf
        
        If (cCampo == "M->H6_HORAFIN" .Or. cCampo == "M->H6_HORAINI") .And. (!Empty(M->H6_HORAFIN) .And. M->H6_HORAFIN <= M->H6_HORAINI .And. M->H6_DATAFIN == M->H6_DATAINI .And. lRet)
            Help(" ",1,"A680Hora")
            lRet := .F.
        EndIf
        
        If lRet
            M->H6_TEMPO := A680Calc()
            nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "H6_TEMPO  " } )
            If nEndereco > 0
      
                aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := M->H6_TEMPO
      
            EndIf
        EndIf
    
    ElseIf cCampo == "M->H6_TEMPO"
        nPos:=AT(":",M->H6_TEMPO)
        If nPos == 0
            nPos:=AT(":",PesqPict("SH6","H6_TEMPO"))
        EndIf
        If mv_par03 == 1
            If Val(Substr(M->H6_TEMPO,1,nPos-1)) < 999
                If Val(Substr(M->H6_TEMPO,nPos+1,2)) >= 60
                    nHora:=Val(Substr(M->H6_TEMPO,1,nPos-1))+1
                    nMinutos:=Val(Substr(M->H6_TEMPO,nPos+1,2))-60
                   
                   
                    M->H6_TEMPO := StrZero(nHora,nPos-1)+":"+StrZero(nMinutos,2)
                    
                    nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "H6_TEMPO  " } )
                    If nEndereco > 0
                        aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := M->H6_TEMPO
                    EndIf
                EndIf
            Else
                If Val(Substr(M->H6_TEMPO,nPos+1,2)) >= 60
                    Help(" ",1,"H6_TEMPO")
                    lRet:=.F.
                EndIf
            EndIf
        EndIf
EndIf

If Val(M->H6_TEMPO)<0
	lRet:=.F.
EndIf

Return(lRet)

