#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} KAPAZI_AFIN002.PRW
Exemplo de montagem da modelo e interface de marcacao para uma
tabela em MVC

@author Rodrigo Slisinski
@since 22/12/2015
@version P11
/*/
//-------------------------------------------------------------------
//revisado -- 14.03.2017 -- Andre/Rsac    
//realizado validação do layout 26.06.2017 -- Andre/Rsac 
//Realizado validação -- 17/05/2017 -- Andre/Rsac
User Function AFIN002()
Private oMark
Private cPerg:="AFIN002"
CRIASX1(cPerg)
PERGUNTE(cPerg,.f.)
SETKEY(VK_F12,{|| PERGUNTE(cPerg,.t.)})
oMark := FWMarkBrowse():New()
oMark:SetAlias('SEF')
oMark:SetDescription('Seleção de Cheques')
oMark:SetFieldMark( 'EF_OK' )
oMark:bAllMark := { || marcall() }
oMark:AddButton("Gerar Arquivo", "U_afin002a")
oMark:AddFilter( "Clientes","EF_CLIENTE<>'' .AND. EF_FORNECE==''", .t.,.t.)
//oMark:AddLegend( "ZA0_TIPO=='C'", "YELLOW", "Autor"  )
//oMark:AddLegend( "ZA0_TIPO=='I'", "BLUE"  , "Interprete"  )
oMark:Activate()

Return



//-------------------------------------------------------------------
User Function AFIN002A()
Private lAbort

Processa({||AFIN002C()} ,"Buscando Cheques","Aguarde...",lAbort)
Return
//-------------------------------------------------------------------
Static Function AFIN002C
//Posiciona nos bancos
dbSelectArea('SA6')
DBSetOrder(1)
IF !dbSeek(xFilial('SA6')+MV_PAR01+MV_PAR02+MV_PAR03)
	alert("banco nao cadastrado")
	return
EndIF
dbSelectArea('SEE')
DBSetOrder(1)
if !dbSeek(xFilial('SEE')+MV_PAR01+MV_PAR02+PADR(ALLTRIM(MV_PAR03),10)+MV_PAR04 )
	alert('Cadastrar parametro de banco')
	return
EndIF
cNume:=SEE->EE_ULTDSK
reclock('SEE',.F.)
SEE->EE_ULTDSK:=soma1(iif(empty(cNume),'000001',cNume))
MSUnlock()

ProcRegua(0)
nCont	:=0
//Cabecalho arquivo
cArq:="001" //Banco
cArq+="0000"
cArq+="0"
cArq+=space(9)
cArq+="2"
cArq+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")
cArq+="650281324" //ALLTRIM(SEE->EE_CODEMP),20,"0")// 9 -- andre/rsac 30/03/2017  PADL(ALLTRIM(SEE->EE_CODEMP),20,"0")
cArq+=SPACE(11)
If Empty(SA6->A6_DVAGE)
	cArq+=PADL(ALLTRIM(SA6->A6_AGENCIA),6,"0")
Else
	cArq+=PADL(ALLTRIM(SA6->A6_AGENCIA),5,"0")
	cArq+=PADL(ALLTRIM(SA6->A6_DVAGE),1," ")  
EndIF
If Empty(SA6->A6_DVCTA)
	cArq+=PADL(ALLTRIM(SUBSTR(SA6->A6_NUMCON,1,6)),13,"0") //PADL(ALLTRIM(SA6->A6_NUMCON),13,"0")
Else
	cArq+=PADL(ALLTRIM(SA6->A6_NUMCON),12,"0")
	cArq+=PADL(ALLTRIM(SA6->A6_DVCTA),1," ")    
EndIF
cArq+=SPACE(1)
cArq+=PADR(ALLTRIM(SM0->M0_NOMECOM),30)
cArq+=PADR(ALLTRIM(""),30)
cArq+=SPACE(10)
cArq+="1"                  //AAAAMMDD
cArq+=SUBSTR(DTOS(DDATABASE),7,2)+SUBSTR(DTOS(DDATABASE),5,2)+SUBSTR(DTOS(DDATABASE),1,4)
cArq+=STRTRAN(TIME(),":","")
cArq+=STRZERO(val(SEE->EE_ULTDSK),6)
cArq+="030"
cArq+="00000" //PADR(ALLTRIM("BPI"),5)  26/08/2016
cArq+=SPACE(20)
cArq+=SPACE(20)
cArq+=SPACE(19)
cArq+=SPACE(2)
cArq+=SPACE(8)+CHR(13)+CHR(10)

cArq+= '001'
cArq+= '0001'
cArq+= '1'
cArq+= 'R'
cArq+= '07'
cArq+= '01'
cArq+= '020'
cArq+= SPACE(1)
cArq+= '2'
cArq+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")
cArq+="650281324"//PADL(ALLTRIM(SEE->EE_CODEMP),20,"0")// 9 -- andre/rsac 30/03/2017
ŒcArq+= SPACE(11)
If Empty(SA6->A6_DVAGE)
	cArq+=PADL(ALLTRIM(SA6->A6_AGENCIA),6,"0")
Else
	cArq+=PADL(ALLTRIM(SA6->A6_AGENCIA),5,"0")// 5 ANDRE/RSAC 31.03.2017
	cArq+=ALLTRIM(SA6->A6_DVAGE)
EndIF
cArq+=STRZERO(val(SEE->EE_ULTDSK),6)
If Empty(SA6->A6_DVAGE)
	cArq+=PADL(ALLTRIM(SA6->A6_AGENCIA),6,"0")
Else
	cArq+=PADL(ALLTRIM(SA6->A6_AGENCIA),5,"0")// 5 ANDRE/RSAC 31.03.2017
	cArq+=ALLTRIM(SA6->A6_DVAGE)
EndIF
If Empty(SA6->A6_DVCTA)
	cArq+=PADL(ALLTRIM(SA6->A6_NUMCON),13,"0")
Else
	cArq+=PADL(ALLTRIM(SA6->A6_NUMCON),12,"0")
	cArq+=ALLTRIM(SA6->A6_DVCTA)
EndIF
cArq+=SPACE(1)
cArq+=PADR(ALLTRIM(SM0->M0_NOMECOM),30)
cArq+=SUBSTR(DTOS(DDATABASE),7,2)+SUBSTR(DTOS(DDATABASE),5,2)+SUBSTR(DTOS(DDATABASE),1,4)
cArq+=SPACE(6)
cArq+=SPACE(10)
cArq+=SPACE(4)
cArq+=PADR(SUBSTR(SM0->M0_ENDCOB,1,AT(",",SM0->M0_ENDCOB)-1) ,30)
cArq+=PADl(val(alltrim(SUBSTR(SM0->M0_ENDCOB,AT(",",SM0->M0_ENDCOB)+1))),5,'0')
cArq+=SPACE(15)
cArq+=PADR(ALLTRIM(SM0->M0_CIDCOB),20)
cArq+=PADR(ALLTRIM(SM0->M0_CEPCOB),8)
cArq+=PADR(ALLTRIM(SM0->M0_ESTCOB),2)
cArq+=SPACE(8)
cArq+=SPACE(2)
cArq+=SPACE(8)+CHR(13)+CHR(10)
cLin:="00000"
nSomat:=0
nCont2:=0
While !SEF->(EOF()) .AND. nCont2 < 50
	IncProc("Montando arquivo")
	nCont2++
	if !EMPTY(SEF->EF_OK)
		nCont++
		cArq+="001"
		cArq+="0001"
		cArq+="3"
		cLin:=soma1(cLin)
		cArq+=cLin
		cArq+="N"
		cArq+="0"
		cArq+="02"
		cArq+=PADR(SEF->EF_CODCHEQ,34)
		cArq+=PADR(alltrim(posicione('SA1',1,xFilial('SA1')+SEF->EF_CLIENTE+SEF->EF_LOJACLI,"A1_CGC")),14)
		cArq+=PADl(alltrim(CVALTOCHAR(SEF->EF_VALOR*100)),15,'0')
		nSomat+=SEF->EF_VALOR
		cArq+=SUBSTR(DTOS(SEF->EF_VENCTO),7,2)+SUBSTR(DTOS(SEF->EF_VENCTO),5,2)+SUBSTR(DTOS(SEF->EF_VENCTO),1,4)
		cSql:=" SELECT TOP 1 EF_IDCNAB FROM "+RetSqlName('SEF')
		cSql+=" ORDER BY EF_IDCNAB DESC"
		If Select('TRNUM')<>0
			TRNUM->(DBCloseArea())
		EndIF
		TcQuery cSql New Alias 'TRNUM'
		IF !TRNUM->(EOF())
			if Empty(TRNUM->EF_IDCNAB)
				cNum:='0000000001'
			Else
					cNum:=soma1(TRNUM->EF_IDCNAB)
				EndIF
		EndIF
		/*
		gravar o idcnab na SEF
		
		*/
		cArq+=cNum
		cArq+= space(10)
		cArq+= '000'
		cArq+= '001'
		cArq+= strzero(val(subs(mv_par02,01,4))*1,5) //padl(alltrim(mv_par02),4) // (5) Alterado Andre/Rsac -- 08/06/2016   -- 06/09/2016 -- strzero(val(subs(SEF->EF_CODCHEQ,4,4))*1,5) //
		cArq+= strzero(val(subs(mv_par02,01,4))*1,5) //padl(alltrim(mv_par02),4) //(5) Alterado Andre/Rsac -- 08/06/2016-- 06/09/2016
		cArq+= strzero(val(subs(mv_par03,1,5))*1,12) //strzero(val(subs(mv_par03,1,12))*1,12) // (padl) Alterado Andre/Rsac -- 08/06/2016     -- 06/09/2016
		cArq+= replicate('0',15)
		cArq+= replicate('0',15)
		cArq+= replicate('0',15)
		cArq+= space(49)
		cArq+= space(2)
		cArq+= space(8)+CHR(13)+CHR(10)
	EndIf
	SEF->(DBsKIP())
