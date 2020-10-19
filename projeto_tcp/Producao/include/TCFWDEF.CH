#XCOMMAND TCF INIT <cHtml>;
			=>	IF ( !( FindFunction( "TcfInit" ) ) .or. ( FindFunction( "TcfInit" ) .and. TcfInit( @<cHtml> ) ) );;

#XCOMMAND TCF END <cHtml>;
			=>		IF( FindFunction( "TcfEnd" ) , TcfEnd( @<cHtml> ) , NIL );;
				ENDIF

#IFNDEF CRLF
	#DEFINE CRLF ( chr(13)+chr(10) )
#ENDIF