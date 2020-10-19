#IFNDEF _FILDFLT_CH
	
	#DEFINE _FILDFLT_CH
	
	/*  
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁBegin Comando de Traducao para as Atualizacoes das  VariaveisЁ
	ЁMv's. 														  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	#xcommand DEFAULTFIL	<uVar1> := <uVal1> =>;
							<uVar1> := (;
										 __cSvFilAnt := IF( Type("__cSvFilAnt") == "U" , cFilAnt , __cSvFilAnt ),;
							  			 IF( <uVar1> == NIL .or. cFilStatic != __cSvFilAnt , <uVal1>, <uVar1> )	 ;
						 				)
	/*  
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁEnd  Comando  de Traducao para as Atualizacoes das  VariaveisЁ
	ЁMv's. 														  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/			 				

#ENDIF