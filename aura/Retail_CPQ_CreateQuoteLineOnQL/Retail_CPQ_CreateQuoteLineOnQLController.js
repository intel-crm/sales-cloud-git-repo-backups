({

    /*

     * This method is being called from init event

     * to fetch all available recordTypes

     * */

    fetchListOfRecordTypes: function(component, event, helper) {

        var action = component.get("c.fetchRecordTypeValues");

        

        //pass the object name here for which you want

        //to fetch record types

        action.setParams({

            "objectName" : "SBQQ__QuoteLine__c"

        });

        

        action.setCallback(this, function(response) {

            var mapOfRecordTypes = response.getReturnValue();

            component.set("v.mapOfRecordType", mapOfRecordTypes);

            

            var recordTypeList = [];

            //Creating recordTypeList from retrieved Map

            for(var key in mapOfRecordTypes){

                recordTypeList.push(mapOfRecordTypes[key]);

            }

            

            if(recordTypeList.length == 0){//Object does not have any record types

                //Close Quick Action Modal here

                helper.closeModal();

                

                //Calling CreateRecord modal here without providing recordTypeId

                helper.showCreateRecordModal(component, "", "SBQQ__QuoteLine__c");

            } else{

            component.set("v.lstOfRecordType", recordTypeList);

            }

            

        });

        $A.enqueueAction(action);

    },

    

    /*

     * This method will be called when "Next" button is clicked

     * It finds the recordTypeId from selected recordTypeName

     * and passes same value to helper to create a record

     * */

    createRecord: function(component, event, helper, sObjectRecord) {
		var selectedRecordTypeName = component.get("v.radioButtonvalue");
       
        //var selectedRecordTypeName =  event.getParam("value");
       // var selectedRecordTypeName = component.find("recordTypePickList").get("v.value");
		console.log('selectedRecordTypeName'+selectedRecordTypeName);
        if(selectedRecordTypeName != ""){

            var selectedRecordTypeMap = component.get("v.mapOfRecordType");
			console.log('selectedRecordTypeMap'+selectedRecordTypeMap);
            var selectedRecordTypeId;

            

            //finding selected recordTypeId from recordTypeName

            for(var key in selectedRecordTypeMap){

                if(selectedRecordTypeName == selectedRecordTypeMap[key]){

                    selectedRecordTypeId = key;//match found, set value in selectedRecordTypeId variable

                    break;

                }

            }

            //Close Quick Action Modal here

            helper.closeModal();

            

            //Calling CreateRecord modal here without providing recordTypeId

            helper.showCreateRecordModal(component, selectedRecordTypeId, "SBQQ__QuoteLine__c");

        } else{

            alert('You did not select any record type');

        }

        

    },

    handleChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        console.log('changeValue22'+changeValue);
        cmp.set("v.radioButtonvalue",changeValue);
        cmp.set("v.disableSave",false);
    },

    /*

     * closing quickAction modal window

     * */

    closeModal : function(component, event, helper){

        helper.closeModal();

    }

})