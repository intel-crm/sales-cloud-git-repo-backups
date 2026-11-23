({
	doInit : function(component, event, helper) {
		helper.doInIt(component);        
	},
    //When User searches for any record in search box
    fetchSearchedRecords: function (component, event, helper){
        helper.fetchSearchedRecords(component);
    },
    //Set Records to display on page navigation 
    handleRecordsOnPageChange : function(component, event, helper){
        helper.handleRecordsOnPageChange(component, event);
    }
})