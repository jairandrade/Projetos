#INCLUDE "rwmake.ch"
#INCLUDE "AVPRINT.CH"
*----------------------------------------------------------------------------------------
User Function KpFatR01()
* Ricardo Luiz da Rocha 31/10/2011 GNSJC
*----------------------------------------------------------------------------------------
_cPerg:='FatR01'
ValidPerg(_cPerg)

if !Pergunte(_cPerg,.t.)
	return
endif

cursorwait()
oFont06  := TFont():New( "Arial",,06,,.F.,,,,,.F. )
oFont06B := TFont():New( "Arial",,06,,.T.,,,,,.F. )
oFont07  := TFont():New( "Arial",,07,,.F.,,,,,.F. )
oFont07B := TFont():New( "Arial",,07,,.T.,,,,,.F. )
oFont08  := TFont():New( "Arial",,08,,.F.,,,,,.F. )
oFont08B := TFont():New( "Arial",,08,,.T.,,,,,.F. )
oFont09  := TFont():New( "Arial",,09,,.F.,,,,,.F. )
oFont09B := TFont():New( "Arial",,09,,.T.,,,,,.F. )
oFont10  := TFont():New( "Arial",,10,,.F.,,,,,.F. )
oFont10B := TFont():New( "Arial",,10,,.T.,,,,,.F. )
oFont11  := TFont():New( "Arial",,11,,.F.,,,,,.F. )
oFont11B := TFont():New( "Arial",,11,,.T.,,,,,.F. )
oFont12  := TFont():New( "Arial",,12,,.F.,,,,,.F. )
oFont12B := TFont():New( "Arial",,12,,.T.,,,,,.F. )
oFont13  := TFont():New( "Arial",,13,,.F.,,,,,.F. )
oFont13B := TFont():New( "Arial",,13,,.T.,,,,,.F. )
oFont14  := TFont():New( "Arial",,14,,.F.,,,,,.F. )
oFont14B := TFont():New( "Arial",,14,,.T.,,,,,.F. )
oFont15  := TFont():New( "Arial",,15,,.F.,,,,,.F. )
oFont15B := TFont():New( "Arial",,15,,.T.,,,,,.F. )
oFont16  := TFont():New( "Arial",,16,,.F.,,,,,.F. )
oFont16B := TFont():New( "Arial",,16,,.T.,,,,,.F. )
oFont17  := TFont():New( "Arial",,17,,.F.,,,,,.F. )
oFont17B := TFont():New( "Arial",,17,,.T.,,,,,.F. )
oFont18  := TFont():New( "Arial",,18,,.F.,,,,,.F. )
oFont18B := TFont():New( "Arial",,18,,.T.,,,,,.F. )
oFont19  := TFont():New( "Arial",,19,,.F.,,,,,.F. )
oFont19B := TFont():New( "Arial",,19,,.T.,,,,,.F. )
oFont20  := TFont():New( "Arial",,20,,.F.,,,,,.F. )
oFont20B := TFont():New( "Arial",,20,,.T.,,,,,.F. )
oFont21  := TFont():New( "Arial",,21,,.F.,,,,,.F. )
oFont21B := TFont():New( "Arial",,21,,.T.,,,,,.F. )
oFont22  := TFont():New( "Arial",,22,,.F.,,,,,.F. )
oFont22B := TFont():New( "Arial",,22,,.T.,,,,,.F. )
oFont23  := TFont():New( "Arial",,23,,.F.,,,,,.F. )
oFont23B := TFont():New( "Arial",,23,,.T.,,,,,.F. )
oFont24  := TFont():New( "Arial",,24,,.F.,,,,,.F. )
oFont24B := TFont():New( "Arial",,24,,.T.,,,,,.F. )
oFont25  := TFont():New( "Arial",,25,,.F.,,,,,.F. )
oFont25B := TFont():New( "Arial",,25,,.T.,,,,,.F. )
oFont26  := TFont():New( "Arial",,26,,.F.,,,,,.F. )
oFont26B := TFont():New( "Arial",,26,,.T.,,,,,.F. )
oFont27  := TFont():New( "Arial",,27,,.F.,,,,,.F. )
oFont27B := TFont():New( "Arial",,27,,.T.,,,,,.F. )
oFont28  := TFont():New( "Arial",,28,,.F.,,,,,.F. )
oFont28B := TFont():New( "Arial",,28,,.T.,,,,,.F. )
oFont29  := TFont():New( "Arial",,29,,.F.,,,,,.F. )
oFont29B := TFont():New( "Arial",,29,,.T.,,,,,.F. )
oFont30  := TFont():New( "Arial",,30,,.F.,,,,,.F. )
oFont30B := TFont():New( "Arial",,30,,.T.,,,,,.F. )

