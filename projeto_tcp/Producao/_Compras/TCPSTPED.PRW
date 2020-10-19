/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Programa ≥TCPSTPED  ∫ Autor ≥ ALYSON           ∫ Data ≥  27/09/18      ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ TCP STATUS DO PEDIDO DE COMPRAS EM PROCESSO DE APROVA«√O   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/


User function TCPSTPED


local oReport
local cPerg  := "TCPSTPED"
local cAlias := getNextAlias()


//criaSx1(cPerg)
Pergunte(cPerg, .F.)

oReport := reportDef(cAlias, cPerg)

oReport:printDialog()

return

//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relatorio.                                  !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportPrint(oReport,cAlias)

local oSecao1 := oReport:Section(1)
local cConvert := " "   
Local cWhere := '%' 

IF !EMPTY(mv_par03)
	cWhere += " AND ( SELECT COUNT(*) FROM "+ RetSqlName("SCR")  +" SCR, "+ RetSqlName("SAK")  +" SAK "
	cWhere += " WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD "
	cWhere += "AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*'  AND AK_COD='"+mv_par03+"' ) > 0 "
ENDIF

cWhere += '%'

//Column C7_EMISSAO AS date
oSecao1:BeginQuery()

BeginSQL Alias cAlias	
		
SELECT  DISTINCT SC7.C7_NUM AS NUM,C7_CONTRA AS CONTRATO,
CASE
WHEN SC7.C7_CONTRA = '' THEN 'PED.COMPRA' 
WHEN SC7.C7_CONTRA <> '' THEN 'CONTRATO'  
END AS TPPED,
C7_FORNECE AS FORNECEDOR, 
ISNULL((SELECT A2_NOME FROM %Table:SA2% SA2 WHERE A2_COD = SC7.C7_FORNECE AND A2_LOJA = SC7.C7_LOJA AND SA2.D_E_L_E_T_ <> '*' ),'') AS NOM_FORN,
ISNULL((SELECT A2_CGC FROM %Table:SA2% SA2 WHERE A2_COD = SC7.C7_FORNECE AND A2_LOJA = SC7.C7_LOJA AND SA2.D_E_L_E_T_ <> '*' ),'') AS CNPJF,C7_EMISSAO , SC7.C7_USER AS COMPRADOR,
ISNULL((SELECT  Y1_NOME FROM %Table:SY1% SY1 WHERE  Y1_USER = SC7.C7_USER AND D_E_L_E_T_ <> '*'),'' )AS NOME_COMP,
CASE
WHEN SC7.C7_CONAPRO = 'B' THEN 'BLOQUEADO-AZUL' 
WHEN SC7.C7_CONAPRO = 'L' THEN 'APROVADO-VERDE'  
END AS TPPED,
(SELECT SUM(XC7.C7_TOTAL +C7_VALIPI + XC7.C7_VALEMB + XC7.C7_VALSOL- XC7.C7_VLDESC) FROM %Table:SC7% XC7  WHERE XC7.C7_FILIAL = SC7.C7_FILIAL AND XC7.C7_NUM = SC7.C7_NUM AND SC7.D_E_L_E_T_ <> '*' AND XC7.D_E_L_E_T_ <> '*') AS TOTPED,
(SELECT COUNT (*) FROM %Table:SCR% SCR WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND D_E_L_E_T_ <> '*') AS TOT_APROV,
(SELECT COUNT (*) FROM %Table:SCR% SCR WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND D_E_L_E_T_ <> '*' AND SCR.CR_STATUS IN (3)) AS TOT_LIB,
ISNULL((SELECT SAK.AK_NOME FROM %Table:SCR% SCR,%Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '01' AND SCR.R_E_C_N_O_ = (SELECT MAX(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR,%Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '01' ) ),'---') PRIM_NVL1,

ISNULL((SELECT 
CASE
WHEN SCR.CR_STATUS = 01   THEN 'Aguardando aprovaÁ„o de outros usuarios' 
WHEN SCR.CR_STATUS = 02   THEN 'Aguardando aprovaÁ„o deste usu·rio' 
WHEN SCR.CR_STATUS = 03   THEN 'Aprovado' 
WHEN SCR.CR_STATUS = 04   THEN 'Bloqueado' 
WHEN SCR.CR_STATUS = 05   THEN 'Aprovado por outro usuario' 
END 
FROM %Table:SCR% SCR,%Table:SAK% SAK
WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '01' AND SCR.R_E_C_N_O_ = (SELECT MAX(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '01' ) ),'---') STAT_NVL1,

ISNULL((SELECT SAK.AK_NOME FROM %Table:SCR% SCR,%Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '02' AND SCR.R_E_C_N_O_ = (SELECT MAX(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR,%Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '02' ) ),'---') PRIM_NVL2,

ISNULL((SELECT 
CASE
WHEN SCR.CR_STATUS = 01   THEN 'Aguardando aprovaÁ„o de outros usuarios' 
WHEN SCR.CR_STATUS = 02   THEN 'Aguardando aprovaÁ„o deste usu·rio' 
WHEN SCR.CR_STATUS = 03   THEN 'Aprovado' 
WHEN SCR.CR_STATUS = 04   THEN 'Bloqueado' 
WHEN SCR.CR_STATUS = 05   THEN 'Aprovado por outro usuario' 
END STATUS_APROV
FROM %Table:SCR% SCR,%Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '02' AND SCR.R_E_C_N_O_ = (SELECT MAX(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '02' ) ),'---') STAT_NVL2,

ISNULL((SELECT SAK.AK_NOME FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '02' AND SCR.R_E_C_N_O_ = (SELECT MIN(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '02' ) ),'---') SEG_NVL2,
ISNULL((SELECT 
CASE
WHEN SCR.CR_STATUS = 01   THEN 'Aguardando aprovaÁ„o de outros usuarios' 
WHEN SCR.CR_STATUS = 02   THEN 'Aguardando aprovaÁ„o deste usu·rio' 
WHEN SCR.CR_STATUS = 03   THEN 'Aprovado' 
WHEN SCR.CR_STATUS = 04   THEN 'Bloqueado' 
WHEN SCR.CR_STATUS = 05   THEN 'Aprovado por outro usuario' 
END STATUS_APROV
FROM %Table:SCR% SCR, %Table:SAK% SAK 
WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '02' AND SCR.R_E_C_N_O_ = (SELECT MIN(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '02' ) ),'---') SEG_NVL2,

ISNULL((SELECT SAK.AK_NOME FROM %Table:SCR% SCR,%Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '03' AND SCR.R_E_C_N_O_ = (SELECT MAX(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR,%Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '03' ) ),'---') PRM_NVL3,

ISNULL((SELECT 
CASE
WHEN SCR.CR_STATUS = 01   THEN 'Aguardando aprovaÁ„o de outros usuarios' 
WHEN SCR.CR_STATUS = 02   THEN 'Aguardando aprovaÁ„o deste usu·rio' 
WHEN SCR.CR_STATUS = 03   THEN 'Aprovado' 
WHEN SCR.CR_STATUS = 04   THEN 'Bloqueado' 
WHEN SCR.CR_STATUS = 05   THEN 'Aprovado por outro usuario' 
END STATUS_APROV
FROM %Table:SCR% SCR,%Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '03' AND SCR.R_E_C_N_O_ = (SELECT MAX(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '03' ) ),'---') PRM_STAT3,

ISNULL((SELECT SAK.AK_NOME FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '03' AND SCR.R_E_C_N_O_ = (SELECT MIN(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '03' ) ),'---') SEG_NVL3,
ISNULL((SELECT 
CASE
WHEN SCR.CR_STATUS = 01   THEN 'Aguardando aprovaÁ„o de outros usuarios' 
WHEN SCR.CR_STATUS = 02   THEN 'Aguardando aprovaÁ„o deste usu·rio' 
WHEN SCR.CR_STATUS = 03   THEN 'Aprovado' 
WHEN SCR.CR_STATUS = 04   THEN 'Bloqueado' 
WHEN SCR.CR_STATUS = 05   THEN 'Aprovado por outro usuario' 
END STATUS_APROV
FROM %Table:SCR% SCR, %Table:SAK% SAK 
WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '03' AND SCR.R_E_C_N_O_ = (SELECT MIN(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '03' ) ),'---') SEG_STAT3,

ISNULL((SELECT SAK.AK_NOME FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '04' AND SCR.R_E_C_N_O_ = (SELECT MAX(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '04' ) ),'---') QUART_APROVADOR_NIVEL_4,
ISNULL((SELECT CASE
WHEN SCR.CR_STATUS = 01   THEN 'Aguardando aprovaÁ„o de outros usuarios' 
WHEN SCR.CR_STATUS = 02   THEN 'Aguardando aprovaÁ„o deste usu·rio' 
WHEN SCR.CR_STATUS = 03   THEN 'Aprovado' 
WHEN SCR.CR_STATUS = 04   THEN 'Bloqueado' 
WHEN SCR.CR_STATUS = 05   THEN 'Aprovado por outro usuario' 
END STATUS_APROV FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '04' AND SCR.R_E_C_N_O_ = (SELECT MAX(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '04' ) ),'---') STAT_NVL4,
ISNULL((SELECT SAK.AK_NOME FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '05' AND SCR.R_E_C_N_O_ = (SELECT MAX(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '05' ) ),'---') QUIN_APROVADOR_NIVEL_5,
ISNULL((SELECT 
CASE
WHEN SCR.CR_STATUS = 01   THEN 'Aguardando aprovaÁ„o de outros usuarios' 
WHEN SCR.CR_STATUS = 02   THEN 'Aguardando aprovaÁ„o deste usu·rio' 
WHEN SCR.CR_STATUS = 03   THEN 'Aprovado' 
WHEN SCR.CR_STATUS = 04   THEN 'Bloqueado' 
WHEN SCR.CR_STATUS = 05   THEN 'Aprovado por outro usuario' 
END STATUS_APROV FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '05' AND SCR.R_E_C_N_O_ = (SELECT MAX(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '05' ) ),'---') STAT_NVL5,
ISNULL((SELECT SAK.AK_NOME FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '05' AND SCR.R_E_C_N_O_ = (SELECT MAX(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '06' ) ),'---') PRIM_NVL6,
ISNULL((SELECT 
CASE
WHEN SCR.CR_STATUS = 01   THEN 'Aguardando aprovaÁ„o de outros usuarios' 
WHEN SCR.CR_STATUS = 02   THEN 'Aguardando aprovaÁ„o deste usu·rio' 
WHEN SCR.CR_STATUS = 03   THEN 'Aprovado' 
WHEN SCR.CR_STATUS = 04   THEN 'Bloqueado' 
WHEN SCR.CR_STATUS = 05   THEN 'Aprovado por outro usuario' 
END STATUS_APROV FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '05' AND SCR.R_E_C_N_O_ = (SELECT MAX(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_NIVEL = '06' ) ),'---') STAT_NVL6,
CASE
WHEN (SELECT COUNT (*) FROM %Table:SCR% SCR WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND SCR.D_E_L_E_T_ <> '*' AND SCR.CR_STATUS = 4) > 0 THEN 'BLOQUEADO' 
ELSE 'PENDENTE' 
END AS STATUS,
ISNULL((SELECT MAX(AK_NOME) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_STATUS = 4),'') AS APR_BLOQ,
ISNULL((SELECT SCR.CR_DATALIB FROM %Table:SCR% SCR WHERE SCR.CR_NUM = SC7.C7_NUM AND D_E_L_E_T_ <> '*' AND SCR.CR_STATUS = 4),'') AS DT_BLOQ,
C7_MOTREJ AS MOT_BLOQ,
ISNULL((SELECT SAK.AK_NOME FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_STATUS = '02' AND SCR.R_E_C_N_O_ = (SELECT MAX(SCR.R_E_C_N_O_) FROM %Table:SCR% SCR, %Table:SAK% SAK WHERE SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND  SCR.CR_FILIAL = SAK.AK_FILIAL AND SCR.CR_APROV = SAK.AK_COD AND SCR.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*' AND SCR.CR_STATUS = '02' ) ),'---') RESP,
ISNULL((SELECT MAX(CR_DATALIB) FROM %Table:SCR% SCR WHERE SCR.CR_NUM = SC7.C7_NUM AND D_E_L_E_T_ <> '*' AND SCR.CR_STATUS = '03'),(SELECT MAX(CR_EMISSAO) FROM %Table:SCR% SCR WHERE SCR.CR_NUM = SC7.C7_NUM AND D_E_L_E_T_ <> '*')) AS DT_RSP


FROM %Table:SC7% SC7
WHERE SC7.D_E_L_E_T_ <> "*"  
AND SC7.C7_ACCPROC <> "1" 
AND SC7.C7_CONAPRO = "B" 
AND SC7.C7_QUJE < SC7.C7_QUANT 
AND SC7.C7_FILIAL = %xFilial:SC7%
AND SC7.C7_EMISSAO BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
AND SC7.C7_RESIDUO = ""
%EXP:cWhere%
ORDER BY C7_NUM
EndSQL 

//Conout(getlastquery()[2])

oSecao1:EndQuery()
oReport:SetMeter((cAlias)->(RecCount()))

oSecao1:Print()	

return

//+-----------------------------------------------------------------------------------------------+
//! Funcao para criaÁ„o da estrutura do relatorio                                                 !
//+-----------------------------------------------------------------------------------------------+ 

Static Function ReportDef(cAlias,cPerg)

local cTitle  := "Status da aprovaÁ„o do Pedido de Compras"
local cHelp   := "Permite gerar relatorio Pedidos de Vendas em aberto. Com valores."
local oBreak1
local oBreak2
local oReport
local oSection1  

oReport	:= TReport():New("TCPSTPED",cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

//oReport:oPage:SetPaperSize(3) // seleciona Impressao papel A4  
oReport:SetLandScape(.T.)
oReport:SetTotalInLine(.F.)  

//Primeira seÁ„o
oSection1 := TRSection():New(oReport,"Status",{"SC7"})
TRCell():New(oSection1,"NUM", "SC7", "Numero","",20,,,,,"")
TRCell():New(oSection1,"TOTPED", "SC7", "TOTAL PEDIDO","@E 999,999,999.99",14,,,,,"RIGHT")
TRCell():New(oSection1,"NOM_FORN", "SC7", "Nome Fornecedor","",20,,,,,"")
TRCell():New(oSection1,"FORNECEDOR", "SC7", "FORNECEDOR","",20,,,,,"")

TRCell():New(oSection1,"CNPJF", "SC7", "CNPJ","",20,,,,,"")
TRCell():New(oSection1,"CONTRATO", "SC7", "CONTRATO","@!",35,,,,,"")
TRCell():New(oSection1,"TPPED", "SC7", "TIPO","",20,,,,,"")

TRCell():New(oSection1,"C7_EMISSAO", "SC7", "DT.EMISSAO","",20,,,,,"")
TRCell():New(oSection1,"COMPRADOR", "SC7", "Comprador","",20,,,,,"")
TRCell():New(oSection1,"NOME_COMP", "SC7", "Nome","",40,,,,,"")

TRCell():New(oSection1,"RESP", "SC7", "RESPONS¡VEL PENDENTE","",15,,,,,"RIGHT")
TRCell():New(oSection1,"DT_RSP", "SC7", "DATA DO ENVIO AO RESP.",X3PICTURE("C7_EMISSAO"),20,,,,,"")


TRCell():New(oSection1,"TOT_APROV", "SC7", "TOTAL APROVADORES","@E 99",2,,,,,"RIGHT")
TRCell():New(oSection1,"TOT_LIB", "SC7", "TOTAL APROVADO","@E 99",2,,,,,"RIGHT")

TRCell():New(oSection1,"PRIM_NVL1", "SC7", "Aprovador Nivel 1","",20,,,,,"")
TRCell():New(oSection1,"STAT_NVL1", "SC7", "Status Nivel 1","",20,,,,,"")

TRCell():New(oSection1,"PRIM_NVL2", "SC7", "Prim. Aprovador Nivel 2","",20,,,,,"")
TRCell():New(oSection1,"STAT_NVL2", "SC7", "Prim Status Nivel 2","",20,,,,,"")

TRCell():New(oSection1,"SEG_NVL2", "SC7", "Seg. Aprovador Nivel 2","",20,,,,,"")
TRCell():New(oSection1,"SEG_NVL2", "SC7", "Seg. Status Nivel 2","",20,,,,,"")


TRCell():New(oSection1,"PRM_NVL3", "SC7", "Prim. Aprovador Nivel 3","",20,,,,,"")
TRCell():New(oSection1,"PRM_STAT3", "SC7", "Prim. Status Nivel 3","",20,,,,,"")


TRCell():New(oSection1,"SEG_NVL3", "SC7", "Seg. Aprovador Nivel 3","",20,,,,,"")
TRCell():New(oSection1,"SEG_STAT3", "SC7", "Seg. Status Nivel 3","",20,,,,,"")


TRCell():New(oSection1,"PRIM_NVL4", "SC7", "Aprovador Nivel 4","",20,,,,,"")
TRCell():New(oSection1,"STAT_NVL4", "SC7", "Status Nivel 4","",20,,,,,"")


TRCell():New(oSection1,"PRIM_NVL5", "SC7", "Aprovador Nivel 5","",20,,,,,"")
TRCell():New(oSection1,"STAT_NVL5", "SC7", "Status Nivel 5","",20,,,,,"")


TRCell():New(oSection1,"PRIM_NVL6", "SC7", "Aprovador Nivel 6","",20,,,,,"")
TRCell():New(oSection1,"STAT_NVL6", "SC7", "Status Nivel 6","",20,,,,,"")

TRCell():New(oSection1,"STATUS", "SC7", "Status","",10,,,,,"RIGHT")

TRCell():New(oSection1,"APR_BLOQ",   "SC7", "Nome Aprovador Bloqueio","",30,,,,,"")
TRCell():New(oSection1,"DT_BLOQ", "SC7", "Data Bloqueio","",20,,,,,"")
TRCell():New(oSection1,"MOT_BLOQ", "SC7", "MOT_BLOQ","",200,,,,,"")

Return(oReport)

//+-----------------------------------------------------------------------------------------------+
//! Funcao para criacao das perguntas (se nao existirem)                                          !
//+-----------------------------------------------------------------------------------------------+
/*Static function criaSX1(cPerg)
Local aRegs := {}
	aAdd(aRegs,{cPerg, "01", "Data de"	   , "Data de"     ,"Data de"	  , "mv_ch1", "D", 8, 0, 0, "G", "", "mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "02", "Data ate"	   , "Data ate"    ,"Data ate"    , "mv_ch2", "D", 8, 0, 0, "G", "", "mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "03", "Aprovador"  , "Aprovador"  ,"Aprovador"  , "mv_ch3", "C", 15, 0, 0, "G", "", "mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","SAK","","",""})
	
	U_BuscaPerg(aRegs)
return*/