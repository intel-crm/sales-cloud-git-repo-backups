({
	recordSelectedValue: function(component, event, helper){
		var sourceComponent = event.getSource();
		var sourceId = sourceComponent.getLocalId();
		var resultMap = component.get("v.checklistMap");
		var complaintArray = component.get("v.complaintIds");
		var nonComplaintArray = component.get("v.nonComplaintIds");
		var naArray = component.get("v.naIds");
		
		if(sourceComponent.get("v.checked")==true){
			resultMap[sourceComponent.get('v.name')] = sourceComponent.getLocalId();
			component.set("v.checklistMap", resultMap);
			console.log('key' + sourceComponent.get('v.name') + 'value' + sourceComponent.getLocalId()) ;
		}

		/*if(sorceComponent.get('v.name')=='complaint'){
			if(sorceComponent.get("v.value")==true){
				resultMap[sourceComponent.get('v.text')] = sourceComponent.get('v.name');
				component.set("v.resultArray", resultMap);
				complaintArray.push(sorceComponent.get("v.text"));
			}
			else{
				var index = complaintArray.indexOf(sorceComponent.get("v.text"));
				complaintArray.splice(index, 1);        
				component.set("v.complaintIds", complaintArray);
			}
		}

		if(sorceComponent.get('v.name')=='noncomplaint'){
			if(sorceComponent.get("v.value")==true){
				nonComplaintArray.push(sorceComponent.get("v.text"));
			}
			else{
				var index = nonComplaintArray.indexOf(sorceComponent.get("v.text"));
				nonComplaintArray.splice(index, 1);        
				component.set("v.nonComplaintIds", nonComplaintArray);
			}
		}

		if(sorceComponent.get('v.name')=='na'){
			if(sorceComponent.get("v.value")==true){
				naArray.push(sorceComponent.get("v.text"));
			}
			else{
				var index = naArray.indexOf(sorceComponent.get("v.text"));
				naArray.splice(index, 1);        
				component.set("v.naIds", naArray);
			}
		}
		console.log('v.complaintIds' + component.get("v.complaintIds"));
		console.log('v.nonComplaintIds' + component.get("v.nonComplaintIds"));
		console.log('v.naIds' + component.get("v.naIds"));*/

		
	},
	recordComments: function(component, event, helper){
		var sourceComponent = event.getSource();
		var commentMap = component.get("v.commentCopy");

		commentMap[sourceComponent.get('v.name')] = sourceComponent.get('v.value');
		component.set("v.commentCopy", commentMap);
		console.log('key' + sourceComponent.get('v.name') + 'value' +  sourceComponent.get('v.value'));
	},
	recordImpactAmount: function(component, event, helper){
		var sourceComponent = event.getSource();
		var resultMap = component.get("v.impactAmount");

		resultMap[sourceComponent.get('v.name')] = sourceComponent.get('v.value');
		component.set("v.impactAmount", resultMap);
		//console.log('key' + sourceComponent.get('v.name') + 'value' +  sourceComponent.get('v.value'));
	}
})