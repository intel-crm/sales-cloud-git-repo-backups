({
    getData : function(component){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner,  "slds-show");
        component.set('v.columns', [
            {label: 'Employee', fieldName: 'employee', type: 'text',wrapText: true},
            {label: 'Responsibility', fieldName: 'responsibility', type: 'text',wrapText: true}
        ]);
        
        var action = component.get("c.getData"); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state::'+state);
            if (state === "SUCCESS") {
                var responseData = response.getReturnValue();
                var data = [];
                component.set("v.classObj",responseData);
                
                var accContRelationship = responseData.lstAccContRelationship;
                var accTierMembership = responseData.lstAccChannelMembership;
                console.log('userInfo::'+ responseData.lstAccContRelationship);
                var count = 0;
                component.set("v.totalRecords",accContRelationship.length);
                    for(var res in accContRelationship){
                        //console.log('getData res'+res);
                        var value = accContRelationship[res];
                        var name = value.PRM_Contact_Id__r.Name;
                         if(name.length > 30){
                            name = name.substring(0,30);
                        }
                        if(count < 5){
                            data.push(
                                {employee:name,responsibility:value.PRM_Relationship_Id__r.Name}
                            );
                            count= count + 1;                   
                        }else{
                            break;
                        }
                    }
                    component.set("v.data",data);
                
                
                var tier = [];
                for(var tierData in accTierMembership){
                    var acmObj = accTierMembership[tierData];
                    tier.push(acmObj.PRM_Channel_Program_Level_Id__r.Name);
                }
                console.log('tier:'+tier);
                var tierDetail;
                var tierType;
                if(tier.indexOf("Titanium") > -1){
                    tierDetail = 'Details about Titanium need to be added here';
                    tierType = 'Titanium Member';
                }else if(tier.indexOf("Gold") > -1){
                    tierDetail = 'Details about Gold need to be added here';
                    tierType = 'Gold Member';
                }else if(tier.indexOf("Member") > -1){
                    tierDetail = 'Details about Member need to be added here';
                    tierType = 'Member';
                }
                component.set("v.tierDetail",tierDetail);
                component.set("v.tierType",tierType);
                
                $A.util.removeClass(spinner, "slds-show");
                $A.util.addClass(spinner,  "slds-hide");
            }else{
                var errors = response.getError(); 
                console.log('error::'+errors[0].message);
            }
        });
        $A.enqueueAction(action);
        
    },/*
    getPartnerAccountRelationDetails : function(component,event){
        var action = component.get("c.getContactEntitlements"); 
        component.set('v.columns', [
            {label: 'Employee', fieldName: 'employee', type: 'text'},
            {label: 'Responsibility', fieldName: 'responsibility', type: 'text'}
        ]);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state::'+state);
            if (state === "SUCCESS") {
                var responseData = response.getReturnValue();
                var data = [];
                console.log('responseData'+responseData);
                for(var res in responseData){
                    var value = responseData[res];
                    data.push(
                        {employee:value.PRM_Contact_Id__r.Name,responsibility:value.PRM_Relationship_Id__r.Name}
                    );
                }
                component.set("v.data",data);
                $A.util.removeClass(spinner, "slds-show");
                $A.util.addClass(spinner,  "slds-hide");
            }
        });           
        $A.enqueueAction(action);
    },*/
    
    getAccountTierDetails : function(component){
        var classObj = component.get("v.objClassController");
        var intelAccountId = component.get("v.objClassController.intelAccountIDSt");
        var oPId = component.get("v.objClassController.oPAccountIDStr");
        console.log('getAccountTierDetails account ID:'+intelAccountId+'<-->'+classObj.intelAccountIDStr+'<-->'+oPId);
        var action = component.get("c.getAccountTierDetails");
        action.setParams({
            'intelAccountOfPC_D': intelAccountId,
            'onePartnerIdOfPC_D' : oPId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state::'+state);
            if (state === "SUCCESS") {
                var responseData = response.getReturnValue();
                for(var res in responseData){
                    var acmObj = responseData[res];
                    tier = acmObj.PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c;
                    console.log('tier:'+tier);
                    var tierDetail;
                    var tierType;
                    if(tier == 'Titanium'){
                        tierDetail = 'Details about Titanium need to be added here';
                        tierType = 'Titanium Member';
                    }else if(tier == 'Gold'){
                        tierDetail = 'Details about Gold need to be added here';
                        tierType = 'Gold Member';
                    }else{
                        tierDetail = 'Details about Member need to be added here';
                        tierType = 'Member';
                    }
                    component.set("v.tierDetail",tierDetail);
                    component.set("v.tierType",tierType);
                }
            }
        });           
        $A.enqueueAction(action);
    }
})