({
	//Method records the answers for all the checklist values
	recordSelectedValue: function(component, event){
		var sourceComponent = event.getSource();
		var resultMap = component.get("v.checklistMap");
		var impactComp = component.find("impactamount");
		var commentsComp = component.find("commentcopy");
		var impactAmountMap = component.get("v.impactAmount");
		var commentMap = component.get("v.commentCopy");
		
		//Checklist Enhancements v1 - US458779: [Case: Checklists] Impact Amount Prevention / Requirement
		var i=0;	
		if(sourceComponent.get("v.checked")==true){
			resultMap[sourceComponent.get('v.name')] = sourceComponent.getLocalId();
			component.set("v.checklistMap", resultMap);
			
			if(sourceComponent.getLocalId()=='compliant'){
				//Impact Amount to be disabled when Compliant Radio button is clicked
				//Checklist Enhancements v2 - US497414: Enable optional Impact Amount if Checklist is Compliant
				for(i in impactComp){
					var record = impactComp[i];
					if(record.get("v.name") == sourceComponent.get('v.name')){
						record.set("v.required",false);
						record.set("v.placeholder", "Amount can include 2 decimal places");
						record.set("v.title","Amount can include 2 decimal places");
                        record.set("v.step","0.01");
						//impactAmountMap[record.get('v.name')] = record.get('v.value');
						//component.set("v.impactAmount", impactAmountMap);	
						record.set("v.disabled",false);
						$A.util.removeClass(record, "slds-has-error"); // remove red border
					}
				}
				//Comments copy to be re-enabled when Radio button switches from NA to Compliant
				for(i in commentsComp){
					var record = commentsComp[i];
					if(record.get("v.name") == sourceComponent.get('v.name')){
						record.set("v.placeholder", "Enter optional comments here...");
						record.set("v.title","Enter optional comments here...");
						record.set("v.value","");
						commentMap[sourceComponent.get('v.name')] = sourceComponent.get('v.value');
						component.set("v.commentCopy", commentMap);
						record.set("v.disabled",false);
					}
				}	
			}
			if(sourceComponent.getLocalId()=='noncompliant'){
				//Impact Amount to be mandatory when Non-Compliant Radio button is clicked
				for(i in impactComp){
					var record = impactComp[i];
					if(record.get("v.name") == sourceComponent.get('v.name')){
						record.set("v.required",true);
						record.set("v.disabled",false);
						record.set("v.placeholder", "Amount can include 2 decimal places");
						record.set("v.title","Amount can include 2 decimal places");
                        record.set("v.step","0.01");
						$A.util.addClass(record, "slds-has-error");
						record.set("v.messageWhenValueMissing", " ");	
					}
				}
				//Comments copy to be re-enabled when Radio button switches from NA to Non-Compliant
				for(i in commentsComp){
					var record = commentsComp[i];
					if(record.get("v.name") == sourceComponent.get('v.name')){
						record.set("v.placeholder", "Enter optional comments here...");
						record.set("v.title","Enter optional comments here...");
						record.set("v.value","");
						commentMap[sourceComponent.get('v.name')] = sourceComponent.get('v.value');
						component.set("v.commentCopy", commentMap);
						record.set("v.disabled",false);
					}
				}
			}
			if(sourceComponent.getLocalId()=='na'){
				//Impact Amount to be disabled when NA Radio button is clicked
				for(i in impactComp){
					var record = impactComp[i];
					if(record.get("v.name") == sourceComponent.get('v.name')){
						record.set("v.placeholder", "");
						record.set("v.title","");
						record.set("v.value","");
						impactAmountMap[record.get('v.name')] = record.get('v.value');
						component.set("v.impactAmount", impactAmountMap);
						record.set("v.disabled",true);
						record.set("v.required",false);
						$A.util.removeClass(record, "slds-has-error");
					}
				}
				//Comments copy to be disabled when NA Radio button is clicked
				for(i in commentsComp){
					var record = commentsComp[i];
					if(record.get("v.name") == sourceComponent.get('v.name')){
						
						record.set("v.placeholder", "");
						record.set("v.title","");
						record.set("v.value","");
						commentMap[sourceComponent.get('v.name')] = sourceComponent.get('v.value');
						component.set("v.commentCopy", commentMap);
						record.set("v.disabled",true);
					}
				}	
			}
		}
	},
	//Method records the comments provided for the checklist values
	recordComments: function(component, event){
		var sourceComponent = event.getSource();
		var commentMap = component.get("v.commentCopy");

		commentMap[sourceComponent.get('v.name')] = sourceComponent.get('v.value');
		component.set("v.commentCopy", commentMap);
	},
	//Method records the Impact Amount for the checklist values
	recordImpactAmount: function(component, event){
		var sourceComponent = event.getSource();
		var impactAmountMap = component.get("v.impactAmount");
		
		impactAmountMap[sourceComponent.get('v.name')] = sourceComponent.get('v.value');
		component.set("v.impactAmount", impactAmountMap);		

	}
})