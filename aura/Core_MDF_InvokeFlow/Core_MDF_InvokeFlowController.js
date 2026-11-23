({
	init : function (cmp) {
    /*var flow = cmp.find("flowData");
    flow.startFlow("Core_MDF_Invoke_recrdtypeslector");*/
        
       var pageReference = cmp.get("v.pageReference");
        if(pageReference != null){
           cmp.set("v.recordId", pageReference.state.c__recordId);
           cmp.set("v.isCampaignUrl", pageReference.state.c__isCampaignUrl);
          // cmp.set("v.createActivityFromCampaign", true);
        }
        var flow = cmp.find("flow");
        var inputVariables = [
        {
            name : 'recordId',
            type : 'String',
            value :cmp.get("v.recordId")
        },
         {
            name : 'IsCamapignURL',
            type : 'Boolean',
            value :cmp.get("v.isCampaignUrl")    
          }
       
        ];
        flow.startFlow("Core_MDF_Invoke_recrdtypeslector", inputVariables);
  }
})