#include "Protheus.ch"
#include "Topconn.ch"

User Function AGCT005()

Local bRet := .F.

Private nPosProd   := aScan(aHeader, {|x| alltrim(x[2]) == "CNE_PRODUT"})
Private cCodigo    := Alltrim(&(ReadVar()))

bRet := FiltraCnt()

Return(bRet)

Static Function FiltraCnt()
Local lHasButton := .T.
Private	oLstCNT := nil
Private oDlgCNT := nil
Private _bRet 	:= .F.
Private aDados 	:= {}
Private cCodProd:=space(tamsx3('B1_COD')[1])
Private cDescProd:=space(tamsx3('B1_DESC')[1])
Private nList   
oFont := TFont():New('Courier new',,-14,.T.)

FilCnt(cCodProd,cDescProd,.t.)

//--Montagem da Tela
Define MsDialog oDlgCNT Title "Produtos" From 0,0 To 280, 500 Of oMainWnd Pixel

  
 // Usando o método New 
oSay1:= TSay():New(05,01,{||'Codigo'},oDlgCNT,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20) 

oTGet1 := TGet():New( 005,035,{ | u | If( PCount() == 0, cCodProd, cCodProd := u ) },oDlgCNT,060,009,"@!"     ,{||FilCnt(cCodProd,cDescProd)}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCodProd",,,,lHasButton  )

oSay1:= TSay():New(05,110,{||'Desc.'},oDlgCNT,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20) 

oTGet1 := TGet():New( 005,145,{ | u | If( PCount() == 0, cDescProd, cDescProd := u ) },oDlgCNT,060,009,"@!"     ,{||FilCnt(cCodProd,cDescProd)}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cDescProd",,,,lHasButton  )
//oTGet1 := TGet():New( 005,145,{|| cDescProd},oDlgCNT,060,009,"@!",{||FilCnt(cCodProd,cDescProd)},0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,, )

@ 17,5 LISTBOX oLstCnt VAR lVarMat Fields HEADER "Cod. Produto", "Descricao" SIZE 245,97 On DblClick ( Confcnt(oLstCNT:nAt, @aDados, @_bRet) )OF oDlgCNT PIXEL

oLstCNT:SetArray(aDados)
oLstCNT:nAt := nList
oLstCNT:bLine := { || {aDados[oLstCNT:nAt,1], aDados[oLstCNT:nAt,2]}}

DEFINE SBUTTON FROM 122,5 TYPE 1 ACTION Confcnt(oLstCNT:nAt, @aDados, @_bRet) ENABLE OF oDlgCNT
DEFINE SBUTTON FROM 122,40 TYPE 2 ACTION oDlgCNT:End() ENABLE OF oDlgCNT

Activate MSDialog oDlgCNT Centered

Return _bRet

Static Function Confcnt(_nPos, aDados, _bRet)

cCodigo := aDados[_nPos,1]

_bRet := .T.


dbSelectArea('SB1')
DBSetOrder(1)
DbSeek(xFilial('SB1')+cCodigo)
oDlgCNT:End()

Return


Static Function FilCnt(cCodProd,cDescProd,lPrim)
Default lPrim := .f.
lVai:=.f.
if lPrim
	lVai:= .t.
ElseIf !Empty(cCodProd) .or. !EmptY(cDescProd)
	lVai:= .t.
	aDados:={}       
EndIf                                        
if lVai          
	
	IF !EMPTY(CN9->CN9_XCODTA)
		if emptY(M->CND_FORNEC) .or. emptY(M->CND_LJFORN)
			alert('Codigo do fornecedor nao preenchido.'+chr(13)+chr(10)+"O programa não ira filtrar a tabela de preco!")
		ENdIF
	
	Endif
	
	IF !EMPTY(CN9->CN9_XCODTA) .and. !emptY(M->CND_FORNEC) .and. !emptY(M->CND_LJFORN)		
		cSql:=" SELECT AIB_CODPRO B1_COD, B1_DESC FROM "+RetSqlName('AIA')+" AIA"+chr(13)+chr(10)
		cSql+=" INNER JOIN "+RetSqlName('AIB')+" AIB"+chr(13)+chr(10)
		cSql+=" ON AIA_FILIAL = AIB_FILIAL"+chr(13)+chr(10)
		cSql+=" AND AIA_CODFOR = AIB_CODFOR"+chr(13)+chr(10)
		cSql+=" AND AIA_LOJFOR = AIB_LOJFOR"+chr(13)+chr(10)
		cSql+=" AND AIA_CODTAB = AIB_CODTAB"+chr(13)+chr(10)
		cSql+=" INNER JOIN "+RetSqlName('SB1')+" SB1"+chr(13)+chr(10)
		cSql+=" ON B1_COD = AIB_CODPRO"+chr(13)+chr(10)
		cSql+=" WHERE AIA_FILIAL ='"+xFilial('AIA')+"'"+chr(13)+chr(10)
		cSql+=" AND AIA_CODFOR = '"+M->CND_FORNEC+"'"+chr(13)+chr(10)
		cSql+=" AND AIA_LOJFOR ='"+M->CND_LJFORN+"'"+chr(13)+chr(10)
		cSql+=" AND AIA_DATDE<='"+DTOS(DDATABASE)+"'"+chr(13)+chr(10)
		cSql+=" AND AIA_DATATE>='"+DTOS(DDATABASE)+"'"+chr(13)+chr(10)
		cSql+=" AND  AIB_CODPRO LIKE ('"+ALLTRIM(cCodProd)+"%')"
		cSql+=" AND  B1_DESC LIKE ('"+ALLTRIM(cDescProd)+"%')"
		cSql+=" AND AIA.D_E_L_E_T_<>'*' "+chr(13)+chr(10)
		cSql+=" AND AIB.D_E_L_E_T_<>'*' "+chr(13)+chr(10)
		cSql+=" AND SB1.D_E_L_E_T_<>'*'"+chr(13)+chr(10)
		//cSql+=" AND B1_MSBLQL<>'1' "
	eLSE
		cSql:=" SELECT B1_COD, B1_DESC FROM "+RetSqlName('SB1')+" SB1"+chr(13)+chr(10)
		cSql+=" WHERE B1_FILIAL ='"+XfILIAL('SB1')+"' " 
		cSql+=" and SB1.D_E_L_E_T_<>'*'"+chr(13)+chr(10)
		cSql+=" AND  B1_COD LIKE ('"+ALLTRIM(cCodProd)+"%')"
		cSql+=" AND  B1_DESC LIKE ('"+ALLTRIM(cDescProd)+"%')"
		
	EndIF
	cAlias1:= CriaTrab(Nil,.F.)
	DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cSql),cAlias1, .F., .T.)
	
	
	(cAlias1)->(DbGoTop())
	If (cAlias1)->(Eof())
		Aviso( "ATENCAO","produto nao encontrado",{"OK"})
		Return .F.
	Endif
	
	Do While (cAlias1)->(!Eof())
		
		aAdd( aDados, { (cAlias1)->B1_COD, (cAlias1)->B1_DESC } )
		
		(cAlias1)->(DbSkip())
		
	Enddo
	DbCloseArea(cAlias1)
	nList := aScan(aDados, {|x| alltrim(x[1]) == alltrim(cCodigo)})
	IF nList == 0
		nList:=1
	EndIf
	if !lPrim	
		iif(nList = 0,nList := 1,nList)
		oLstCNT:SetArray(aDados)
		oLstCNT:nAt := nList
		oLstCNT:bLine := { || {aDados[oLstCNT:nAt,1], aDados[oLstCNT:nAt,2]}}  
		oLstCNT:refresh()
	EndIF
EndIF	

Return .t.


USER FUNCTION AGCT005G

M->CN9_VLATU := M->CN9_VLINI

RETURN .T.