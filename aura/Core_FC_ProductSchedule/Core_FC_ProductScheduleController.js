({
    doInit : function(component, event, helper) {
        component.set("v.loaded", false);
        var action = component.get("c.initializeForecast");
        action.setParams({
            oppId : component.get("v.recordId")
        });
        
        
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.fcWrapper", result);
                component.set("v.fcCustomSetting", result.fcCustomSetting);
                component.set("v.oppRecord", result.oppRecord);
                component.set("v.fcDisplayWrapList", result.fcDisplayWrapList);
                component.set("v.dummyFcDisplayWrapList", result.dummyFcDisplayWrapList);
                component.set("v.quarterStatusSet", result.quarterStatusSet);
                component.set("v.dummyQuarterStatusSet", result.dummyQuarterStatusSet);
                component.set("v.oppCoverage", result.oppRecord.Core_Opportunity_Coverage_Nm__c);
                component.set("v.coverageType", result.oppRecord.Core_Coverage_Type_Nm__c);
                component.set("v.isOppLocked", result.isOppLocked);
                component.set("v.totalQuantityError", result.totalQuantityError);
                component.set("v.QuartersNotAligned", result.isQuartersAligned);
                component.set("v.isPartner", result.isPartnerUser);
                component.set("v.negativeErrorMessage", result.negativeQuantityError);
                // TWC3123-5786 Start
                if(result.oppRecord.Core_Opportunity_Coverage_Nm__c == "Partner-Led Opportunity" && result.oppRecord.Core_Coverage_Type_Nm__c == 'Deal Registration' && result.oppRecord.RecordType.Name == 'Deal Opportunity' ){
                    component.set("v.isPCCDealOpp", false);
                }
                
                
                // TWC3123-5786 End
                if(result.fcDisplayWrapList.length > 0){
                    var qtTotalList = [];
                    for(var key in result.quarterTotalMap){
                        qtTotalList.push({value:result.quarterTotalMap[key], key:key});
                    }
                    component.set("v.quarterTotalList", qtTotalList);
                    var qtMap = new Map();
                    var qtStatusSet = result.quarterStatusSet;
                    for(var i=0; i<qtStatusSet.length; i++){
                        qtMap[qtStatusSet[i].quarterName] = qtStatusSet[i].quarterStatus;
                    }
                    component.set("v.myMap",qtMap);
                }
            }else{
                const errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.toastMessage(component, "error",  errors[0].message);
                    }
                }
            }
            component.set("v.loaded", true);
        });
        $A.enqueueAction(action);
        $A.enqueueAction(component.get('c.get6QPSData'));
    },  
    get6QPSData : function(component, event, helper){
        //Checking First Customer ShipDate and 6QPS Alignment
        var action = component.get("c.quarterAlignmentCheck");
        action.setParams({
            oppId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var resp = response.getReturnValue();
                component.set("v.quarterMisALign",resp);
            }
            else{
                const errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.toastMessage(component, "error",  errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    scheduleQuarter : function(component, event, helper){
        //TWC3123-5786 Start
        if(component.get("v.isOppLocked") && component.get("v.oppCoverage") == "Partner-Led Opportunity" && component.get("v.coverageType") == "Deal Registration"
           && component.get("v.oppRecord.RecordType.Name") == 'Deal Opportunity'){
                helper.toastMessage(component, "error", $A.get("$Label.c.Core_6QPS_QLI_Not_Approved_Error"));
        }
        //TWC3123-5786 End
        else{
        let fcWrapper = component.get("v.fcWrapper");
        if(!fcWrapper.isFirstCustmerShipDateEmpty)
            helper.toastMessage(component, "error", $A.get("$Label.c.Core_First_Customer_Date_Error"));
        else
            component.set("v.isSchedQuarter", true);
        }
    },
    addQuarterFunction : function(component, event, helper){
        //TWC3123-5786 Start
        if(component.get("v.isOppLocked") && component.get("v.oppCoverage") == "Partner-Led Opportunity" && component.get("v.coverageType") == "Deal Registration"
           && component.get("v.oppRecord.RecordType.Name") == 'Deal Opportunity'){
                helper.toastMessage(component, "error", $A.get("$Label.c.Core_6QPS_QLI_Not_Approved_Error"));
        }//TWC3123-5786 End
        else{
            if(component.get("v.fcWrapper.canAddQuarter") == true){
                component.set("v.isAddQuarter", true);
        }
		else{
            if(component.get("v.fcWrapper.oppProductCount") > 0){
                if(component.get("v.fcWrapper.oppProductCount") == component.get("v.fcWrapper.invalidProductCount")){
                    helper.toastMessage(component, "error", $A.get("$Label.c.Core_FC_lost_AddQuarter"));
                }
                else{
                    helper.toastMessage(component, "error", $A.get("$Label.c.Core_FC_Max_AddQuarter"));
                }
            }
            else{
                helper.toastMessage(component, "error", $A.get("$Label.c.Core_FC_NoProd_AddQuarter"));
            }
        }
    }
    },
    editQuarterFunction : function(component, event, helper){
        if(component.get("v.isOppLocked") && component.get("v.oppCoverage") == "Partner-Led Opportunity" && component.get("v.coverageType") == "Deal Registration"
           && component.get("v.oppRecord.RecordType.Name") == 'Deal Opportunity'){
                helper.toastMessage(component, "error", $A.get("$Label.c.Core_6QPS_QLI_Not_Approved_Error"));
        }
        else{
            if(component.get("v.fcWrapper.canEditQuarter") == true){
                component.set("v.isEditQuarter", true);
            }else{
                if(component.get("v.fcWrapper.oppProductCount") > 0){
                    if(component.get("v.fcWrapper.oppProductCount") == component.get("v.fcWrapper.invalidProductCount")){
                        helper.toastMessage(component, "error", $A.get("$Label.c.Core_FC_Lost_EditQuarter"));
                    }else{
                        helper.toastMessage(component, "error", $A.get("$Label.c.Core_FC_Approve_EditQuarter"));
                    }
                }else{
                    helper.toastMessage(component, "error", $A.get("$Label.c.Core_FC_DelProd_EditQuarter"));
                }
            }
        }
    },
    handlePostWinDelete : function(component, event, helper){
        component.set("v.loaded", false);
        var fcWrapList = component.get("v.fcDisplayWrapList");
        let toBeDeletedfcRecs = [];
        for(var i=0; i<fcWrapList.length; i++){
            let check = fcWrapList[i].isDeleteSelected;
            if(check){
                toBeDeletedfcRecs.push(fcWrapList[i].productId);
            }  
        }
        var action = component.get("c.deletePostWinProducts");
        action.setParams({
            listfcRec : JSON.stringify(toBeDeletedfcRecs)
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.canShowPostWinDelete",false);
                helper.toastMessage(component, "success",$A.get("$Label.c.Core_Post_Win_Delete_Success"));
                $A.get('e.force:refreshView').fire();
            }else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.toastMessage(component, "error", errors[0].message);
                    }
                }  
                component.set("v.loaded", true);
            }
        });
        $A.enqueueAction(action);
    },
    handlePostWinCheckbox : function(component, event, helper){
        var fcWrapList = component.get("v.fcDisplayWrapList");
        let showDeletePostWin = false;
        for(var i=0; i<fcWrapList.length; i++){
            let check = fcWrapList[i].isDeleteSelected;
            if(check){
                showDeletePostWin = true;
                component.set("v.canShowPostWinDelete",fcWrapList[i].isDeleteSelected);
                break;
            }
        }
        if(!showDeletePostWin){
            component.set("v.canShowPostWinDelete",showDeletePostWin);
        }
    },
    
    saveAllQuarter : function(component, event, helper){
        var actType = '';
        var comingFrom = '';
        var fcWrapList = [];
        var fcWrapListAdd = [];
        var fcWrapListEdit = [];
        var oliRowNum='';
        var fcWrapList1 = [];
        var ProductNumberListAura = [];
		var fcWrapListForEditQty = [];
		var fcWrapListForEditQtyDummy = [];
        var invalidLineItems = [];
        component.set("v.QuantityEditRestriction", false);
        //Duplicate qtr fix - poc - start
        var saveBtn = event.getSource();
        saveBtn.set("v.disabled", true);
        //Duplicate qtr fix - poc - end
        if(component.get("v.isAddQuarter") == true){
                actType = 'addQuarter';
                fcWrapList = component.get("v.dummyFcDisplayWrapList");
            	
           		
            }else{
                actType = 'editQuarter';
                fcWrapList = component.get("v.fcDisplayWrapList");
            }
            for(var i=0; i<fcWrapList.length; i++){
                for(var j=0; j<fcWrapList[i].scheduledList.length; j++){
                    if(fcWrapList[i].scheduledList[j].scheduledQuantity == ""){
                        fcWrapList[i].scheduledList[j].scheduledQuantity = 0;
                    }
                     else if( isNaN(fcWrapList[i].scheduledList[j].scheduledQuantity) || (fcWrapList[i].scheduledList[j].scheduledQuantity < 0) || (fcWrapList[i].scheduledList[j].scheduledQuantity % 1 !== 0)){
                          invalidLineItems.push(i+1); 
                        
                        }
                }
            }
             invalidLineItems = [...new Set(invalidLineItems)];

        if(invalidLineItems.length > 0) {
    helper.toastMessage(component, "error", component.get("v.negativeErrorMessage") + invalidLineItems);
    return;
        }

        //TWC3123-5771 Start
        if(component.get("v.isAddQuarter") == true){
                actType = 'addQuarter';
                fcWrapList1 = component.get("v.dummyFcDisplayWrapList");
            }else{
                actType = 'editQuarter';
                fcWrapList1 = component.get("v.fcDisplayWrapList");
            }
        component.set("v.schQuantityError",false);
        //TWC3123-6665 Commented as part ofTWC3123-6665
        /*for(var i=0; i<fcWrapList1.length; i++){
            var rowNum;
            var totschedQty = 0;
            var k=0;
            
            for(var j=0; j<fcWrapList1[i].scheduledList.length; j++){
                totschedQty = totschedQty+parseInt(fcWrapList1[i].scheduledList[j].scheduledQuantity);
                if(component.get("v.oppCoverage") == "Partner-Led Opportunity" &&
                    component.get("v.coverageType") == "Deal Registration"   &&
                    component.get("v.oppRecord.RecordType.Name") == 'Deal Opportunity'){
                if(totschedQty > fcWrapList1[i].scheduledList[j].oppProduct.Quantity){
                    k=i+1;
            		component.set("v.schQuantityError",true);
                }
                }
            }
            if(k>0){
                rowNum = k;
                if(oliRowNum != ''){
                     oliRowNum = oliRowNum+'/'+'Item#'+rowNum;            
                }
                else{
                    oliRowNum = 'Item#'+rowNum;
                }
            }
            k=0;
        } */ 
        
		//Devashish
        if (component.get("v.oppCoverage") == "Partner-Led Opportunity" && component.get("v.coverageType") == "Deal Registration") 
        {
            var errorMessage1;
            var errorMessage2;
            var oliRowNumLess='';//TWC3123-6665
        
            if(component.get("v.isAddQuarter") == true){
                component.set("v.dummyFcDisplayWrapList", fcWrapList);
                fcWrapListForEditQtyDummy = component.get("v.dummyFcDisplayWrapList");
            }else{
                component.set("v.fcDisplayWrapList", fcWrapList);
                fcWrapListForEditQty = component.get("v.fcDisplayWrapList");
            }
            component.set("v.canShowPostWinDelete",false);
            component.set("v.loaded", false);
            
            //TWC3123-6665 start
           var action = component.get("c.checkQuantityValidation");
          action.setParams({
            fcDisplayWrapStr: JSON.stringify(fcWrapListForEditQty),
			dummyFcDisplayWrapStr : JSON.stringify(fcWrapListForEditQtyDummy),
            oppObject: component.get("v.oppRecord"),
			actionType : actType
          });
            
          action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
              var ItemNoList;
              var result = response.getReturnValue();
                 console.log('Aura result is:'+result);
                if(result.length !=0)
				{
					for(var l=0; l<result.length; l++)
					{                    
						if(oliRowNumLess != ''){
						 oliRowNumLess = oliRowNumLess+'/'+'Item#'+result[l]+' ';
					}
					else{
						oliRowNumLess = 'Item#'+result[l]+' ';
						}
					}
                    component.set("v.schQuantityError",true);
                }
			 
            } else {
              const errors = response.getError();
              if (errors) {
                if (errors[0] && errors[0].message) {
                    component.set("v.isEditQuarter", false);
                  helper.toastMessage(component, "error", errors[0].message);
                }
              }
            }
          });
          $A.enqueueAction(action);
          //TWC3123-6665 end
            
          var action = component.get("c.checkQLDates");
          action.setParams({
            fcDisplayWrapStr: JSON.stringify(fcWrapListForEditQty),
			dummyFcDisplayWrapStr : JSON.stringify(fcWrapListForEditQtyDummy),
            opp: component.get("v.oppRecord"),
			actionType : actType,
            comingFrom : 'Aura'
          });
            
          action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
              var result = response.getReturnValue();
			  component.set("v.QLQuarterList", result);
                var oliRowNum1='';
                ProductNumberListAura = component.get("v.QLQuarterList");
                if(ProductNumberListAura.length !=0)
				{					
					for(var l=0; l<ProductNumberListAura.length; l++)
					{                    
						if(oliRowNum1 != ''){
						 oliRowNum1 = oliRowNum1+'/'+'Item #'+ProductNumberListAura[l];
					}
					else{
						oliRowNum1 = 'Item #'+ProductNumberListAura[l];
						}
					}
                    component.set("v.QuantityEditRestriction", true);
					
                    errorMessage1 = oliRowNum1+$A.get("$Label.c.Core_PCC_6QPSEditQtyRestriction");
                    errorMessage2 = $A.get("$Label.c.Core_Oppo_Sch_prod_Qty_Ck")+' '+oliRowNumLess;//TWC3123-6665  changed Core_6QPS_Schedule_Error/oliRowNum
                    helper.showToast(component, event, errorMessage1, errorMessage2);

              }
                else if(component.get("v.schQuantityError") == true){
            helper.toastMessage(component, "error", $A.get("$Label.c.Core_Oppo_Sch_prod_Qty_Ck")+' '+oliRowNumLess);//TWC3123-6665 changed Core_6QPS_Schedule_Error/oliRowNum           
        }
                else{
                    component.set("v.loaded", false);
            if(component.get("v.isAddQuarter") == true){
                component.set("v.dummyFcDisplayWrapList", fcWrapList);
                fcWrapListAdd = fcWrapList;
            }else{
                component.set("v.fcDisplayWrapList", fcWrapList);
                fcWrapListEdit = fcWrapList;
            }
            component.set("v.canShowPostWinDelete",false);
            component.set("v.loaded", false);

                    var action = component.get("c.saveAll");
					action.setParams({
						fcDisplayWrapStr : JSON.stringify(fcWrapListEdit),
						dummyFcDisplayWrapStr : JSON.stringify(fcWrapListAdd),
						opp : component.get("v.oppRecord"),
						actionType : actType
					});
					action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    component.set("v.fcDisplayWrapList", fcWrapList);// add newly 18th Oct
                    console.log('Before success toast');
                    helper.toastMessage(component, "success", $A.get("$Label.c.Core_FC_SaveAll"));
                    $A.get('e.force:refreshView').fire();
                }else{
                    component.set("v.fcDisplayWrapList", fcWrapList);// add newly 18th Oct
                    const errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.toastMessage(component, "error",  errors[0].message);
                        }
                    }
                }
                component.set("v.isEditQuarter", false);
                component.set("v.isAddQuarter", false);
                component.set("v.loaded", true);
            });
            $A.enqueueAction(action);
                }
            } else {
              const errors = response.getError();
              if (errors) {
                if (errors[0] && errors[0].message) {
                    component.set("v.isEditQuarter", false);
                  helper.toastMessage(component, "error", errors[0].message);
                }
              }
            }
          });
          $A.enqueueAction(action);
	}
                    
        else{   
            if(component.get("v.isAddQuarter") == true){
                component.set("v.dummyFcDisplayWrapList", fcWrapList);
                fcWrapListAdd = fcWrapList;
            }else{
                component.set("v.fcDisplayWrapList", fcWrapList);
                fcWrapListEdit = fcWrapList;
            }
            component.set("v.canShowPostWinDelete",false);
            component.set("v.loaded", false);             
            var action = component.get("c.saveAll");
            action.setParams({
                fcDisplayWrapStr : JSON.stringify(fcWrapListEdit),
                dummyFcDisplayWrapStr : JSON.stringify(fcWrapListAdd),
                opp : component.get("v.oppRecord"),
                actionType : actType
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    component.set("v.fcDisplayWrapList", fcWrapList);// add newly 18th Oct
                    helper.toastMessage(component, "success", $A.get("$Label.c.Core_FC_SaveAll"));
                    $A.get('e.force:refreshView').fire();
                }else{
                    component.set("v.fcDisplayWrapList", fcWrapList);// add newly 18th Oct
                    const errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.toastMessage(component, "error",  errors[0].message);
                        }
                    }               
                    
                }
                component.set("v.isEditQuarter", false);
                component.set("v.isAddQuarter", false);
            });
            $A.enqueueAction(action);
      //     }

        }
        component.set("v.loaded", true);
    },
    
    openSubmitQuarterPopup : function(component, event, helper){
        //TWC3123-5786 Start
        if(component.get("v.isOppLocked") && component.get("v.oppCoverage") == "Partner-Led Opportunity" && component.get("v.coverageType") == "Deal Registration"
           && component.get("v.oppRecord.RecordType.Name") == 'Deal Opportunity'){
               helper.toastMessage(component, "error", $A.get("$Label.c.Core_6QPS_QLI_Not_Approved_Error"));
        }//TWC3123-5786 End
        else if(component.get("v.oppRecord.StageName") != 'Production Win' && component.get("v.oppRecord.RecordType.Name") == 'Design Opportunity'){
            helper.toastMessage(component, "error", $A.get("$Label.c.Core_FC_Not_PW")); 
        }
             
        //TWC3123-5771 Start
        else if(component.get("v.totalQuantityError") != '' && component.get("v.oppCoverage") == "Partner-Led Opportunity" && component.get("v.coverageType") == "Deal Registration" 
                && component.get("v.oppRecord.RecordType.Name") == 'Deal Opportunity'){
            helper.toastMessage(component, "error", $A.get("$Label.c.Core_Oppo_Sch_prod_Qty_Ck")+' '+component.get("v.totalQuantityError")); //TWC3123-6665 updated label from Core_6QPS_Schedule_Error           
        }//TWC3123-5771 End
                 
		//Devashish
        else if (component.get("v.oppCoverage") == "Partner-Led Opportunity" && component.get("v.coverageType") == "Deal Registration") 
        {
            
		var comingFrom = '';
		var fcWrapListForEditQty = [];
		var fcWrapListForEditQtyDummy = [];
        fcWrapListForEditQty = component.get("v.fcDisplayWrapList");
		fcWrapListForEditQtyDummy = component.get("v.fcDisplayWrapList");
            
          var action = component.get("c.checkQLDates");
          action.setParams({
            fcDisplayWrapStr: JSON.stringify(fcWrapListForEditQty),
			dummyFcDisplayWrapStr : JSON.stringify(fcWrapListForEditQtyDummy),
            opp: component.get("v.oppRecord"),
			actionType : 'Submit',
            comingFrom : 'Submit'
          });		
            
          action.setCallback(this, function(response) 
		  {
            if (response.getState() === "SUCCESS") 
			{
                
              var result = response.getReturnValue();
			  component.set("v.QLQuarterList", result);
                var oliRowNum1='';
                var ProductNumberListAura = [];
                ProductNumberListAura = component.get("v.QLQuarterList");
                if(ProductNumberListAura.length !=0)
				{
					for(var l=0; l<ProductNumberListAura.length; l++)
					{                    
						if(oliRowNum1 != ''){
						 oliRowNum1 = oliRowNum1+'/'+'Item#'+ProductNumberListAura[l]+' ';
					}
					else{
						oliRowNum1 = 'Item#'+ProductNumberListAura[l]+' ';
						}
					}
                    component.set("v.QuantityEditRestriction", true);

               helper.toastMessage(component, "error", oliRowNum1+$A.get("$Label.c.Core_PCC_6QPSEditQtyRestriction"));
              }
                
               else{
					if(component.get("v.quarterMisALign") == true){
						var msg = " ";
						var title = $A.get("$Label.c.Core_6QPS_Quarter_Error");
						helper.toastMessage(component, "error", title, msg);
						component.set("v.isSubmitQuarter", false);
					}else if(component.get("v.fcWrapper.noManager") == true && !(component.get("v.oppCoverage") == "Partner-Led Opportunity" && component.get("v.coverageType") == "Deal Registration")){
						helper.toastMessage(component, "error", $A.get("$Label.c.Core_FC_NoManager"));
					}else{
						component.set("v.isSubmitQuarter", true);
					}  
				}
            }
          });
          $A.enqueueAction(action);
	}
        
        //Added By Hira
            else{
                if(component.get("v.quarterMisALign") == true){
                    var msg = " ";
                    var title = $A.get("$Label.c.Core_6QPS_Quarter_Error");
                    helper.toastMessage(component, "error", title, msg);
                    component.set("v.isSubmitQuarter", false);
                }else if(component.get("v.fcWrapper.noManager") == true && !(component.get("v.oppCoverage") == "Partner-Led Opportunity" && component.get("v.coverageType") == "Deal Registration")){
                    helper.toastMessage(component, "error", $A.get("$Label.c.Core_FC_NoManager"));
                }else{
                    component.set("v.isSubmitQuarter", true);
                }  
            }
    },
    
    closeSubmitQuarterPopup : function(component, event, helper){
        component.set("v.isSubmitQuarter", false);
    },
    
    submitForApproval : function(component, event, helper){        
        component.set("v.loaded", false);
        component.set("v.isSubmitQuarter", false);
        var action = component.get("c.submitQuarterForApproval");
        action.setParams({
            fcDisplayWrapStr : JSON.stringify(component.get("v.fcDisplayWrapList")),
            quarterStatusString : JSON.stringify(component.get("v.quarterStatusSet")),
            opp : component.get("v.oppRecord"),
            delegatedApp : component.get("v.fcWrapper.delegatedApprover")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result != ""){
                    helper.toastMessage(component, "success", result+" "+$A.get("$Label.c.Core_FC_SubmitForApproval"));
                }else{
                    helper.toastMessage(component, "error", $A.get("$Label.c.Core_FC_Submit_NoQuarter"));
                }
                $A.get('e.force:refreshView').fire();
            }else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.toastMessage(component, "error", errors[0].message);
                    }
                }  
                component.set("v.loaded", true);
            }
        });
        $A.enqueueAction(action);
    
    },
    
    approveForecast : function(component, event, helper){
        component.set("v.loaded", false);
        var action = component.get("c.approveQuarters");
        action.setParams({
            fcDisplayWrapStr : JSON.stringify(component.get("v.fcDisplayWrapList")),
            quarterStatusString : JSON.stringify(component.get("v.quarterStatusSet")),
            opp : component.get("v.oppRecord")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result != ""){
                    helper.toastMessage(component, "success", result+" "+$A.get("$Label.c.Core_FC_ApproveQuarter"));
                }else{
                    helper.toastMessage(component, "error", $A.get("$Label.c.Core_FC_UnexpectedError"));
                }
                $A.get('e.force:refreshView').fire();
            }else{
                const errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.toastMessage(component, "error",  errors[0].message);
                    }
                }
                component.set("v.loaded", true);
            }
        });
        $A.enqueueAction(action);
    },
    
    rejectForecast : function(component, event, helper){
        component.set("v.loaded", false);
        var action = component.get("c.rejectQuarters");
        action.setParams({
            fcDisplayWrapStr : JSON.stringify(component.get("v.fcDisplayWrapList")),
            quarterStatusString : JSON.stringify(component.get("v.quarterStatusSet"))
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result != ""){
                    helper.toastMessage(component, "success", result+" "+$A.get("$Label.c.Core_FC_RejectQuarter"));
                }else{
                    helper.toastMessage(component, "error", $A.get("$Label.c.Core_FC_UnexpectedError"));
                }
                $A.get('e.force:refreshView').fire();
            }else{
                const errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.toastMessage(component, "error",  errors[0].message);
                    }
                }
                component.set("v.loaded", true);
            }
        });
        $A.enqueueAction(action);
    },
    
    recallLstApproval : function(component, event, helper){
        component.set("v.loaded", false);
        var action = component.get("c.recallApproval");
        action.setParams({
            opp : component.get("v.oppRecord"),
            fcDisplayWrapString : JSON.stringify(component.get("v.fcDisplayWrapList")),
            quarterStatusString : JSON.stringify(component.get("v.quarterStatusSet"))
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                helper.toastMessage(component, "success", $A.get("$Label.c.Core_FC_Recall"));
                
                var action = component.get("c.quarterAlignmentCheck");
                action.setParams({
                    oppId : component.get("v.recordId")
                });
                action.setCallback(this, function(response){
                    if(response.getState() === "SUCCESS"){
                        var resp = response.getReturnValue();
                        component.set("v.quarterMisALign",resp);
                        if(component.get("v.quarterMisALign") == true){
                            var msg = " ";
                            var title = $A.get("$Label.c.Core_6QPS_Quarter_Error");                            
                            helper.toastMessageSticky(component, "error", title, msg);
                        }
                    }
                    else{
                        const errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                helper.toastMessage(component, "error",  errors[0].message);
                            }
                        }
                    }
                    
                });
                $A.enqueueAction(action); 
                $A.get('e.force:refreshView').fire();
            }else{
                const errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.toastMessage(component, "error",  errors[0].message);
                    }
                }
                component.set("v.loaded", true);
            }
        });
        $A.enqueueAction(action);
    },
    
    onMenuSelection : function(component, event, helper){
        var selectedValue = event.getParam("value");
        var action;
        if(selectedValue == "AppSchedQuarter"){
            action = component.get("c.approveForecast");
        }else if(selectedValue == "RejSchedQuarter"){
            action = component.get("c.rejectForecast");
        }else if(selectedValue == "RecallLastApproval"){
            action = component.get("c.recallLstApproval");
        }else if(selectedValue == "forecastCredit"){
            action = component.get("c.redirectToReport");
        }
        $A.enqueueAction(action);
    },
    
    clearAllSchedules : function(component, event, helper){
        component.set("v.isClearAll", true);
        var displayWrapList = [];
        if(component.get("v.isAddQuarter") == true){
            displayWrapList = component.get("v.dummyFcDisplayWrapList");
        }else{
            displayWrapList = component.get("v.fcDisplayWrapList");
        }
        for(var i=0; i<displayWrapList.length; i++){
            for(var j=0; j<displayWrapList[i].scheduledList.length; j++){
                if(component.get("v.myMap."+displayWrapList[i].scheduledList[j].quarterName) == "noValue"){
                    displayWrapList[i].scheduledList[j].scheduledQuantity = 0;
                }
            }
        }
        if(component.get("v.isAddQuarter") == true){
            component.set("v.dummyFcDisplayWrapList", displayWrapList);
        }else{
            component.set("v.fcDisplayWrapList", displayWrapList);
        }
    },
    
    closeAddEditPopup : function(component, event, helper){
        component.set("v.isAddQuarter", false);
        component.set("v.isEditQuarter", false);
        $A.get('e.force:refreshView').fire(); 
    },
    
    redirectToReport : function(component, event, helper){
        component.set("v.loaded", false);
        var action = component.get("c.open6QPSReport");
        action.setParams({
            oppId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var reportId = response.getReturnValue();
                component.set("v.loaded", true);
                //var reportUrl = component.get("v.ltngRecUrl");
                window.open(component.get("v.ltngRecUrl") + reportId + "/view?fv0=" + component.get("v.recordId"));
            }else{
                component.set("v.loaded", true);
            }
        });
        $A.enqueueAction(action);
    }
})