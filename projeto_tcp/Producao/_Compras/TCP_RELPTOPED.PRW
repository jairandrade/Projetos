#INCLUDE "totvs.ch"

/*/{Protheus.doc} RELPTOPD
    TRELATORIO PONTO DE PEDIDO CUUSTOMIZADO
    @type  Function
    @author Eduardo Vieira
    @since 27/09/18
    @version 1.0
    @return Nil
/*/
User function RELPTOPD()

local oReport
local cPerg  := "TCPSTPE6"
local cAlias := getNextAlias()

private oSection1  

criaSx1(cPerg)
Pergunte(cPerg, .F.)

oReport := reportDef(cAlias, cPerg)

oReport:PrintDialog()

return

/*/{Protheus.doc} ReportDef
    Funcao para criação da estrutura do relatorio
    @type  Function
/*/
Static Function ReportDef(cAlias,cPerg)

local cTitle  := "Relatório de análise de estoque"
local cHelp   := "Permite gerar relatorio das movimentações e quantidades de estoque dos produtos de um determinado período."
local oReport

oReport	:= TReport():New("RELPTOPD",cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

//oReport:oPage:SetPaperSize(3) // seleciona Impressao papel A4  
//oReport:SetPortrait(.T.)
//oReport:SetTotalInLine(.F.)  

//Primeira seção
oSection1 := TRSection():New(oReport,"teste1231",{"ZP9"},, /*Campos do SX3*/, /*Campos do SIX*/)
//oSection1:SetLineStyle()
//oSection1:SetTotalInLine(.F.)
Return(oReport)

/*/{Protheus.doc} ReportPrint
    Rotina para montagem dos dados do relatorio.
    @type  Function
    /*/
Static Function ReportPrint(oReport,cAlias)
Local cMesFech := substr(DTOS(GETMV('MV_ULMES')),1,6)   
Local cWhere :=  '%'
Local cWhere2 :=  '%'
Local cPerAtu := ''
Local cAnos   := ''
lOCAL aAnos := {}
Local nI
//TRPosition():New(oSection1,"ZP9",1,{ || xFilial("ZP9") + (cAlias)->ZP9_PRODUT })

TRCell():New(oSection1,"ZP9_PRODUT", "ZP9", "Produto","",20,,,,,"")
TRCell():New(oSection1,"B1_DESC", "ZP9", "Descrição","",20,,,,,"")
//TRCell():New(oSection1,"201908", "ZP9", "201908",X3PICTURE("ZP9_QTDSAI"),20,,,,,"")

TRCell():New(oSection1,"ULTIMA_ENT", "TRBPTO", "Dt. Ult. Entrada",X3PICTURE("ZP9_DTENT"),20,,,,,"")
TRCell():New(oSection1,"ULTIMA_SAI", "TRBPTO", "Dt. Ult. Movimentação",X3PICTURE("ZP9_DTSAI"),20,,,,,"")
TRCell():New(oSection1,"SEMMOV", "TRBPTO", "Slow Mov",,20,,,,,"")
TRCell():New(oSection1,"SUMSAI", "TRBPTO", "Consumo Período","",20,,,,,"")
TRCell():New(oSection1,"MEDIA_MES", "TRBPTO", "Média Consumo Mensal","",20,,,,,"")
//TRCell():New(oSection1,"MEDIA_DIA", "TRBPTO", "Média Consumo Diário","",20,,,,,"")
TRCell():New(oSection1,"MEDRES", "TRBPTO", "Média Tempo Entrega Mensal","",20,,,,,"")
TRCell():New(oSection1,"MEDRESSLA", "TRBPTO", "Média Tempo Entrega Mensal + SLA","",20,,,,,"")
//TRCell():New(oSection1,"MEDRESDIA", "TRBPTO", "Média Tempo Entrega Diário","",20,,,,,"")
TRCell():New(oSection1,"SALDO", "TRBPTO", "Saldo Atual","",20,,,,,"")
TRCell():New(oSection1,"B1_ESTSEG", "TRBPTO", "Estoque Mínimo Atual","",20,,,,,"")
TRCell():New(oSection1,"EST_MIN", "TRBPTO", "Estoque Mínimo Sugerido","",20,,,,,"")
TRCell():New(oSection1,"B1_EMIN", "TRBPTO", "Ponto de Pedido Atual","",20,,,,,"")
TRCell():New(oSection1,"SUGER_PTO", "TRBPTO", "Ponto de Pedido Sugerido","",20,,,,,"")
TRCell():New(oSection1,"CSTUNIT", "TRBPTO", "Custo Unitário","",20,,,,,"")
TRCell():New(oSection1,"CUSTOEST", "TRBPTO", "Custo Prod. Estoque","",20,,,,,"")
TRCell():New(oSection1,"B1_ZITEMZ", "TRBPTO", "Criticidade","",20,,,,,"")
TRCell():New(oSection1,"B1_LE", "TRBPTO", "Lote Econômico","",20,,,,,"")
TRCell():New(oSection1,"B1_EMAX", "TRBPTO", "Estoque Máximo","",20,,,,,"")
TRCell():New(oSection1,"B1_MSBLQL", "TRBPTO", "Bloqueado","",20,,,,,"")
TRCell():New(oSection1,"B2_LOCAL", "TRBPTO", "Armazém","",20,,,,,"")

cPerAtu := substr(mv_par01,3,4)+substr(mv_par01,1,2)

iF(EMPTY(mv_par01))
	alert('Preencha o período inicial!')
	return
elseif SUBSTR(mv_par01,3,4) < '2010'
	alert('Período inicial inválido. Máscara correta: AAAAMM!')
	return
else
	
	while cPerAtu <= cMesFech
		
		_mesAtu := SUBSTR(cPerAtu,5,2)+'/'+SUBSTR(cPerAtu,1,4)
		
		TRCell():New(oSection1,cPerAtu, "ZP9", _mesAtu,X3PICTURE("ZP9_QTDSAI"),20,,,,,"")
		
		if !empty(cAnos)
			cAnos += ','
		endif
		
		cAnos += "["+cPerAtu+"]"
		aadd(aAnos,cPerAtu)
		_cMes := substr(cPerAtu,5,2)
		_cAno := substr(cPerAtu,1,4)
		
		if(VAL(_cMes)+ 1 >= 13)
			cPerAtu := 	ALLTRIM(STR(VAL(_cAno)+1))+'01'
		else
			cPerAtu := 	_cAno+PADL(ALLTRIM(STR(VAL(_cMes)+1)),2,'0')
		endif
	enddo
	
	//ultimo mes do loop
	if !empty(cAnos)
		cAnos += ','
	endif
	cAnos += "["+cPerAtu+"]"
ENDIF

cPerAtu := substr(mv_par01,3,4)+substr(mv_par01,1,2)

IF(!EMPTY(mv_par02) .AND. mv_par02 == 1)
	cWhere += " AND B1_MSBLQL != '1' "
ENDIF

cWhere += " AND REPLACE(B1_COD,'`','') BETWEEN '"+mv_par03+"' AND " + "'"+mv_par04+"'"

IF(!EMPTY(mv_par05))
	cWhere += " AND B1_GRUPO >= '"+mv_par05+"'"
ENDIF
IF(!EMPTY(mv_par06))
	cWhere += " AND B1_GRUPO <= '"+mv_par06+"'"
ENDIF

IF(!EMPTY(mv_par07) .AND. mv_par07 == 2)
	cWhere2 += " AND B2_QATU > 0 "
ENDIF

IF(!EMPTY(mv_par08))
	cWhere2 += " AND B2_LOCAL = '"+mv_par08+"' "
ENDIF


cWhere2 += '%'
cWhere += '%'
cAnos := '%'+cAnos+'%'

oReport:Section(1):BeginQuery()

//Eu vi que ficou tudo marcado como erro, é terrível de ler, mas a ide que não entendeu q isso funciona
BeginSQL Alias cAlias	

 column ZP9_DTSAI as date
 
 SELECT PIVOTZP9.*, ZP92.ZP9_PRODUT,ZP92.ZP9_DTREF,B1_DESC,ZP92.ZP9_DTENT,ZP92.ZP9_DTSAI,B1_UM,
  ZP92.ZP9_QTDSAI,ZP92.ZP9_MEDCON,ZP92.ZP9_MEDRES ,ZP92.ZP9_SALDO,B1_EMIN,B1_MSBLQL,B2_CM1 AS CSTUNIT,B1_LE,B1_ZITEMZ, ZP9_PPEDI + B1_LE AS EMAX,B2_LOCAL,
  B2_QATU as SALDO,round(CAST(B2_VATU1 as numeric (36,2)),2) AS CUSTOEST,SUMSAI,ZP9_PPEDI,B1_ESTSEG,B1_EMAX,
 ( CASE COUNT_SAI WHEN 0 THEN 0 ELSE SUMSAI/ COUNT_SAI END) AS MEDIA_MES, 
 ( CASE COUNT_SAI WHEN 0 THEN 0 ELSE (SUMSAI/ COUNT_SAI) / 30 END) AS MEDIA_DIA, 
 ( CASE COUNT_ENT WHEN 0 THEN 0 ELSE SOMMEDRES / COUNT_ENT END) AS MEDRES, 
 ( CASE COUNT_ENT WHEN 0 THEN 0 ELSE (SOMMEDRES/ COUNT_ENT)+4 END) AS MEDRESSLA, 
 ( CASE COUNT_ENT WHEN 0 THEN 0 ELSE  ((SOMMEDRES/ COUNT_ENT)+4) / 30 END) AS MEDRESDIA, 
   
  ((( CASE COUNT_SAI WHEN 0 THEN 0 ELSE SUMSAI/ COUNT_SAI END)) * ( ( CASE COUNT_ENT WHEN 0 THEN 0 ELSE  ((SOMMEDRES/ COUNT_ENT)+4) END) / 30)) AS EST_MIN,
   ((( CASE COUNT_SAI WHEN 0 THEN 0 ELSE SUMSAI/ COUNT_SAI END)) * (( CASE COUNT_ENT WHEN 0 THEN 0 ELSE  ((SOMMEDRES/ COUNT_ENT)+4) END) / 30)) * 2.3 as SUGER_PTO,
   
 ISNULL((SELECT MIN(SD3.D3_EMISSAO) 
 			FROM %Table:SD3% SD3 
			WHERE D3_COD = ZP92.ZP9_PRODUT 
			AND SD3.D_E_L_E_T_ = ' ' 
			AND D3_EMISSAO>='20110101' 
			AND D3_TM = '499'  ),'') PRIM_ENT,
 ISNULL((SELECT MAX(SD3.D3_EMISSAO) 
 			FROM %Table:SD3% SD3 
			 WHERE D3_COD = ZP92.ZP9_PRODUT 
			 AND SD3.D_E_L_E_T_ = ' ' 
			 AND D3_EMISSAO>='20110101' 
			 AND  (D3_TM = '500' 
			 AND D3_CF = 'PR0' ) ),'') ULT_PROD,
 ISNULL((SELECT MAX(SD3.D3_EMISSAO) 
 			FROM %Table:SD3% SD3 
			WHERE D3_COD = ZP92.ZP9_PRODUT 
			AND SD3.D_E_L_E_T_ = ' ' 
			AND D3_EMISSAO>='20110101' 
			AND D3_TM > '499' 
			AND D3_TM < '999' ),'') ULTIMA_SAI,
 ISNULL((SELECT MAX(SD1.D1_EMISSAO) 
 			FROM %Table:SD1% SD1 
			WHERE D1_COD = ZP92.ZP9_PRODUT 
			AND SD1.D_E_L_E_T_ = ' ' 
			AND D1_EMISSAO>='20090101' ),'') ULTIMA_NOTA

	FROM (
	 SELECT ZP9_PRODUT, %EXP:cAnos%
	 FROM
	 (SELECT ZP9_DTREF, ZP9_QTDSAI,ZP9_PRODUT 
		FROM %Table:ZP9% ZP 
		INNER JOIN %Table:SB1%  SB11 
			ON ZP.ZP9_PRODUT = SB11.B1_COD 
			AND SB11.D_E_L_E_T_ != '*' 
		WHERE ZP.D_E_L_E_T_ != '*' %EXP:cWhere% ) AS ZP9
		PIVOT  ( 
		MAX(ZP9.ZP9_QTDSAI)
		 FOR ZP9.ZP9_DTREF IN (%EXP:cAnos%)
		) AS PivotTable )  AS PIVOTZP9
		INNER JOIN %Table:ZP9% ZP92 
		ON PIVOTZP9.ZP9_PRODUT = ZP92.ZP9_PRODUT 
		AND ZP92.ZP9_DTREF = %EXP:cMesFech%
		INNER JOIN (
				SELECT ZP9_PRODUT,
						SUM(ZP9_MEDCON) as SUMMEDCON,SUM(ZP9_QTDSAI) AS SUMSAI,SUM(ZP9_MEDRES) AS SOMMEDRES ,
						sum(CASE ZP9_QTDSAI WHEN 0 THEN 0 ELSE 1 END) COUNT_SAI,
						sum(CASE ZP9_MEDRES WHEN 0 THEN 0 ELSE 1 END) COUNT_ENT
				 FROM %Table:ZP9% ZP93 
				WHERE ZP9_DTREF >= %EXP:cPerAtu% 
				GROUP BY ZP9_PRODUT
				)  AS ZP94 ON ZP94.ZP9_PRODUT= PIVOTZP9.ZP9_PRODUT
	INNER JOIN %Table:SB1%  SB1 
		ON PIVOTZP9.ZP9_PRODUT = B1_COD 
		AND SB1.D_E_L_E_T_ != '*'
	LEFT JOIN %Table:SB2%  SB2 
		ON PIVOTZP9.ZP9_PRODUT = B2_COD 
		AND SB2.D_E_L_E_T_ != '*'
	WHERE ZP92.D_E_L_E_T_ != '*'  
	AND 1=1 %EXP:cWhere% 
	AND 1=1 %EXP:cWhere2%
	ORDER BY B1_COD
	
EndSQL 

//MemoWrite("C:\Temp\tcp_order_point.txt",getlastquery()[2])

oReport:Section(1):EndQuery()
oReport:SetMeter((cAlias)->(RecCount()))
(cAlias)->(dbGoTop())

IF (cAlias)->(!Eof())
	oReport:Section(1):Init()  
	While (cAlias)->(!Eof())  
		
	    If oReport:Cancel()
			Exit
		EndIf
	
		oReport:IncMeter()
		oReport:Section(1):Cell("B1_MSBLQL"):SetValue(IF((cAlias)->B1_MSBLQL=='1','SIM','NÃO')) 
		IF(!empty((cAlias)->ULTIMA_NOTA))
			_dUltEnt := (cAlias)->ULTIMA_NOTA
		ELSEIF(!EMPTY((cAlias)->ULT_PROD))
			_dUltEnt := (cAlias)->ULT_PROD
		ELSE
			_dUltEnt := (cAlias)->PRIM_ENT
		ENDIF
		
		oReport:Section(1):Cell("ULTIMA_ENT"):SetValue(STOD(_dUltEnt)) 
		oReport:Section(1):Cell("ULTIMA_SAI"):SetValue(STOD((cAlias)->ULTIMA_SAI)) 
		_nDifDays := 'SEM MOVIMENTAÇÃO'
		
		if(!EMPTY((cAlias)->ULTIMA_SAI))
			_nDifDays := DateDiffDay(STOD((cAlias)->ULTIMA_SAI),DATE())
		elseif(!EMPTY(_dUltEnt))
			_nDifDays := DateDiffDay(STOD(_dUltEnt),DATE())
		endif
		
		oReport:Section(1):Cell("SEMMOV"):SetValue( _nDifDays ) 
	
		For nI := 1 to (cAlias)->(FCount())
			If (nPos := aScan(aAnos,{|x| Alltrim(x) == Alltrim((cAlias)->(Field(nI))) })) > 0
		        oReport:Section(1):Cell(aAnos[nPos]):SetValue((cAlias)->(FieldGet(nI)))
		    EndIf
	    Next nI
	    
	    nPP_Sugerido := (cAlias)->SUGER_PTO
	    if (cAlias)->B1_UM = 'UN'
	        nPP_Aux := (cAlias)->SUGER_PTO
	        nPP_Sugerido := round((cAlias)->SUGER_PTO, 0)
	        if nPP_Aux > nPP_Sugerido
	            nPP_Sugerido += 1
	        endif
	    else
	        nPP_Sugerido := round(nPP_Sugerido, 2)
	    endif
	    
	    oReport:Section(1):Cell("SUGER_PTO"):SetValue(nPP_Sugerido) 
	    
	    oReport:Section(1):Printline()
	    
	    (cAlias)->(dbSkip())
	
	EndDo 
ELSE
	ALERT('Nenhum registro encontrado!')
ENDIF
(cAlias)->(dbCloseArea()) 

oReport:Section(1):Finish() 
	
return

/*/{Protheus.doc} criaSX1
    Funcao para criacao das perguntas (se nao existirem) 
    @type  Function
/*/
Static function criaSX1(cPerg)
Local aRegs := {}

	aAdd(aRegs,{cPerg, "01", "Ano de"	   , "Ano de"     ,"Ano de"	  , "mv_ch1", "C", 7, 0, 0, "G", "", "mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","","","@R 99/9999"})
	aAdd(aRegs,{cPerg, "02","Prod. Bloqueados?"	 	   ,"Prod. Bloqueados?"      ,"Prod. Bloqueados?"	     ,"mv_ch02","C",1,0,1,"C","","mv_par02","Não","Não",'Não',"1"  ,"mv_par02","Sim","Sim","Sim","","","","","","","","","","","","","","","","","","","",""})
	
	aAdd(aRegs,{cPerg, "03", "Produto de"  , "Produto de"  ,"Produto de"  , "mv_ch3", "C", 15, 0, 0, "G", "", "mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","SB1","","",""})
	aAdd(aRegs,{cPerg, "04", "Produto ate" , "Produto ate" ,"Produto ate" , "mv_ch4", "C", 15, 0, 0, "G", "", "mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","SB1","","",""})
	aAdd(aRegs,{cPerg, "05", "Grupo de"  , "Grupo de"  ,"Grupo de"  , "mv_ch5", "C", 4, 0, 0, "G", "", "mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","SBM","","",""})
	aAdd(aRegs,{cPerg, "06", "Grupo ate" , "Grupo ate" ,"Grupo ate" , "mv_ch6", "C", 4, 0, 0, "G", "", "mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","SBM","","",""})
	aAdd(aRegs,{cPerg, "07","Apenas com Saldo?"	 	   ,"Apenas com Saldo?"      ,"Apenas com Saldo?"	     ,"mv_ch07","C",1,0,1,"C","","mv_par07","Não","Não",'Não',"1"  ,"mv_par07","Sim","Sim","Sim","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "08", "Armazém" , "Armazém" ,"Armazém" , "mv_ch8", "C", 2, 0, 0, "G", "", "mv_par08","","","",""  ,"","","","","","","","","","","","","","","","","","","","","NNR","","",""})
	
	U_BuscaPerg(aRegs)
return
