({
   
    myAction : function(component, event, helper) 
    {
        /*var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'C__DisclaimerPage'
            },
            state: {}
        };*/
        
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                componentName: 'C__DisclaimerPage',
            },
             "state": {}
        };
        component.set("v.pageReference", pageReference);
        console.log('entered in MyAction function');
        component.set('v.columns', [
            {label: 'Claim Batch record ID', fieldName: 'LinkName', type: 'url' ,  editable: false,typeAttributes:{ label:{fieldName:'Name'},target:'_blank'}},
            //{label: 'Claim Batch Record Status', fieldName: 'Core_MDF_Processing_Status_Nm__c', type: 'text' ,  editable: true},
            {label: 'Activity#', fieldName: 'Core_MDF_Activity_Nbr__c', type: 'text' ,  editable: false},
            //{label: 'Claim Name', fieldName: 'Core_MDF_Claim_Nm__c', type: 'string' ,  editable: false,typeAttributes:{ label:'ClaimName',Name:'Core_MDF_Claim_Nm__c',disabled:false}},
            // {label: 'Claim Reference Number', fieldName: 'Core_MDF_Claim_Reference_Nbr__c', type: 'text' ,  editable: false},
            // {label: 'Created By', fieldName: 'CreatedBy', type: 'text' ,  editable: false},
            // {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {   day: 'numeric',  month: 'numeric',   year: 'numeric',  hour: '2-digit',  minute: '2-digit', hour12: true}},
            {label: 'Execution Start Date', fieldName: 'Core_MDF_Ad_Run_Start_Dt__c', type: 'date', typeAttributes: {   day: 'numeric',  month: 'numeric',   year: 'numeric',  hour: '2-digit',  minute: '2-digit', hour12: true}},
            {label: 'Execution End Date', fieldName: 'Core_MDF_Ad_Run_End_Dt__c', type: 'date', typeAttributes: {   day: 'numeric',  month: 'numeric',   year: 'numeric',  hour: '2-digit',  minute: '2-digit', hour12: true}},
            {label: 'Upload POP Documents', fieldName: 'UploadDocs', type: 'button' ,  editable: false,typeAttributes:{ label:'Upload POP Documents',Name:'Core_MDF_Upload_POP_Document__c',disabled:false}}
            
        ]);
        var ClaimStageRecList = component.get("c.getRelatedStageRecordList");
        //This is to fetch record type meta data map and set activity record type developer name
        //this.fetchRecordTypeMetaData(component);
        console.log('#####');
        console.log(component.get("c.getRelatedStageRecordList"));
        ClaimStageRecList.setParams
        ({
            recordId: component.get("v.recordId")
        });
        console.log(component.get("v.recordId"));
        console.log('good'+ClaimStageRecList);
        ClaimStageRecList.setCallback(this, function(data) 
                                      {
                                          if(data.getState()=='SUCCESS'){ //&& data.getReturnValue() != null){
                                              var rows=data.getReturnValue();
                                              for(var i=0;i<rows.length;i++){
                                                  var row=rows[i];
                                                  row.LinkName='/'+row.Core_MDF_Upload_POP_Document__c;
                                                  row.LinkName='/'+row.Id;
                                                  //row.LinkName='/'+row.Core_MDF_Claim_Nm__c;
                                              }
                                              /*if(row.CreatedById){
                                                      row.CreatedBy=row.CreatedBy.Name;
                                                      console.log('createdBy'+row.CreatedBy);
                                                  }*/
                                              component.set("v.ClaimStageRecList", rows);
                                          }
                                      });
        $A.enqueueAction(ClaimStageRecList);
    },
    
    UploadAction: function(component,event,helper){
        component.set("v.isModalOpen", true);  
        /*var recordId=event.getParam('row').Id;
        var actionName=event.getParam('action').Name;
        console.log('rceordId'+recordId);
        console.log('actionName'+actionName);
        var pageReference = component.get("v.pageReference");
        //console.log('pagereference'+component.get("v.pageReference"));
        
        
           var navService = component.find("navService");
            //alert(JSON.stringify(pageReference));
                //event.preventDefault();
                alert(navService.navigate(pageReference));
                navService.navigate(pageReference);*/
    },     
    closeModel: function(component, event, helper) {      
        // Set isModalOpen attribute to false       
        component.set("v.isModalOpen", false);  
    },
    //This helper function is used to fetch all record type meta data map and set activity record type developer name
    fetchRecordTypeMetaData: function (component) {
        var action = component.get("c.fetchRecordTypeMetaData");
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS" && a.getReturnValue() != null) {
                //Setting record Type map
                component.set('v.recordTypeMap', a.getReturnValue());
                var activityId = component.get('v.activityId');
                if (!$A.util.isUndefined(activityId) && !$A.util.isEmpty(activityId)) {
                    component.set('v.simpleNewClaim.RequestId', activityId);
                }
            }
            /*else {
                this.handleServerExceptions(component, a.getReturnValue());
            }*/
        });
        $A.enqueueAction(action);
    },
})