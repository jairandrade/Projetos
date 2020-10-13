#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*
+----------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Relatório                                               !
+------------------+---------------------------------------------------------+
!Módulo            ! Compras	                                             !
+------------------+---------------------------------------------------------+
!Nome              ! COMR202                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Relatório de Grupos de Aprovação 		                 !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                  		     !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 17/01/2019                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!											!           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/
User Function COMR202()
Local oReport
Private cPerg := PadR("COMR202",10)

CriaSX1(cPerg)
Pergunte(cPerg,.F.)

oReport := ReportDef()
oReport:PrintDialog()

Return

Static Function ReportDef()

Local oReport
Local oSessao

oReport := TReport():New("COMR202", "Relatório de Grupos de Aprovação", cPerg, {|oReport| ReportPrint(oReport)}, "Relatório de Grupos de Aprovação")
oReport:SetLandScape(.T.)
oSessao := TRSection():New(oReport, "Relatório de Grupos de Aprovação" )

// Colunas padrão
TRCell():New( oSessao, "AL_COD" 	, "", "Grupo" 			, "", 15)
TRCell():New( oSessao, "AL_DESC" 	, "", "Descrição" 		, "", 40)
//TRCell():New( oSessao, "AL_AUTOLIM" , "", "Limite Autom."	, "", 15)
//TRCell():New( oSessao, "AL_TPLIBER" , "", "Tp.Liberação"	, "", 15)
TRCell():New( oSessao, "AL_DOCAE" 	, "", "Aut.Entrega"		, "", 15)
TRCell():New( oSessao, "AL_DOCCO" 	, "", "Cotações"   		, "", 15)
TRCell():New( oSessao, "AL_DOCCP" 	, "", "Contr.Parceria" 	, "", 15)
TRCell():New( oSessao, "AL_DOCMD" 	, "", "Medições"		, "", 15)
TRCell():New( oSessao, "AL_DOCNF" 	, "", "Nota Fiscal" 	, "", 15)
TRCell():New( oSessao, "AL_DOCPC" 	, "", "Ped.Compra" 		, "", 15)
TRCell():New( oSessao, "AL_DOCSA"  	, "", "Sol.Armazem" 	, "", 15)
TRCell():New( oSessao, "AL_DOCSC" 	, "", "Sol.Compra"  	, "", 15)
TRCell():New( oSessao, "AL_DOCST" 	, "", "Sol.Transfer." 	, "", 15)
TRCell():New( oSessao, "AL_DOCIP" 	, "", "Item Pedido" 	, "", 15)
TRCell():New( oSessao, "AL_DOCCT" 	, "", "Tp.Contrato" 	, "", 15)
TRCell():New( oSessao, "AL_DOCGA" 	, "", "Doc.Garantia" 	, "", 15)
TRCell():New( oSessao, "Z33_GRPCOM"	, "", "Grupo Compras" 	, "", 15)
TRCell():New( oSessao, "AJ_XDESCG" 	, "", "Descrição Grupo"	, "", 20)
TRCell():New( oSessao, "Z34_GRUPO" 	, "", "Grp.Usuarios"    , "", 15)
TRCell():New( oSessao, "Z34_USUAR" 	, "", "Usuarios" 		, "", 15)
TRCell():New( oSessao, "AL_USER" 	, "", "Aprovadores" 	, "", 15)
TRCell():New( oSessao, "AL_NIVEL" 	, "", "Nivel"			, "", 05)
TRCell():New( oSessao, "AL_TPLIBER" , "", "Tipo liberacao"  , "", 15)
TRCell():New( oSessao, "AL_PERFIL" 	, "", "Perfil Aprovador", "", 15)
TRCell():New( oSessao, "DBL_CC" 	, "", "Centro Custo" 	, "", 15)

oReport:HideParamPage()

Return (oReport)

Static Function ReportPrint(oReport)

Local oBreak
Local oSessao 	:= oReport:Section(1)
Local cAl 		:= GetNextAlias()
Local cWhere	:= '%%'
Local dDtInc
Local dDtAlt
Local cUserLGI 	:= ""
Local cStatus 	:= ""
Local aGrupos
Local cGrupo := ""
Local cNome := ""
Local cNomeU := ""
Local cCod := ""
Local cTpLiberacao := ""

oSessao:BeginQuery()

BeginSQL alias cAl
	
	SELECT AL_COD,AL_DESC,AL_LIBAPR,AL_DOCAE,AL_DOCCO,AL_DOCCP,AL_DOCMD,AL_DOCNF,
	AL_DOCPC,AL_DOCSA,AL_DOCSC,AL_DOCST,AL_DOCIP,AL_DOCCT,AL_DOCGA, Z33_GRPCOM,
	(SELECT DISTINCT AJ_XDESCG FROM SAJ010 SAJ WHERE AJ_GRCOM = Z33_GRPCOM AND SAJ.D_E_L_E_T_ <> '*') AS AJ_XDESCG,
	Z34_GRPUSU, AL_USER ,Z34_USUAR,AL_NIVEL,AL_TPLIBER,AL_PERFIL,DBL_CC
	FROM  %table:SAL% SAL
	LEFT JOIN %table:Z33% Z33 ON Z33_GRUPO = AL_COD AND Z33.D_E_L_E_T_ <> '*'
	LEFT JOIN %table:Z34% Z34 ON Z34_GRUPO = AL_COD AND Z34.D_E_L_E_T_ <> '*'
	LEFT JOIN %table:DBL% DBL ON DBL_GRUPO = AL_COD AND DBL.D_E_L_E_T_ <> '*'
	WHERE SAL.D_E_L_E_T_ <> '*'
	AND (AL_COD >= %Exp:mv_par01%)
	AND (AL_COD <= %Exp:mv_par02%)
	ORDER BY AL_COD,Z33_GRPCOM
