({
    // uncommented by Nikhil 
    getSearchFilterData : function(component, helper) {
        component.set('v.loading', true);
        var userLangCode = $A.get("$Locale.langLocale");
        var action = component.get("c.getSearchFilterData");
        action.setParams({
            searchType:component.get("v.searchType"),
            langCode: userLangCode
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var searchFilters = response.getReturnValue();
                
                // map return value to searchFilters expected format
                component.set('v.searchFilters', searchFilters);
                component.set('v.loading', false);
                component.set('v.categoryType',searchFilters[0].isCategory);
                component.set('v.isPartnerType',searchFilters[0].isPartnerProgram);
                var params = { quickSearchFilters :  searchFilters};
                helper.dispatch(component, 'updateQuickSearchFilters', params);
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
                this.reject('Unknown error.');
            }
        });
        $A.enqueueAction(action);
    },
    
    getPageReference:function(component){
        if(component.get('v.categoryType')){
            return {
                type: "standard__recordPage",
                attributes: {
                    recordId: component.get('v.selected'),
                    objectApiName: "PMP_Category__c",
                    actionName: "view"
                }
            }
        }else if(component.get('v.isPartnerType')){
            return{
                type: "standard__recordPage",
                attributes: {
                    recordId: component.get('v.selected'),
                    objectApiName: "PMP_Partner_Program__c",
                    actionName: "view"
                }
            }
        }
    },
    
    resetUrl : function(component, helper) {
        var pageReference=this.getPageReference(component);
        var defaultUrl = "#";
        var params='';
        window.setTimeout($A.getCallback(function() {
            if (component.isValid()) {
                component.find("navService").generateUrl(pageReference)
                .then($A.getCallback(function(urlResponse) {
                    component.set('v._href',urlResponse ? urlResponse + params : defaultUrl);
                })).catch($A.getCallback(function(error) {
                    component.set('v._href',defaultUrl);
                }));
            }
        }), 100);
        
    },
    
    sendAnalyticsData : function(component){
        var currentState = component.get('v.state');
        
        //Analytics code for Quick Search
        var analyticsData = component.find("analyticsData");
        
        var type = 'click';
        var element = 'quick-search-filter';
    
        analyticsData.formAnalyticsData(type,analyticsData.formQuickSearchDetail(currentState.quickSearchFilters, component.get('v.selectedFilters'), 'click'),element);
        //Analytics code end
        
    }
})