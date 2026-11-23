public class UrlOnClickController {
   public pageReference doRedirect(string url) {    	
        PageReference pr = new PageReference( urlShortenController.DEFAULT_URL );
        pr.setRedirect( true );
        
        system.debug('url '+url);
                system.debug('pr '+pr);

        if( url == null || !urlShortenController.isSetup )
            return pr;
            
        url = string.escapeSingleQuotes(url.trim());
            
        if( url.startsWith('/') )
            url = url.substring( 1, url.length() );
            
        if( url == '' )
            return pr;
        
        Short_URL__c[] urls;
        
        try {
            urls = [select id, URL__c
            from Short_URL__c
            where short_url__c = :url
            order by createddate asc limit 1];
        } catch( QueryException e ) {}
         system.debug('urls '+urls);   
        if( urls == null || urls.isEmpty() )
            return pr;
            
        string redirect = urls[0].url__c;
        system.debug('redirect '+redirect);
        if( !redirect.tolowercase().startsWith('http://') &&
            !redirect.tolowercase().startsWith('https://') &&
            !redirect.tolowercase().startsWith('mailto:') )
            redirect = 'http://' + redirect;
            
        if( redirect.endsWith( '/' ) )
        	redirect = redirect.substring( 0, redirect.length() - 1 );
            
        pr = new PageReference( redirect );
        pr.setRedirect( true );     
      
        return pr;
    }

}