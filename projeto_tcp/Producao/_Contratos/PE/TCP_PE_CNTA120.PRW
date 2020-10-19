#Include 'Protheus.ch'
#Include 'TopConn.ch'



/*/{Protheus.doc} CN120PED
Descrição:
Localizado na função CN120PED, responsável por gerar Pedido de Compras ou Vendas por meio de rotina automática.
Este ponto de entrada é executado no encerramento da medição, no momento em que é gerado o Pedido de Compras, 
por meio da rotina automática MATA120 ou Pedido de Vendas, por meio da rotina automática MATA410. 
Tem por objetivo permitir o preenchimento dos campos específicos do SC7 para Pedidos de Compras ou 
SC6 para Pedidos de Vendas.
@author Hugo
@since 30/06/2017
@version 1.0

@see http://tdn.totvs.com/pages/releaseview.action?pageId=6089554
/*/
//******************************************************//


User Function CN120PED() 

Local aCab := PARAMIXB[1] 
Local aItm := PARAMIXB[2] 
Local aArea:= GetArea() 
Local Nx
Local cObs	:= AllTrim(CND->CND_OBS) //Alltrim(MSMM(CND->CND_CODOBS))

//Unico jeito de mostrar msg que não integrou com Sales, sem estornar o processo ;/
public _cErrSales := ''

For Nx:=1 to Len(aItm) 
                             
          // C7_OBS 
          If (nLin :=aScan(aItm[Nx],{|x|x[1]=="C7_OBS"}))>0 
               aItm[Nx][nLin][2] := cObs 
               aItm[Nx][nLin][3] := nil 
          Else 
               aAdd(aItm[Nx],{"C7_OBS","CONTRATO-"+cObs,nil}) 
          EndIf 
Next 

//aAdd(aCab,{"C7_OBS",cObs,nil}) 


RestArea(aArea) 



Return({aCab,aItm}) 

user function CN120ENCMD()

IF TYPE("_cErrSales") == 'C' .AND. !EMPTY(_cErrSales)
	Alert(_cErrSales)
ENDIF

return


/*/{Protheus.doc} CN120CMP
Descrição:
O ponto de entrada CN120CMP está localizado na rotina "Medição do Contrato" e tem por finalidade 
adicionar campos customizados à consulta especifica do contrato de Medição.


@author Hugo
@since 30/06/2017
@version 1.0

@see http://tdn.totvs.com/pages/releaseview.action?pageId=6089554
/*/
//******************************************************//

User Function CN120CMP()

Local ExpA1  := PARAMIXB[1]
Local ExpA2  := PARAMIXB[2]
Local aField := {}
Local bBlock :=  {|cField| IIf(FieldPos(cField) == 0, NIL, AAdd(aField, {FwSX3Util():GetDescription(cField),;
																		cField,;
																		X3PICTURE(cField),; 
																		TamSX3(cField)[1],;
																		TamSX3(cField)[2],;
																		GetSx3Cache(cField, "X3_VALID"),;
																		GetSx3Cache(cField, "X3_USADO"),;
																		FwSX3Util():GetFieldType(cField),;
																		X3F3(cField),;
																		GetSx3Cache(cField, "X3_CONTEXT"),;
																		X3CBOX(cField),;
																		GetSx3Cache(cField, "X3_RELACAO");
																		}))}
AEval({"CN9_DESCRI"}, bBlock)

AAdd(ExpA1,aField[01][01])
Aadd(ExpA2,{aField[01][02],aField[01][08],aField[01][10],aField[01][03]})

Return {ExpA1,ExpA2}



/*/{Protheus.doc} CN120QCC
Descrição:
Ponto de entrada para refazer a query 

@author Hugo
@since 30/06/2017
@version 1.0

@see http://tdn.totvs.com/pages/releaseview.action?pageId=6089554
/*/
//******************************************************//

User Function CN120QCC()

	Local aArea     := GetArea()
	Local aGrp   	:= {}
	Local aTamCab	:= {}
	Local aButtons	:= {}
	Local aCN120CMP := {}

	Local cGrps     := ""
	Local cQuery    := ""
	Local cQuery1   := ""
	Local cQuery2   := ""
	Local cQuery3   := ""
	Local cQuery4   := ""
	Local cQuery5   := ""
	Local cCod      := RetCodUsr()
	Local cQueryPE  := ""

	Local lVldVige  := GetNewPar("MV_CNFVIGE","N") == "N"
	Local lRet      := .F.

	Local nSavQual  := 0
	Local nX        := 0
	Local nOpca		:= 0
	Local nNovaOrd	:= 0
	Local oQual
	Local oDlg
	Local oSize

	PRIVATE aCab	   := {}
	PRIVATE aCampos	   := {}
	PRIVATE aArrayF4   := {}

	aGrp := UsrRetGrp(UsrRetName(cCod))

	For nX:=1 to len(aGrp)
		cGrps += "'"+aGrp[nX]+"',"
	Next
	cGrps := SubStr(cGrps,1,len(cGrps)-1)

	cQuery1 := " SELECT CN9_NUMERO, MAX(CN9_REVISA) AS CN9_REVISA , CN9_DESCRI"
