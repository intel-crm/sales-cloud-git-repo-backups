function viewResponse(namespace,responseId){
	var adjScrWidth = (window.screen.width / 2) - (250);
	var adjScrHeight = (window.screen.height / 2) - (275);
	namespace = namespace === '' ? namespace : namespace + '__' ;
	var url = '/apex/' + namespace + 'DisplayResponseView?ResponseId=' + responseId ;
	var options = 'status=no,'
				  + 'height=550,'
				  + 'width=500,'
				  + 'resizable=yes,'
				  + 'left=' + adjScrWidth + ',' 
				  + 'top=' + adjScrHeight + ',' 
				  + 'screenX=' + adjScrWidth + ','
				  + 'screenY=' + adjScrHeight + ','
				  + 'toolbar=no,'
				  + 'menubar=no,'
				  + 'scrollbars=1,'
				  + 'location=no,'
				  + 'directories=no,'
				  + 'titlebar=no,' 
				  + 'menubar=no';
	var win2 = window.open(url ,'Response', options);
	win2.focus();
}