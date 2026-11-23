({
	afterRender: function (component, helper) {
        this.superAfterRender();
        
        var urlStr = window.location.href;
        var urlStrWithoutQueryParams = window.location.href;
        var query_string_paramter = '';
        
        if(urlStr != null || urlStr !== undefined){
            var splittedURL = urlStr.split("?");
            if(splittedURL != null && splittedURL.length !== undefined && splittedURL.length > 1)
                query_string_paramter = splittedURL[1];
            urlStrWithoutQueryParams = splittedURL[0];
        }
        
        var messageDomain = window.location.protocol + '//' + window.location.hostname + (window.location.port ? ':' + window.location.port : '');
        var messageData = {
            type: 'intel.salesForceHitPageView',
            pageType: 'pageType', 
            partnerMDAId : 'partnerMDAId',
            offeringId : 'offeringId',
            labelHeader : 'labelHeader',
            title : 'title',
            targetURL : 'targetURL',
            urlStr : urlStrWithoutQueryParams,
            query_string_paramter : '?'+ query_string_paramter,
        };
        
	},
})