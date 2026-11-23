({
	onInit : function(component) {
		var labelAction = component.get("c.getFieldMembers");
		
		// Configure response handler
		labelAction.setCallback(this, function(response) {
			var state = response.getState();
			if(component.isValid() && state === "SUCCESS") {
				component.set("v.fieldMap", response.getReturnValue());
				console.log('@@FieldSet::'+JSON.stringify(response.getReturnValue()));
				// Prepare the action to load Registration Request record
				var action = component.get("c.getRegRecord");
				console.log('recordId: '+component.get("v.recordId"));
				action.setParams({
					"recordId": component.get("v.recordId"),
				});
				
				// Configure response handler
				action.setCallback(this, function(response) {
					var state = response.getState();
					if(component.isValid() && state === "SUCCESS") {
						var result = response.getReturnValue();
						if(result.hasOwnProperty("PRM_Matching_Contact__c")){
							component.set("v.isMatchingContact", true);
						}
						component.set("v.regRequest", response.getReturnValue());
                        console.log('Response::'+JSON.stringify(result));
						var labelsMap = component.get("v.fieldMap");
                        console.log('labelsMap::'+JSON.stringify(labelsMap));
                        var strList = [];
						for(var x in labelsMap){
							strList.push(x);
						}
						component.set("v.strList", strList);
                        console.log('StrList::'+JSON.stringify(component.get("v.strList")));
						var displayFieldsList = [];
						strList.forEach(function(entry){
							var displayFields = {};
							if(entry == 'PRM_Email_Verification_Criteria__c'){
								displayFields = {name: entry,label: labelsMap[entry], result: result.PRM_Email_Verification_Criteria__c};
							}
							else if(entry == 'PRM_DeDup_Criteria__c'){
								displayFields = {name: entry, label: labelsMap[entry], result: result.PRM_DeDup_Criteria__c};
							}
							else if(entry == 'PRM_Legal_Agreement_Criteria__c'){
							    displayFields = {name: entry, label: labelsMap[entry], result: result.PRM_Legal_Agreement_Criteria__c};
							}
                            else if(entry == 'PRM_Matching_Contact__c'){
                                displayFields = {name: entry, label: labelsMap[entry], result: result.PRM_Matching_Contact__c};   
                            }
							displayFieldsList.push(displayFields);
						});
                        displayFieldsList.sort((a, b) => (a.result < b.result) ? 1 : -1);
						component.set("v.fieldList", displayFieldsList);
						console.log(`Display field list ${JSON.stringify(component.get("v.fieldList"))}`);
                    } else {
						console.log('Problem getting Registration record, response state: ' + state);
					}
				});
				$A.enqueueAction(action);
			}
		});
		$A.enqueueAction(labelAction);
	},

	displayTooltip : function(component, event) {
	    var eventId = event.currentTarget;
	    var nextDivEl = eventId.firstChild.lastChild;
	    console.log(nextDivEl.className);
	    nextDivEl.classList.remove('slds-hide');
	    console.log(nextDivEl.className);
    },
	
	hideTooltip : function(component, event) {
		var eventId = event.currentTarget;
	    var nextDivEl = eventId.firstChild.lastChild;
	    console.log(nextDivEl.className);
	    nextDivEl.classList.add('slds-hide');
	    console.log(nextDivEl.className);
	}


});