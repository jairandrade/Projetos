#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/09/00

User Function Gpe902()        // incluido pelo assistente de conversao do AP5 IDE em 25/09/00

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("_nVHE,_nHE,")

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    쿒PHEXTRA  � Autor � Rita Pimentel         � Data � 16.03.00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o 쿎alculo HORAS EXTRAS      -REGINALDO 25/03/2010             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       쿝oteiro de Calculo -> FOLXXX - Calculo da Folha             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿌ltera豫o:
굇쿎onsiderar todas as verbas de horas extras com exce豫o da verba "110"   �. 
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘anuten뇙o�                                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
//If sra->ra_sitfolh != "D"
	_nVHE := 0
	_nVHE := fBuscaPd("106","V")+fBuscaPd("107","V")+fBuscaPd("108","V")
	_nVHE := _nVHE + fBuscaPd("109","V")+fBuscaPd("111","V")
	_nVHE := _nVHE + fBuscaPd("112","V")+fBuscaPd("113","V")+fBuscaPd("114","V")
	_nVHE := _nVHE + fBuscaPd("115","V")+fBuscaPd("116","V")+fBuscaPd("223","V")
	_nHE := 0
	_nHE := fBuscaPd("106","H")+fBuscaPd("107","H")+fBuscaPd("108","H")
	_nHE := _nHE + fBuscaPd("109","H")+fBuscaPd("111","H")
	_nHE := _nHE + fBuscaPd("112","H")+fBuscaPd("113","H")+fBuscaPd("114","H")
	_nHE := _nHE + fBuscaPd("115","H")+fBuscaPd("116","H")
   If _nHE > 0  
	   FgeraVerba("902",_nVHE,_nHE,,,"H",,,,,.t.)
   ENDIF	   
//endIf
Return
