#include "protheus.ch"
/*---------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! PE                                       		 !
+------------------+---------------------------------------------------------+
!Módulo            ! FIN                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Posiciona no título, usando nosso número e banco.
!				   !  PE chamado na importação do arquivo. 
!                  |Deve estar coerente com o PE FR650FIL que é o relatório da importação. |													 !
/*-----------------+---------------------------------------------------------+
!Nome              ! FA200FIL                                                 !			                                         
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 11/10/2016 
                                             !
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                       !
+------------------+--------------------------------------------------------*/
User Function FA200FIL
Local aValores   := ParamIXB
Local _cIdCnab   := aValores[1]
//Preenche com 0 a esquerda, pois pode vir com quantidade de 0 a esquerda diferente do que está gravado no banco. Assim garante que vamos comparar corretamente.
Local _cNumBco   := PADL(ALLTRIM(SUBSTR(aValores[4],1,LEN(ALLTRIM(aValores[4]))-1)),17,'0')
Local _cE1Num    := Substr(aValores[16],305,8)
Local _lReturn   := .F.
Local _cWhere    := '%'
Local _nTotReg
Local dDtMin     := GetNewPar("TCP_DTCNAB", "20150101")

cAlias := getNextAlias()
BeginSQL Alias cAlias
 
 SELECT R_E_C_N_O_ AS E1REC,E1_PORTADO,E1_NUMBCO,E1_NUM
  FROM %Table:SE1% SE1       
  
  WHERE SE1.%NotDel% AND E1_FILIAL = %EXP:cFilAnt% 
   AND E1_EMISSAO >= %EXP:dDtMin% AND right(replicate('0',17) + LTRIM(RTRIM(E1_NUMBCO)),17) = %EXP:_cNumBco% AND E1_PORTADO = %EXP:SEE->EE_CODIGO% 
 
EndSQL

IF !(cAlias)->(Eof())  

	SE1->(DBGOTO((cAlias)->E1REC))
	_lReturn := .T.
		
ENDIF

(cAlias)->(dbclosearea()) 

Return _lReturn