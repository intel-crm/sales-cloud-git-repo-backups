({
    doInit: function(component, event, helper) {
        //fetch fieldname and record type
        var fldname = component.get("v.fldName");
        var rectypedevName = component.get("v.recTypeDevName");
        var picklistfld = $A.get("$Label.c.Core_MDF_PFRPicklistField");
        var fieldValuesFromPFRRecordType = $A.get("$Label.c.Core_MDF_PicklistValues_From_PFR_RecordType");
        // Activity Category for CCF
        if(fldname == "Core_MDF_ActivityCategory__c" && component.get("v.options") != "" && fieldValuesFromPFRRecordType.includes(rectypedevName)){ 
           helper.replaceActualLabelwithLocalizedLabel(component);
        }
        //  Activity Type for CCF
        if(fldname == "Core_MDF_Activity_Types__c" && component.get("v.options") != "" && fieldValuesFromPFRRecordType.includes(rectypedevName)){   
           	helper.replaceActualLabelwithLocalizedLabel(component); 
        }
        // Target Audience For CCF
        if(fldname == "Core_MDF_TargetAudience__c" && component.get("v.options") != "" && fieldValuesFromPFRRecordType.includes(rectypedevName)){
  			helper.replaceActualLabelwithLocalizedLabel(component);
        }
        // Product Type For CCF
        if(fldname == "Core_MDF_ProductType__c" && component.get("v.options") != "" && fieldValuesFromPFRRecordType.includes(rectypedevName)){
  			helper.replaceActualLabelwithLocalizedLabel(component);
        }
        // Brand For CCF
        if(fldname == "Core_MDF_Brand__c" && component.get("v.options") != "" && fieldValuesFromPFRRecordType.includes(rectypedevName)){
  			helper.replaceActualLabelwithLocalizedLabel(component);
        }
        // Event Format 
        if(fldname == "Core_MDF_Event_Format_Nm__c" && component.get("v.options") != ""){
            helper.replaceActualLabelwithLocalizedLabel(component);
        }
        // Country for CCF 
        /*if(fldname == "Core_MDF_Country_nm__c" && component.get("v.options") != "" && rectypedevName == "Core_MDF_Client_CoMarketing_Fund" ){
            alert("Here--->Country");
            helper.replaceActualLabelwithLocalizedLabel(component);
        }*/
        
        var rectypeName = component.get("v.recTypeName"); //$A.get("$Label.c.Core_MDF_CCF_RecordType");
        var parId = component.get("v.ParentId");
        var pickListFields = [];
        var pickLabel = "";
        pickLabel = $A.get("$Label.c.Core_MDF_ActivityPickFields");
        var pickListFields = pickLabel.split(",");
        
        var isCPLed = component.get("v.CPLed");
        var ctry = component.get("v.Ctry");
        var cps = component.get("v.myoptions").length;
        if (isCPLed == true && cps == 0) // SS - Call the channel partner helper method to load CP's if CP enabled for the country
        {
            helper.GetChannelPartners(component,ctry);    
        }
        //For DCF fields and CCF other than activity category, activity type and country
        //if ((rectypeName != $A.get("$Label.c.Core_MDF_CCF_RecordType") || pickListFields.includes(fldname) == false) &&
        //    rectypeName != '' && parId != '') 
        if ((!fieldValuesFromPFRRecordType.includes(rectypedevName) || pickListFields.includes(fldname) == false) &&
            rectypeName != '' && parId != '' )
        {   
            helper.fetchPickListVal(component, component.get("v.objName"),component.get("v.fldName"), 
                                   component.get("v.ParentId"), component.get("v.ParentfldName"),
                                   component.get("v.recTypeName"),component.get("v.controllingvalue"));
        }
    },
    
    //SS - Pick list change event and to call helper method
    handleChange : function(component,event,helper){
        helper.sendchangedvalue(component);
    }
})