nPag:=0

_cNotaIni:=mv_par01 // Nf Inicial
_cNotaFim:=mv_par02 // Nf Final
_cSeriIni:=mv_par03 // Serie Inicial
_cSeriFim:=mv_par04 // Serie Final
_dDataIni:=mv_par05 // Data de
_dDataFim:=mv_par06 // Data fim
_lVisual :=(mv_par07==1) // Visualiza impressão 1=Sim;2=Nao
_lConfig :=(mv_par08==1) // Configurar impressora 1=Sim;2=Nao
_nSaida:=mv_par09 // 1=Zebra Lpt1;2=Zebra Lpt3;3=Windows
_cPorta:=''
if _nSaida==1
	_cPorta:='LPT1'
elseif _nSaida==2
	_cPorta:='LPT3'
endif

_nVelocid:=mv_par10 // Velocidade de impressao:  1-Lenta;3-Media I;6-Media II;9-Media III;12-Rapida
if _nVelocid==2
	_nVelocid:=3
elseif _nVelocid==3
	_nVelocid:=6
elseif _nVelocid==4
	_nVelocid:=9
elseif _nVelocid==5
	_nVelocid:=12
endif

_cModelo:="TLP 2844"

sf2->(dbsetorder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

_cSql:="select * from "+RetSqlName("SF2")+" SF2"
_cSql+=" where F2_FILIAL='"+xfilial("SF2")+"'"
_cSql+=" and F2_SERIE between '"+_cSeriIni+"' and '"+_cSeriFim+"'"
_cSql+=" and F2_DOC between '"+_cNotaIni+"' and '"+_cNotaFim+"'"
_cSql+=" and F2_EMISSAO between '"+Dtos(_dDataIni)+"' and '"+dtos(_dDataFim)+"'"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSql),"FATR01",.T.,.F.)
TcSetField(Alias(),"D2_EMISSAO","D")

_nImp:=0

_nEspLin:=75
FatR01->(dbgotop())


oprn:=TMSPrinter():New()

if _lConfig//.and._nImp==1
	oPrn:Setup()
	
endif
cursorwait()
do while FatR01->(!eof())
	
	sa1->(dbseek(xfilial()+FatR01->(f2_cliente+f2_loja),.f.))

	if sf2->f2_xetiq==0
	    _nVias:=sf2->f2_volume1
	else    
		_nVias:=sf2->f2_xetiq
	endif

	_nVias:=max(1,_nVias)
	
	for _nVezVias:=1 to _nVias
		_nImp++
		
		if _nSaida<=2 // Zebra Lpt
			MSCBPRINTER(_cModelo,_cPorta,,,.f.,,,,)
			_lRet:=MSCBCHKSTATUS(.f.)
			MSCBBEGIN(1,_nVelocid)
			
		else // Via windows
			
			/*
			if _lConfig.and._nImp==1
			oPrn:Setup()
			cursorwait()
			endif
			*/
			
			oprn:StartPage()
		endif
		
		_nPosHor:=0
		_nPosVer:=10
		_cDet:="Nota fiscal   "+FatR01->(f2_doc+" / "+f2_serie)
		
		if _nSaida<=2
			_cTamanho:="020,020"
			_nAltLin:=8
			mscbsay(_nCol:=5,_nLin:=10,_cDet,"N","A",_cTamanho)
			_nLin+=_nAltLin
			
		else
			oprn:say(_nPosHor,_nPosVer,_cDet,ofont20B,100)
			_nPosHor+=(_nEspLin*1.3)
		endif
		
		_cDet:=left(sa1->a1_nome,30)
		
		if _nSaida<=2
			mscbsay(_nCol,_nLin,_cDet,"N","B",_cTamanho)
			_nLin+=_nAltLin
		else
			oprn:say(_nPosHor,_nPosVer,_cDet,ofont17B,100)
			_nPosHor+=(_nEspLin*1.3)
		endif
		
		// Hipotese de colher o endereço de faturamento
		_vEnd:={}
		_nLarg:=35
		if sa1->A1_XENDETQ=='2' // Colher o endereço em A1_MSGPED
			_cEndCompleto:=sa1->(alltrim(a1_msgped))
			
			for _nVezLin:=1 to mlcount(_cEndCompleto,_nLarg)
				_cAdd:=alltrim(memoline(_cEndCompleto,_nLarg,_nVezLin))
				if !empty(_cAdd)
					aadd(_vEnd,_cAdd)
				endif
				if len(_vEnd)>=4
					exit
				endif
			next
			
		else // Endereço de faturamento (padrão)
			
			_cLinha:=alltrim(sa1->a1_end)
			if !empty(sa1->a1_bairro)
				_cLinha+=" - "+alltrim(sa1->a1_bairro)
			endif
			
			if len(alltrim(_cLinha))>0
				for _nVezLin:=1 to mlcount(_cLinha,_nLarg)
					_cAdd:=alltrim(memoline(_cLinha,_nLarg,_nVezLin))
					if !empty(_cAdd)
						aadd(_vEnd,_cAdd)
					endif
					
					if _nVezLin==2
						exit
					endif
					
				next
				
			endif
			
			if !empty(sa1->a1_mun)
				sa1->(aadd(_vEnd,alltrim(a1_mun)+" - "+a1_est))
			endif
			
			sa1->(aadd(_vEnd,"CEP  "+tran(a1_cep,"@r 99999-999")))
		endif
		
		for _nVezEnd:=1 to len(_vEnd)
			_cDet:=_vEnd[_nVezEnd]
			if _nSaida<=2
				mscbsay(_nCol,_nLin,_cDet,"N","B",_cTamanho)
				_nLin+=_nAltLin
			else
				FatR01->(oprn:say(_nPosHor,_nPosVer,_cDet,ofont15B,100))
				_nPosHor+=_nEspLin
			endif
		next
		
		if _nSaida<=2
			
		else
			oPrn:EndPage()
			// oPrn:Print()
		endif
		
	next
	FatR01->(dbskip(1))
	
