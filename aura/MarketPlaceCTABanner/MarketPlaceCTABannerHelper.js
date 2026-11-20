({
     insertSEO: function(component, event, helper) {
        var strFullURL = 'https://' + window.location.host + window.location.pathname + '?language=' + $A.get("$Locale.langLocale"); 
        document.getElementById('click');
		//var linknode = document.createElement("link");
        var linknode = !!document.querySelector("link[rel='canonical']") ? document.querySelector("link[rel='canonical']") : document.createElement('link');
        linknode.href = strFullURL;
        linknode.rel= 'canonical';
        document.head.appendChild(linknode);
        
         
    },
    
    
    
	
})