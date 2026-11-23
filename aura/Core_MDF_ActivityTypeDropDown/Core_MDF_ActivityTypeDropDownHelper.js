({
    changeSelection : function(component,event,helper){
        var action = component.get("c.fetchActivityTypeDependentFieldsFrmMdt");
        action.setParams({"selectedActType" : component.get("v.selectedValue"),
                          "selectedActCat" : component.get("v.selectedVal")});
        action.setCallback(this, function(response){
            alert(response.getState());
            //$Label.c.Core_MDF_Newsletter_eDM_Send_FieldLabel
            //$Label.c.Core_MDF_Newsletter_eDM_Unique_open_FieldLabel
            //$Label.c.Core_MDF_Newsletter_eDM_Clicks_FieldLabel
            //$Label.c.Core_MDF_Newsletter_eDM_Send_helpTextl
            //$Label.c.Core_MDF_Newsletter_eDM_Unique_open_helpTextl
            //$Label.c.Core_MDF_Newsletter_eDM_Clicks_helpTextl
            //$Label.c.Core_MDF_NoOfImpressions
            //$Label.c.Core_MDf_NoOfClicks_FieldLabel
            //$Label.c.Core_MDF_URL_FieldLabel
            //$Label.c.Core_MDF_NoOfCirculationFieldLabel
            //$Label.c.Core_MDF_Distribution_FieldLabel
            if (response.getState() === "SUCCESS" && response.getReturnValue() != null){
                //component.set("v.wrapperInst",response.getReturnValue());
                var listVal=[];
                var wrapperlist=[];
                wrapperlist = response.getReturnValue();                
                for(var i=0;i<wrapperlist.length;i++){
                    //label values for field
                    var label = $A.get("$Label.c."+wrapperlist[i].fieldlabel);
                    wrapperlist[i].fieldlabel = label;
                }
                
                //label values for picklist values
                for(var i=0;i<wrapperlist.length;i++){
                    var pickListValues = wrapperlist[i].picklistValues;
                    for(var i=0;i<pickListValues.length;i++){
                        console.log('key  - '+pickListValues[i]);
                        var keyVal = $A.get("$Label.c."+pickListValues[i]);
                        listVal.push(keyVal);                         
                    }
                    wrapperlist[i].picklistValues = listVal;
                }                
                component.set("v.wrapperInst",wrapperlist);                
                /*for(var i=0;i<wrapperlist.length;i++){
                    if(wrapperlist[i].fieldDatatype=='Picklist'){
                        component.set("v.picklistValMap",wrapperlist[i].picklistValuesMap);
                        var listVal = [];
                        var arr = [];
                        for(var key in wrapperlist[i].picklistValuesMap){
                            var keyVal = $A.get("$Label.c."+key);
                            listVal.push(keyVal);
                            for(var key1 in wrapperlist[i].picklistValuesMap[key]){
                                arr.push(wrapperlist[i].picklistValuesMap[key][key1]);
                            }                          
                        }
                        component.set("v.mapKeys",listVal);
                        alert('listVal'+listVal);
                        alert('mapKeys'+component.get("v.mapKeys"));
                        component.set("v.listOfVal",arr);
                    }
                    var labl = $A.get("$Label.c."+wrapperlist[i].fieldlabel);
                    wrapperlist[i].fieldlabel = labl;
                    component.set("v.wrapperInst",wrapperlist);
                }*/
            }
        });
        $A.enqueueAction(action);
    },
})