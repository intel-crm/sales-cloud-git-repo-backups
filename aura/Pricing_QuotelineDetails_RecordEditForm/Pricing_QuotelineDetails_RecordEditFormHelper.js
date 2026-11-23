({
	navigate : function(component, index) {
		/*let recordMap = component.get("v.recordFormMap");
        let recordId = component.get("v.recordId");
        recordMap[''+recordId] = component.find('recordEditForm');        
        component.set("v.recordFormMap", recordMap);*/
        
        component.set("v.recordId", component.get("v.quoteLines")[index].Id);
        component.set("v.navigatorCount", index);
	}
})