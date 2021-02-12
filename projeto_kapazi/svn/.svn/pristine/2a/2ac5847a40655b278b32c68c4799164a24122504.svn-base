#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TBICONN.CH"

User Function tMata015(_cAmz,_cEnd,_cDescri)
Local aVetor		:= {}
Local nOpc 			:= 0 
Private lMsErroAuto := .F.  

Default _cAmz 	 := ""
Default _cEnd 	 := ""
Default _cDescri := ""

If !Empty(_cAmz) .And. !Empty(_cEnd) .And. !Empty(_cDescri)

	aVetor := 	{	{"BE_LOCAL"  	,_cAmz		,Nil},;				
					{"BE_LOCALIZ"	,_cEnd		,NIL},;				
					{"BE_DESCRIC"	,_cDescri	,NIL},;				
					{"BE_CAPACID"	,0			,NIL},;				
					{"BE_PRIOR"		,"ZZZ"		,NIL},;				
					{"BE_ALTURLC"	,0			,NIL},;				
					{"BE_LARGLC"	,0			,NIL},;				
					{"BE_COMPRLC"	,0			,NIL},; 				
					{"BE_PERDA"		,0			,NIL},;				
					{"BE_STATUS"	,"1"		,NIL} }			
					
	nOpc := 3	// inclusao			
	MSExecAuto({|x,y| MATA015(x,y)},aVetor, nOpc)     
	If lMsErroAuto	
			MostraErro()	
		Else	
			ConOut("--->>Endereço Criado com Sucesso! ")		
	EndIf
EndIf

Return()