EndDo
//alterado 13/09/2016 -- andre/rsac
cArq+= '001'
cArq+= '0001'
cArq+= '5'
cArq+= SPACE(9)
//cLin:= strzero(val(soma1(cLin)),6)//soma1(cLin) //strzero(val(clin),6)//strzero(val(clin)-1,5) //soma1(cLin) // Alterado Andre/Rsac -- 08/06/2016 -- 06/09/2016
cArq+= strzero(val(soma1(cLin))+1,6)//strzero(val(soma1(cLin))-1,6)
cArq+= PADl(alltrim(CVALTOCHAR(nSomat*100)),18,'0') //strzero(nSomat*100,16)
cArq+= strzero(nCont,6)
cArq+= SPACE(52)
cArq+= REPLICATE('0',18)
cArq+= REPLICATE('0',18)
cArq+= REPLICATE('0',18)
cArq+= REPLICATE('0',6)
cArq+= space(18)
cArq+= space(63)+CHR(13)+CHR(10)

cArq+= '001'
cArq+= '9999'
cArq+= '9'
cArq+= SPACE(9)
cArq+= strzero(1,6)
cLin:=strzero(val(soma1(cLin)),6)//soma1(cLin)
//cArq+= cLin
cArq+= strzero(val(clin)+3,6)//strzero(val(cLin),6)
cArq+= strzero(1,6)
cArq+= space(205)+CHR(13)+CHR(10)

