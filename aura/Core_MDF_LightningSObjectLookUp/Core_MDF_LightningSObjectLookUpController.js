({
    doInit: function(component, event, helper) {
        component.set('v.staticResourceForSearch','$Resource.Core_MDF_SLDS262/icons/utility-sprite/svg/symbols.svg#search');
        component.set('v.staticResourceForClose','$Resource.Core_MDF_SLDS262/icons/utility-sprite/svg/symbols.svg#close');
        //helper.doInit(component, event, helper);
    },
    /**
     * Search an SObject for a match
     */
	search : function(cmp, event, helper) {
        console.log('Inside Search:::');
		helper.doSearch(cmp);        
    },

    /**
     * Select an SObject from a list
     */
    select: function(cmp, event, helper) {
    	helper.handleSelection(cmp, event);
    },
    
    /**
     * Clear the currently selected SObject
     */
    clear: function(cmp, event, helper) {
        console.log('cmp::::'+cmp);
    	helper.clearSelection(cmp);    

    },
    clear2: function(cmp, event, helper) {
        console.log('Inside clear2');
    	helper.clearSelection2(cmp);    
    },
    select2: function(cmp, event, helper) {
        console.log('Inside select2');
    	helper.handleSelection2(cmp, event);
        helper.handleSelection3(cmp, event);	
   },
   
})