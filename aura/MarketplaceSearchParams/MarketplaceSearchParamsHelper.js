({
    
    // Search Param Structure: .....page?search= (URL Encoded JSON String)
    // JSON Object Structre:
    //   cat: 		 category
    //	 q:        search term
    //   page:     current page
    //   type:     search type ('all', 'product', 'partner')
    //   dir:      sort direction ('asc' / 'desc')
    //   field:    sort field
    //   filters:  filters object (TODO)
    
    getUrlParams : function(component, helper) {
        //var match = window.location.href.match(/.*search\=(.*)/), urlParams = {}, params = {};
        var windowUrl = window.location.href;
        
        //console.log('URL Kartik :'+windowUrl);
        if(windowUrl.includes("search=")){
            var match = window.location.href.split('?')[1], params = {}, searchParams = {};
            
        }
        else{           
            var match = window.location.href.split('/'),params = {}, searchParams = {};
            
        }
        
        //  console.log('window.location.href :'+ window.location.href);
        //console.log('match: ' + match);
        if (match) {
            //Added if block for SEO friendly URLs 
            
            if(match.indexOf('pmp-category')!=-1){
                console.log('match for Category:'+match);
                searchParams.cat = match[match.indexOf('pmp-category')+1];
                searchParams.type = 'product';
                searchParams.contextualCat = match[match.indexOf('pmp-category')+1];
                component.set('v.hasSelectedFilter', true);
                component.set('v.contextualCat',match[match.indexOf('pmp-category')+1]);
                
                console.log('Inside Helper if');	
            }else if(match.indexOf('pmp-specification')!=-1){       //Added by Kartik for Region
                console.log('match for Region Specification:'+match);
                //searchParams.cat = match[match.indexOf('pmp-specification')+1];
                searchParams.type = 'partner';
                //searchParams.contextualCat = match[match.indexOf('pmp-specification')+1];
                component.set('v.hasSelectedFilter', true);
                component.set('v.contextualCat',match[match.indexOf('pmp-specification')+1]);
                
                console.log('Inside Helper if');
            }else if(match.indexOf('pmp-partner-program')!=-1){
                console.log('match for partner:'+match);
                searchParams.cat = match[match.indexOf('pmp-partner-program')+1];
                searchParams.type = 'partner';
                console.log('Inside Helper if for Partner program');
                component.set('v.hasSelectedFilter', false); //hasSelectedFilter should only be true for category else false.
            }
                else if(match.indexOf('pmp-partner-specialty')!=-1){
                    console.log('match for specialty:'+match);
                    //searchParams.cat = match[match.indexOf('pmp-specialty')+1];
                    searchParams.specialty = match[match.indexOf('pmp-partner-specialty')+1];  
                    console.log('SearchParams for specialty : '+searchParams.specialty);
                    searchParams.type = 'partner';
                    console.log('Inside Helper if for specialty');
                    var specidList = [];
                    specidList.push(match[match.indexOf('pmp-partner-specialty')+1]);
                    console.log('specidList : '+specidList);
                    var sFilters = {
                        'Specialty_Partner': specidList
                    };  
                    console.log('sFilters : '+sFilters);
                    
                    searchParams.selectedFilters = sFilters; //Used to select the contextual filter
                    component.set('v.hasSelectedFilter', false);
                }
            
            
                    else{
                        console.log('If match else error');
                        component.set('v.hasSelectedFilter', false);
                        try {
                            if(match.indexOf('&')!=-1 || match.indexOf('=')!=-1){
                                match = match.split('&');
                                var urlParams = {};
                                match.forEach(function(m) {
                                    m = m.replace(/\+/g, " ");	// Added by Subash for US606975
                                    urlParams[m.split('=')[0]] = decodeURIComponent(m.split('=')[1] || '');
                                    console.log(':::m:::', m);
                                });
                                if (urlParams.search) {	
                                    searchParams = JSON.parse(urlParams.search);
                                }
                            }
                            
                            
                        } catch(e) {
                            console.error('Search Params incorrect JSON format.', e);
                        }
                    }
            
            
            
            
            /*try {
                console.log('match: ' + match[1].toString());         
                
					urlParams = JSON.parse(decodeURIComponent(match[1]));                
			} catch(e) {
				console.error('Search Params incorrect JSON format.', e);
			}*/            
        }
     /*   if(searchParams.p == null){
            if(windowUrl.includes("search") || windowUrl.includes("pmp-category") || windowUrl.includes("pmp-specification") || windowUrl.includes("pmp-partner-program") || windowUrl.includes("pmp-partner-specialty")){
                searchParams.p = 'search';
            }else{
                searchParams.p = 'home';;
            }
        }*/
        
        console.log('page name in searchparams : ', searchParams.p);
        // maps JSON structure to search format
        try {
            if (searchParams.cat) params.category = String(searchParams.cat);
            //if (searchParams.PartnerProgram) params.category = String(searchParams.PartnerProgram);
            if (searchParams.specialty) params.specialty = String(searchParams.specialty);
            if(searchParams.p) params.pageName = String(searchParams.p);
            if(searchParams.isQsearch) params.isQsearch = String(searchParams.isQsearch);
            if (searchParams.q) params.keyword = String(searchParams.q);
            if (searchParams.page) params.currentPage = parseInt(searchParams.page);
            if (searchParams.type) params.searchType = String(searchParams.type);
            if (searchParams.dir) params.sortDirection = String(searchParams.dir);
            if (searchParams.field) params.sortField = String(searchParams.field);
            if (searchParams.selectedFilters) params.selectedFilters = searchParams.selectedFilters;
            if (searchParams.langCode) params.langCode = searchParams.langCode;
            if (searchParams.contextualCat) params.contextualCat = searchParams.contextualCat;
        } catch(e) {
            console.error('Error mapping search params from url.', e);
        }
        
        return params;
    },
    
    getSelectedFilters : function(component, childCatId){
        
        return new Promise($A.getCallback(function(resolve,reject){
            
            var action = component.get("c.getSelectedFilters");
            action.setParams({
                childCatId: childCatId
            });
            action.setCallback(this, function(response) {
                var status = response.getState();
                if (status === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    component.set('v.selectedFilters', returnValue);
                    resolve();
                } else if (status === "INCOMPLETE") {
                    // do something?
                } else if (status === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                        };
                    }
                } else {
                    reject('Unknown error.');
                }
            });
            $A.enqueueAction(action);
        }));
        
    }
    
})