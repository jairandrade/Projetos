/*
!PRG! TK.CH
!OBJ! definições comuns a todos os programas
!AUT! HMO
!OBS! propriedade da TAKAOKA
*/

#ifndef FALSE
	#define FALSE .F.
#endif

#ifndef TRUE
	#define TRUE .T.
#endif

#ifndef ESC
	#define ESC 27
#endif

#ifndef CRLF
	#define CRLF CHR(13)+CHR(10)
#endif

#ifndef SIM
	#define SIM	'S'
#endif

#ifndef NAO
	#define NAO 'N'
#endif
         
#define ISARRAY(x)    (valtype(x)=='A')
#define ISLOGIC(x)    (valtype(x)=='L')
#define ISNUMERIC(x)  (valtype(x)=='N')
#define ISCHAR(x)     (valtype(x)=='C')
#define ISDATE(x)     (valtype(x)=='D')
#define ISOBJECT(x)   (valtype(x)=='O')
#define ISNIL(x)      x=NIL

//modo de acesso a arquivos
#define FO_READ			0	//Open for reading (default)
#define FO_WRITE		1 //Open for writing
#define FO_READWRITE	2	// Open for reading or writing

//acesso compartilhado ao arquivos
#define FO_COMPAT            0        //Compatibility mode (default)
#define FO_EXCLUSIVE         16       //Exclusive use
#define FO_DENYWRITE         32       //Prevent others from writing
#define FO_DENYREAD          48       //Prevent others from reading
#define FO_DENYNONE          64       //Allow others to read or write
#define FO_SHARED            64       //Same as FO_DENYNONE

//métodos de mover o ponteiro de arquivo
#define FS_SET		0  //Seek from beginning of file
#define FS_RELATIVE 1 //Seek from the current pointer position
#define FS_END      2 //Seek from end of file

//posicao no vetor da função EnergySX3
#define TITULO		1
#define MASCARA		2
#define TAMANHO		3
#define DECIMAL		4
#define VALIDA		5
#define CONSULTA	6
#define RELACAO		7
#define TIPO		8

//posicao mbowse
#define MB_LI	6	//linha inicial
#define MB_CI	1	//coluna inicial
#define MB_LF	22	//linha final
#define MB_CF	75	//coluna final

//posicao enchoice Full
#define EN_LI	12	//linha inicial
#define EN_CI	1	//coluna inicial
#define EN_LF	220	//linha final
#define EN_CF	318	//coluna final

//posicao enchoice part-screen
#define ENP_LI	12	//linha inicial
#define ENP_CI	1	//coluna inicial
#define ENP_LF	150	//linha final
#define ENP_CF	360	//coluna final 318


#define EN_FULL	{EN_LI,EN_CI,EN_LF,EN_CF}
#define EN_PART {ENP_LI,ENP_CI,ENP_LF,ENP_CF}

//posicao de linha de detalhe
#define DET_LINE {ENP_LF+1,ENP_CI+1,ENP_LF+70,ENP_CF-1}

//posicao da linha de detalhe com rodape
#define DET_LINE_RP {ENP_LF+1,ENP_CI+1,ENP_LF+35,ENP_CF-1}

//posicao dialogo para enchoice
#define DE_LI	50	//linha inicial
#define DE_CI	1	//coluna inicial
#define DE_LF	500	//linha final
#define DE_CF	750	//coluna final

//codificação de transações
#define PESQUISAR	1
#define VISUALIZAR	2
#define INCLUIR		3
#define ALTERAR		4
#define EXCLUIR		5
#define IMPRIMIR    2

//Integração com Word
#ifndef PROTHEUS
	#define EIC_OLECREATELINK				 400
	#define EIC_OLECLOSELINK				 401
	#define EIC_OLENEWFILE					 402
	#define EIC_OLEOPENFILE					 403
	#define EIC_OLESAVEFILE					 404
	#define EIC_OLESAVEASFILE				 405
	#define EIC_OLECLOSEFILE				 406
	#define EIC_OLEPRINTFILE				 407
	#define EIC_OLEUPDATEFIELDS				 408
	#define EIC_OLESETDOCUMENTVAR			 409
	#define EIC_OLEINITIALIZE			     410
	#define EIC_OLEGETPROPERTY 				 411
	#define EIC_OLESETPROPERTY               412
	#define EIC_OLECHECKERROR                413
	#define EIC_OLEREADERROR                 414
	#define EIC_OLEEXECUTEMACRO				 415
	#define ID_CHECKMSOLE					 "[19-IDTES99-0915151000-004]"
#endif

#define oleOnError		 "101"

#define oleWdLeft        "201"
#define oleWdTop         "202"
#define oleWdWidth       "203"
#define oleWdHeight      "204"
#define oleWdCaption     "205"
#define oleWdVisible     "206"
#define oleWdWindowState "207"
#define oleWdPrintBack	 "208"

#define oleWdFormatDocument 		 "0" 
#define oleWdFormatTemplate 		 "1" 
#define oleWdFormatText 			 "2" 
#define oleWdFormatTextLineBreaks 	 "3" 
#define oleWdFormatDOSText 			 "4" 
#define oleWdFormatDOSTextLineBreaks "5" 
#define oleWdFormatRTF 				 "6" 
#define oleWdFormatUnicodeText 		 "7" 
#define oleWdFormatHTML 			 "102"

#define AP_DOT	"\MODELOS\"
