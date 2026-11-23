({
/*	handlecreate : function(component, event, helper) {
		//component.find("recordEditForm").submit();
		var createRecordEvent = $A.get("e.force:createRecord");
    createRecordEvent.setParams({"entityApiName": "Order"
    });
    createRecordEvent.fire();
	}*/
    handlecreate : function(component, event, helper) {
    var editRecordEvent = $A.get("e.force:editRecord");
    editRecordEvent.setParams({
       //  "recordId": component.get("v.Order.Id")
        "recordId" : '8012D0000016T7JQAU'
   });
    editRecordEvent.fire();
}
})