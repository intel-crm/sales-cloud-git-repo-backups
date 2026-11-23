({
    init : function(component, event, helper) {
        var flow = component.find("flowData");
        var inputVariables = [
            {
                name : "RecordId",
                type : "Text",
                value : component.get("v.recordId")
                
            }
            
        ];
        flow.startFlow("Core_FeedBackForm");
        
    }
})