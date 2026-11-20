({
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
    	helper.clearSelection(cmp);    

    },
    clear2: function(cmp, event, helper) {
    	helper.clearSelection2(cmp);    
    },
    select2: function(cmp, event, helper) {
    	helper.handleSelection2(cmp, event);
        helper.handleSelection3(cmp, event);	
   },
   
})