enddo

FatR01->(dbclosearea())

if _nImp>0
	if _nSaida==3
		if _lVisual // vizualizar impressão
			oPrn:Preview()
		else
			oPrn:Print()
		endif
	endif
endif
cursorarrow()
msgbox("Concluido")

Return

*----------------------------------------------------------------------------------
Static Function VALIDPERG(_cPerg)
*----------------------------------------------------------------------------------
local aRegs:={}

aadd(aRegs,{_cPerg,"01","Nota fiscal de               :","mv_ch1","C",09,0,0,"G","","mv_par01","","      ","","","","","","","","","","","","",""})
aadd(aRegs,{_cPerg,"02","Nota fiscal ate              :","mv_ch2","C",09,0,0,"G","","mv_par02","","      ","","","","","","","","","","","","",""})
aadd(aRegs,{_cPerg,"03","Serie de                     :","mv_ch3","C",03,0,0,"G","","mv_par03","","      ","","","","","","","","","","","","",""})
aadd(aRegs,{_cPerg,"04","Serie ate                    :","mv_ch4","C",03,0,0,"G","","mv_par04","","      ","","","","","","","","","","","","",""})
aadd(aRegs,{_cPerg,"05","Data  de                     :","mv_ch5","D",08,0,0,"G","","mv_par05","","      ","","","","","","","","","","","","",""})
aadd(aRegs,{_cPerg,"06","Data ate                     :","mv_ch6","D",08,0,0,"G","","mv_par06","","      ","","","","","","","","","","","","",""})
AADD(aRegs,{_cPerg,"07","Visualizar impressao         :","mv_ch7","N",01,0,0,"C","","mv_par07","Sim","","","Nao"," ","","","","","","","","","",""})
AADD(aRegs,{_cPerg,"08","Configurar impressora        :","mv_ch8","N",01,0,0,"C","","mv_par08","Sim","","","Nao"," ","","","","","","","","","",""})
AADD(aRegs,{_cPerg,"09","Tipo de saida                :","mv_ch9","N",01,0,0,"C","","mv_par09","Zebra Lpt1","","","Zebra Lpt3"," ","","Spool Windows","","","","","","","",""})
aadd(aRegs,{_cPerg,"10","Velocidade de impressao      :","mv_chA","N",01,0,0,"C","","mv_par10","1 Lenta","","","3 Media I"," ","","6 Media II","","9 Media III","","","12 Rapida","","",""})

u__fAtuSx1(padr(_cPerg,len(sx1->x1_grupo)),aRegs)

Return
