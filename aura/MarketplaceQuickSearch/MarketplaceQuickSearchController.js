({

	doInit : function(component, event, helper) {
		component.set('v.selectedFilters', {});
    	// TODO hookup backend
        helper.getSearchFilterData(component, helper);

	},

	handleSelectFilter : function(component, event, helper) {
        
		var selectedFilters = component.get('v.selectedFilters') || {};
		if (event.target.value) {
			selectedFilters[event.target.dataset.filter] = [event.target.value];
		} else {
			delete selectedFilters[event.target.dataset.filter];
		}
        var categoryType=event.currentTarget.name;
        
        component.set('v.catType',categoryType);
        component.set('v.selectedFilters', selectedFilters);
        component.set('v.selected',event.currentTarget.value);
        if(component.get('v.categoryType') && categoryType.includes(component.get('v.searchFilters')[0].label)){
            helper.resetUrl(component, helper);
        }else if(component.get('v.isPartnerType') && component.get('v.catType').includes(component.get('v.searchFilters')[0].label)){
            helper.resetUrl(component, helper);
        }
        
	},

    handleSearch : function(component, event, helper) {
        helper.sendAnalyticsData(component);
        var urlParams = {
            type: component.get('v.searchType'),
            isQsearch: true
        };
        if (Object.keys(component.get('v.selectedFilters')).length) {
            urlParams.selectedFilters = component.get('v.selectedFilters');
        }
        var pageName = 'search';
        var searchUrlParams = encodeURIComponent(JSON.stringify(urlParams));
        console.log('selectedFilters',component.get('v.searchFilters')[0].label);
        //var searchUrlParams = JSON.stringify(urlParams);
        //console.log('DEBUG: Search will navigate to...   ' + '/' + pageName + '?search=' + searchUrlParams);
        console.log('partner type : ', component.get('v.isPartnerType'));
        if (component.get('v.debugMode')) {
            console.log('DEBUG: Search will navigate to...   ' + '/' + pageName + '?search=' + searchUrlParams);
            console.log('DEBUG: URL Length: ' + searchUrlParams.length);
        } else {
            //var urlEvent = $A.get("e.force:navigateToURL");
            //urlEvent.setParams({ url : '/' + pageName + '?search=' + searchUrlParams });
            //urlEvent.fire();
            if(component.get('v.catType') === undefined || (component.get('v.catType') !== undefined && component.get('v.selected')  === "")){
              console.log('at 136');  
              var urlEvent = $A.get("e.force:navigateToURL");
              urlEvent.setParams({ url : '/' + pageName + '?search=' + searchUrlParams });
              urlEvent.fire();
             }
            else if(component.get('v.categoryType') && component.get('v.catType').includes(component.get('v.searchFilters')[0].label)){
              console.log('at 142');  
                helper.resetUrl(component, helper);
                
                
                if(window.location.href != null){
                var urlStr = window.location.href;}
                var targetURL =component.get('v._href');
                var urlStr = window.location.href;
                var urlStrWithoutQueryParams = window.location.href;
                var query_string_paramter = '';
                
                if(urlStr != null || urlStr !== undefined){
                    var splittedURL = urlStr.split("?");
                    if(splittedURL != null && splittedURL.length !== undefined && splittedURL.length > 1)
                        query_string_paramter = '?' + splittedURL[1];
                    urlStrWithoutQueryParams = splittedURL[0];
                }
                
                try{
                    var a = component.get('c.testLocker');
                    $A.enqueueAction(a);
                    
                    var messageDomain = window.location.protocol + '//' + window.location.hostname + (window.location.port ? ':' + window.location.port : '');
                    
                    var messageData = {
                        analyticsType: 'click',
                        type: 'intel.salesForceHit',
                        pageType: pageType, 
                        partnerMDAId : partnerMDAId,
                        // IPA2.0 + US TWC4497-1631
                        // offeringId : offeringId,
                        element : labelHeader,
                        title : title,
                        targetURL : targetURL,
                        urlStr : urlStrWithoutQueryParams,
                        query_string_paramter : query_string_paramter,
                    };
                    window.postMessage(messageData, messageDomain);
                }catch(e){
                    console.log ("Testing");
                    console.log(e);
                } 
                
                event.preventDefault();
                event.stopPropagation();
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({ url: targetURL });
                urlEvent.fire();
                
            }else if(component.get('v.isPartnerType') && component.get('v.catType').includes(component.get('v.searchFilters')[0].label)){
                console.log('at 192');
                
                helper.resetUrl(component, helper);
                var targetURL =component.get('v._href');
                event.preventDefault();
                event.stopPropagation();
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({ url: targetURL });
                urlEvent.fire();
            }else{
                console.log('at 201');
                console.log('iscat : ', component.get('v.categoryType'), '---', component.get('v.catType'));
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({ url : '/' + pageName + '?search=' + searchUrlParams });
                urlEvent.fire();
            }
            
        }
        
    }

})