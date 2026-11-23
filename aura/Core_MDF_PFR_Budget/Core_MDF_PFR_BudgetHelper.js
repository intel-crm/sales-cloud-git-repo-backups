({
	doinitHelper : function(component,event,helper) {
         //alert('helper');
		 //Call method fetchBudgetCampaignPFRDetails from Apex Controller
            var action = component.get("c.fetchBudgetCampaignPFRDetails");
            action.setParams({
                pfrId : component.get("v.recordId")
            });
            action.setCallback(this, function(response){
                //alert('NZ-->Response: '+response.getState());
                if(response.getState() === 'SUCCESS'){
                    var result = response.getReturnValue();
                    component.set("v.wrapperList", result);
                    for(var outerIndexIterator in result.campaignIdPFRWrapperList){
                        for(var innerIndexIterator in result.campaignIdPFRWrapperList[outerIndexIterator].pfrList){
                            result.campaignIdPFRWrapperList[outerIndexIterator].pfrList[innerIndexIterator].linkName = '/'+result.campaignIdPFRWrapperList[outerIndexIterator].pfrList[innerIndexIterator].Id;
                            //alert('campURL: '+ result.campaignIdPFRWrapperList[outerIndexIterator].pfrList[innerIndexIterator].linkName );
                        }
                    }
                    component.set("v.innerWrapperList", result.campaignIdPFRWrapperList);
                    component.set("v.dataPresent", true);
                }else{
                   // alert('fail');
                    component.set("v.dataPresent", false);
                }
            });
            $A.enqueueAction(action);
	}
})