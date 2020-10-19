#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

User Function GP650ACM()    

Local aArea := GetArea()
Local cFil	 := &cFilLan
Local cMat	 := &cMatLan
Local cCC  	 := &cCcLan
Local cPD	 := &cPDLan
Local nVal	 := &cValLan
Local nSeq	 := 0         
 
	nPos:= Ascan( aAliasFields ,{|x|x[1]+x[2]+x[3]+x[4]==cFil+cMat+cCC+cPD })    
 
	If nPos == 0
 		Aadd( aAliasFields, { 	cFil, cMat, cCC, cPD, nVal, "001"	} )
	Else	
 		nSeq := VAL(aAliasFields[nPos,6])+1		
 		Aadd( aAliasFields, { 	cFil, cMat, cCC, cPD, nVal, strZero(nSeq,3)} )
	EndIf      

RestArea(aArea)

Return   