EndSQL
//Memowrite("c:\temp\COMR202.TXT",getLastQuery()[2])
oSessao:EndQuery()

DbSelectArea(cAl)

(cAl)->(DbGoTop())

ProcRegua(Reccount())

oReport:SetMeter((cAl)->(RecCount()))

oSessao:Init()
Do While (!(cAl)->(Eof()))
	
	If oReport:Cancel()
		Exit
	EndIf
	cGrupo := ""
	cNome  := ""
	cNomeU  := ""
	// verifica se usuario não está vazio
	If !Empty((cAl)->AL_USER)
		aGrupos :={}
		PswOrder(1)
		If (  PswSeek((cAl)->AL_USER, .T.) )
			aGrupos := Pswret(1)
			cNome := aGrupos[1][4]
		EndIf
	EndIf
	// verifica se usuario não está vazio
	If !Empty((cAl)->Z34_USUAR)
		aGrupos :={}
		PswOrder(1)
		If (  PswSeek((cAl)->Z34_USUAR, .T.) )
			aGrupos := Pswret()
			cNomeU := aGrupos[1][4]
			//cGrupo := aGrupos[1][10][1]
		EndIf
	Else
		cGrupo := (cAl)->Z34_GRPUSU
	EndIf
	If (cAl)->AL_TPLIBER == "U"
		cTpLiberacao := "Usuário" //Liberaçao Individual
	ElseIf (cAl)->AL_TPLIBER == "N"
		cTpLiberacao := "Nível"//Libera todo o nivel de aprovaçao
	ElseIf (cAl)->AL_TPLIBER == "P"
		cTpLiberacao := "Documento" //Libera todo o documento
	EndIf
	
	oSessao:Cell("AL_COD"):SetValue((cAl)->AL_COD)
	oSessao:Cell("AL_DESC"):SetValue((cAl)->AL_DESC)
	oSessao:Cell("AL_DOCAE"):SetValue(IIf((cAl)->AL_DOCAE==.F.,"Não","Sim"))
	oSessao:Cell("AL_DOCCO"):SetValue(IIf((cAl)->AL_DOCCO==.F.,"Não","Sim"))
	oSessao:Cell("AL_DOCCP"):SetValue(IIf((cAl)->AL_DOCCP==.F.,"Não","Sim"))
	oSessao:Cell("AL_DOCMD"):SetValue(IIf((cAl)->AL_DOCMD==.F.,"Não","Sim"))
	oSessao:Cell("AL_DOCNF"):SetValue(IIf((cAl)->AL_DOCNF==.F.,"Não","Sim"))
	oSessao:Cell("AL_DOCPC"):SetValue(IIf((cAl)->AL_DOCPC==.F.,"Não","Sim"))
	oSessao:Cell("AL_DOCSA"):SetValue(IIf((cAl)->AL_DOCSA==.F.,"Não","Sim"))
	oSessao:Cell("AL_DOCSC"):SetValue(IIf((cAl)->AL_DOCSC==.F.,"Não","Sim"))
	oSessao:Cell("AL_DOCST"):SetValue(IIf((cAl)->AL_DOCST==.F.,"Não","Sim"))
	oSessao:Cell("AL_DOCIP"):SetValue(IIf((cAl)->AL_DOCIP==.F.,"Não","Sim"))
	oSessao:Cell("AL_DOCCT"):SetValue(IIf((cAl)->AL_DOCCT==.F.,"Não","Sim"))
	oSessao:Cell("AL_DOCGA"):SetValue(IIf((cAl)->AL_DOCGA==.F.,"Não","Sim"))
	oSessao:Cell("Z33_GRPCOM"):SetValue((cAl)->Z33_GRPCOM)
	oSessao:Cell("AJ_XDESCG"):SetValue((cAl)->AJ_XDESCG)
	oSessao:Cell("Z34_GRUPO"):SetValue(cGrupo)
	oSessao:Cell("AL_USER"):SetValue(cNome)
	oSessao:Cell("Z34_USUAR"):SetValue(cNomeU)
	oSessao:Cell("AL_NIVEL"):SetValue((cAl)->AL_NIVEL)
	oSessao:Cell("AL_TPLIBER"):SetValue(cTpLiberacao)
	oSessao:Cell("AL_PERFIL"):SetValue(Posicione("DHL", 01, xFilial("DHL") + (cAl)->AL_PERFIL, "DHL_DESCRI"))
	oSessao:Cell("DBL_CC"):SetValue((cAl)->DBL_CC)
	oSessao:PrintLine()
	(cAl)->(dbSkip())
	
Enddo

oSessao:Finish()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} CriaSX1
Função para criação das perguntas na SX1

@author Jair  Matos
@since 17/01/2019
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CriaSX1(cPerg)
cValid   := ""
cF3      := ""
cPicture := ""
cDef01   := ""
cDef02   := ""
cDef03   := ""
cDef04   := ""
cDef05   := ""
U_XPutSX1(cPerg, "01", "Grupo De?"		,"MV_PAR01", "MV_CH1", "C", 06,	0, "G", cValid,     "SAL",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o grupo inicial")
U_XPutSX1(cPerg, "02", "Grupo Até?"		,"MV_PAR02", "MV_CH2", "C", 06, 0, "G", cValid,     "SAL",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o grupo final")

Return