cArqSaid:="C:\CNAB\"+alltrim(MV_PAR03)+"_"+DTOS(DDATABASE)+".REM"
MemoWrite(cArqSaid,cArq)

if aviso("[AFIN002]-Cnab de Cheques","Arquivo gerado com sucesso, no caminho: "+cArqSaid+chr(13)+chr(10)+;
	"Deseja abrir a pasta",{"Sim","Nao"})==1
	winexec("explorer.exe "+"C:\CNAB\")
EndIF

Return


Static Function marcall
cAlias:=oMark:Alias()
cMarc:=oMark:CMARK
(cAlias)->( dbGoTop() )
While !(cAlias)->( EOF() )
	
  oMark:MarkRec()

	(cAlias)->(dbSkip())
EndDO


 oMark:refresh(.t.)

Return

 /*
Static Function SeeREC

LOCAL _RecSEE := ""

DBSELECTAREA("SEE")
DBSETORDER(1)
DBSEEK(xfilial("SEE")+BANCO+AGENCIA+CONTA+SUBCNTA)


Reclock("SEE",.F.)
SEE->EE_ULTDSK :=SEE->EE_ULTDSK + 1
MSUNLOCK()

RETURN(_RecSEE)
       
   */



//-------------------------------------------------------------------
Static Function CRIASX1(cPerg)

PutSX1(cPerg, "01", "Banco"                , "", "", "mv_ch1", "C", TAMSX3('A6_COD')[1]    ,  0, 0, "G", "", "SEE"      , "", "" , "mv_par01", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "02", "Agencia"              , "", "", "mv_ch2", "C", TAMSX3('A6_AGENCIA')[1],  0, 0, "G", "", ""         , "", "" , "mv_par02", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "03", "Conta"                , "", "", "mv_ch3", "C", TAMSX3('A6_CONTA')[1]  ,  0, 0, "G", "", ""         , "", "" , "mv_par03", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "04", "Subconta"             , "", "", "mv_ch4", "C", TAMSX3('EE_SUBCTA')[1] ,  0, 0, "G", "", ""         , "", "" , "mv_par04", "","","","","","","","","","","","","","","","")

Return cPerg
