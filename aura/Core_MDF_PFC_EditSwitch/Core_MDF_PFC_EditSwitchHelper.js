({
    fetchClaimRecord: function (component) {
        //this.isInternalAuditUser(component);
        var action;
        console.log('component.get("v.isClone")', component.get("v.isClone"));
        if (component.get("v.isClone")) {
            action = component.get("c.prepareCloneData");
        } else {
            action = component.get("c.fetchClaimById");
        }
        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            /*   if(state === "SUCCESS" && result.getReturnValue() != null && result.getReturnValue().claimObj != null && (result.getReturnValue().isPartner == true && result.getReturnValue().CRRPositiveClaim == true)){
                   component.set("v.accessErrorMsg", $A.get('$Label.c.Core_MDF_No_Permission'));
               }*/

            if (state === "SUCCESS" && result.getReturnValue() != null && result.getReturnValue().claimObj != null && ((result.getReturnValue().activityBudgetType != 'Co-Engineering' && result.getReturnValue().countryMap != null) || (result.getReturnValue().activityBudgetType == 'Co-Engineering'))) {
                //let cloneOrEditClaimWrapper = result.getReturnValue();
                //if ((!$A.util.isUndefinedOrNull(cloneOrEditClaimWrapper) && cloneOrEditClaimWrapper.isValidCloneOrEditUser == true && component.get("v.isClone")) || !component.get("v.isClone")) {
                    //component.set("v.isValidCloneOrEditUser", true);
                    var claimObject = result.getReturnValue().claimObj;
                    var countryNameMap = result.getReturnValue().countryMap;
                    var activitySubType = result.getReturnValue().activitySubTypeMap;
                    var activityBudgetType = result.getReturnValue().activityBudgetType;
                    let kpiPLValueToFieldAPIName = result.getReturnValue().kpiPLValueToFieldAPIMap;
                    let kpiPLValueToFieldLabel = result.getReturnValue().kpiPLValueToFieldLabelMap;
                if(countryNameMap != null && countryNameMap != undefined) {
                    for (let index in countryNameMap) {
                        if (!$A.util.isUndefinedOrNull(index) && !$A.util.isUndefinedOrNull(countryNameMap[index])) {
                            component.set("v.activityCountriesMap", ({ key: index, value: countryNameMap[index] }));
                        }
                    }
                }
                if(activitySubType != null && activitySubType != undefined) {
                    for (let index2 in activitySubType) {
                        if (!$A.util.isUndefinedOrNull(index2) && !$A.util.isUndefinedOrNull(activitySubType[index2])) {
                            component.set("v.activitySubTypesMap", ({ key: index2, value: activitySubType[index2] }));
                        }
                    }
                }
                    if (!$A.util.isUndefinedOrNull(activityBudgetType)) {
                        component.set("v.activityBudgetType", activityBudgetType);
                    }
                    /*component.set("v.kpiPLValueToFieldAPIName", kpiPLValueToFieldAPIName);
                    component.set("v.kpiPLValueToFieldLabel", kpiPLValueToFieldLabel);*/
                    component.set("v.simpleNewClaim", claimObject);
                     component.set("v.claimDetailsOnLoad", JSON.parse(JSON.stringify(claimObject)));
                /*} else {
                    component.set("v.isValidCloneOrEditUser", false);
                    component.set("v.accessErrorMsg", $A.get('$Label.c.Core_MDF_CloneAccessError'));
                   if(!component.get("v.isClone")) {
                       component.set("v.showErrorModalOnEditClaim", true);
                   }
                }*/
            }

        });
        $A.enqueueAction(action);
    },
    //When it is a CRR Positive type of claim and user clicks on Edit action and then error message comes in a POP up
    // on click of the close button of the POP up this Close function is called
    /*  closeModelBox : function(component){
          var navEvt = $A.get("e.force:navigateToSObject");
          navEvt.setParams({
              recordId: component.get("v.recordId"),
              slideDevName: "detail"
          });
          navEvt.fire();
          $A.get("e.force:closeQuickAction").fire();
      }*/
})