//	cQuery1 += ", CN9_DESCRI "
	cQuery1 += " FROM " + RetSqlName("CN9") + " CN9 , "+ RetSqlName("CNN") + " CNN "
	cQuery1 += ", "+ RetSqlName("CPD") + " CPD "
	cQuery1 += " WHERE CN9_SITUAC   = '05' AND "
	cQuery1 += " CPD.CPD_FILAUT = '"+cFilAnt+"' AND "
	cQuery1 += " CPD.CPD_CONTRA = CN9.CN9_NUMERO AND "

	If lVldVige
		cQuery1 += " ('"+DToS(dDataBase)+"' BETWEEN CN9_DTINIC AND CN9_DTFIM )  AND "
	EndIf
	cQuery1+= " CNN.CNN_FILIAL = CN9_FILIAL AND "
	cQuery1+= " CNN.CNN_CONTRA = CN9_NUMERO AND "

	cQuery2 := " CN9_VLDCTR ='2' "
	cQuery3 := " CN9_VLDCTR IN(' ','1') AND (CNN.CNN_USRCOD   = '"+ cCod +"'"
	If len(aGrp) > 0
		cQuery3 += " OR CNN.CNN_GRPCOD IN ("+ cGrps +"))"
	Else
		cQuery3 += ")"
	EndIf

	cQuery4 := " AND CNN.D_E_L_E_T_	= '' "
	cQuery4 += " AND CN9.D_E_L_E_T_	= '' "
	cQuery4 += " AND CPD.D_E_L_E_T_	= '' "
	cQuery4 += " GROUP BY CN9_NUMERO, CN9_XFORN"

	cQuery4 += ", CN9_FILCTR "

	cQuery5 := " ORDER BY CN9_NUMERO,CN9_REVISA"

	cQuery5 += ", CN9_FILCTR "


	cQuery := cQuery1
	cQuery += cQuery2+" "+cQuery4
	cQuery += " UNION "
	cQuery += cQuery1
	cQuery += cQuery3+" "+cQuery4+" "+cQuery5
	
	//Conout(cQuery)


	RestArea(aArea)
Return(cQuery)
 /*/{Protheus.doc} CN120ENVL
Descrição:
Ponto de entrada para nao permitir encerrar a medicao sem rateio  

@author Rodrigo Slisinski
@since 07/08/2017
@version 1.0
/*/
//******************************************************//
 
 
User function CN120ENVL
lOCAL lRet:=.t.         

If Posicione('SA2',1,xFilial('SA2')+CND->CND_FORNEC+CND->CND_LJFORN,"A2_NOTAFOR") == 'C'
	Aviso('Fornecedor Bloqueado para encerramento','Este fornecedor está bloqueado por classificação C'+CHR(13)+chr(10)+;
				"Favor contatar o compras para regularizar a situação deste fornecedor e prosseguir o processo.",{"Ok"})
	return .F.
EndIf      

cQueryZ21 := " SELECT sum(Z21_VALOR) VALOR FROM "+RetSqlName('Z21')+" Z21 "
cQueryZ21 += " WHERE Z21.Z21_FILIAL = '"+xFilial('Z21')+"' AND Z21.Z21_CONTRA = '"+CND->CND_CONTRA+"' 
cQueryZ21 += "   AND Z21.Z21_NUMMED = '"+CND->CND_NUMMED+"' AND Z21.D_E_L_E_T_ != '*' "
If (Select("TMPZ21") <> 0)
	TMPZ21->(DbCloseArea())
Endif

TcQuery cQueryZ21 new alias 'TMPZ21'

if !TMPZ21->(eof())

	IF TMPZ21->VALOR==0
		Alert("Obrigatorio efetuar o rateio!")
		lRet:=U_AGCT004()
	ElseIf TMPZ21->VALOR <> CND->CND_VLTOT
		Alert("Verificar o valor do rateio!")
		lRet:=U_AGCT004()
	End
EndIF  


       	
if CND->CND_MOEDA != 1
	
	_nValTot := XMOEDA(1,CND->CND_MOEDA,1,CND->CND_DTINIC,2,0)
	
	if _nValTot <= 0 
		FwClearHLP()
		Help(NIL, NIL, "Cotação de moeda estrangeira.", NIL, "Não existe cotação atual para a moeda utilizada!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Solicite que o financeiro preencha a taxa correta."})
	   
		lRet := .F.
	endif
endif	     
	

return lRet

User Function CN120VDSD()


RETURN .T.
 
 
 
User function CN130TOK
lret:=.t.

IF CN9->CN9_INCFOR=='S'
	dbSelectArea('CNC')
	DBSetOrder(1)
	if !dbSeek(xFilial('CNC')+M->CND_CONTRA+M->CND_REVISA+M->CND_FORNEC+M->CND_LJFORN)
	     RECLOCK('CNC',.T.)
	     CNC->CNC_FILIAL := xFilial('CNC')	
	     CNC->CNC_NUMERO := M->CND_CONTRA  
	     CNC->CNC_REVISA := M->CND_REVISA
	     CNC->CNC_CODIGO := M->CND_FORNEC	
	     CNC->CNC_LOJA   := M->CND_LJFORN	
	     CNC->CNC_CODED	 := ''
	     CNC->CNC_NUMPR  := ''
	     MSUnlock()
	
	Endif
EndIF	
Return lret
 
 
User Function ALTFRN()
cRet:=M->CND_XFORNF
                   
M->CND_FORNEC := M->CND_XFORNF 
M->CND_LJFORN := M->CND_XLJNF 


return cRet  
 
 
 
User Function MD130GRV

nOp:=paramixb[1]
 
if nOp == 5
	cQueryZ21 := " update "+RetSqlName('Z21')+" set D_E_L_E_T_='*'"
	cQueryZ21 += " WHERE Z21_FILIAL = '"+xFilial('Z21')+"' AND Z21_CONTRA = '"+CND->CND_CONTRA+"' " 
	cQueryZ21 += "   AND Z21_NUMMED = '"+CND->CND_NUMMED+"' AND D_E_L_E_T_ != '*' " 
	TCSqlExec(cQueryZ21)
EndIF


Return
 
