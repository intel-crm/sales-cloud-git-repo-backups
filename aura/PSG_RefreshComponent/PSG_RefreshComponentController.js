({
    handleForceRefreshViewForLWC: function(component, event, helper) {
        console.log('handleForceRefreshViewForLWC test1');
        //component.find("temp").refresh();
        location.reload();
        console.log('handleForceRefreshViewForLWC test2');
    },
	forceRefreshView: function(component, event, helper) {
        console.log('forceRefreshView');
        //let refresh = $A.get('e.force:refreshView');
        $A.get('e.force:refreshView').fire();
        //if (refresh) refresh.fire();
    }
})