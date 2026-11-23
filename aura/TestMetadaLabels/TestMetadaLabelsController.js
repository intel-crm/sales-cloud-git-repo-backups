({
    getMetadata: function(component,event){
        var action=component.get("c.getBulkTextValues");
        var labelList=["Core_MDF_TechnicalProgramName","TestHp"];
        action.setParams({
            labelList : labelList
        });
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS")
                var value=response.getReturnValue();
            var metaData=[];
            for(var key in value){
                metaData.push({val:value[key],key:key});
            }
            console.log("Value JS",metaData);
            component.set("v.labelName1",metaData);
        });
    $A.enqueueAction(action);
    },
    getLabel: function(component,event){
        var action=component.get("c.getValue");
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS")
                var value=response.getReturnValue();
            component.set("v.labelName",value);
        });
        $A.enqueueAction(action);	
    }
   /* getBulkMetadata:function(component,event){
        var action=component.get("c.getBulkTextValues");
        action.setParams({
            label : "Core_MDF_RetailProgram"
        });
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS")
                var value=response.getReturnValue(); 
            component.set("v.labelName",value);
        });
    $A.enqueueAction(action);
    }*/
})