({
    doInit: function(component, event, helper) {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.selectedDate', today);
        var currValList = [];
        var action = component.get("c.getPiklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var mapResp  = response.getReturnValue();
                
                for (var key in mapResp) { 
                    currValList.push({
                        label: key,
                        value: mapResp[key]
                    });
                    
                }
            }
            component.set("v.ProgramList", currValList);
        }
                           
       );
        $A.enqueueAction(action);
    },
     
    handleProgramChange: function (component, event, helper) {
        //Get the Selected values   
        var selectedValues = event.getParam("value");
         
        //Update the Selected Values  
        component.set("v.selectedProgramList", selectedValues);
    },
     
    getProgramInfo : function (component, event, helper){
        //Get selected Program List on button click 
        var selectedValues = component.get("v.selectedProgramList");
        var selectedDate = component.get("v.selectedDate");
        helper.getProgramInfo(component, selectedValues, selectedDate);
    }
})