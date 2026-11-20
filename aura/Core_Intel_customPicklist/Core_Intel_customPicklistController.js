({
    doInit: function (component, event, helper) {
        //fetch fieldname and record type
        var fldname = component.get("v.fldName");
        var rectypedevName = component.get("v.recTypeDevName");
        var prgmsForActCategory = $A.get("$Label.c.Core_MDF_Prgms_Applicable_Act_Category");        //ccf,ccfb,dcf,spcf
        var prgmsForActType = $A.get("$Label.c.Core_MDF_Prgms_Applicable_Act_Types");               //ccf,ccfb,dcf,spcf
        //Added CCF Rec type in below 3 labels as part of US936875 - To remove Field Dependencies b/w Audiences,Product Type and Brand
        //And Inherit the Picklist values from Campaign
        var prgmsForTargetAudience = $A.get("$Label.c.Core_MDF_Prgms_Applicable_TargetAudience");   //dcf,spcf,rmf
        var prgmsForProductType = $A.get("$Label.c.Core_MDF_Prgms_Applicable_ProductType");         //dcf,spcf,rmf
        var prgmsForBrands = $A.get("$Label.c.Core_MDF_Prgms_Applicable_Brands");                   //dcf,spcf,rmf
        
        //OPAL Changes start: US907656 - [OPAL CCF/DCF] - Campaign and Activity inheritance
        //Commented below lines as program addded to labels US936875 - changes
        /*if(component.get("v.isOpalAct")){
            prgmsForTargetAudience = prgmsForTargetAudience + "Core_MDF_Client_CoMarketing_Fund";
            prgmsForProductType = prgmsForProductType + "Core_MDF_Client_CoMarketing_Fund";
            prgmsForBrands = prgmsForBrands + "Core_MDF_Client_CoMarketing_Fund";
        }*/
        //OPAL changes end
        //Get localized category for Retail
      //  console.log('options',component.get("v.options"));
        var option = component.get("v.options");
        //console.log('options',option);
       // component.set("v.options",option);
        //component.set("v.options",option);
		if (fldname == "Core_MDF_ActivityCategory__c" && component.get("v.options") != "" && !prgmsForActCategory.includes(rectypedevName))
        {
            helper.replaceActualLabelwithLocalizedLabel(component);
        }
        //Get localized activity type for Retail
        else if (fldname == "Core_MDF_Activity_Types__c" && component.get("v.options") != "" && !prgmsForActType.includes(rectypedevName)) {
            helper.replaceActualLabelwithLocalizedLabel(component);
        }

        // Target Audience For CCF & CCFB
        else if (fldname == "Core_MDF_TargetAudience__c" && component.get("v.options") != "" && !prgmsForTargetAudience.includes(rectypedevName)) {
            helper.replaceActualLabelwithLocalizedLabel(component);
        }
        // Product Type For CCF & CCFB
        else if (fldname == "Core_MDF_ProductType__c" && component.get("v.options") != "" && !prgmsForProductType.includes(rectypedevName)) {
            helper.replaceActualLabelwithLocalizedLabel(component);
        }
        // Brand For CCF & CCFB
       /* else if (fldname == "Core_MDF_Brand__c" && component.get("v.options") != "" && !prgmsForBrands.includes(rectypedevName)) {
            helper.replaceActualLabelwithLocalizedLabel(component);
        }*/
		 else if (fldname == "Core_MDF_Brand_nm__c" && component.get("v.options") != "" && !prgmsForBrands.includes(rectypedevName)) {
            helper.replaceActualLabelwithLocalizedLabel(component);
        }
        
        else if (fldname == "Core_MDF_Event_Format_Nm__c" && component.get("v.options") != "") {
            helper.replaceActualLabelwithLocalizedLabel(component);
        }
        else if (fldname == "Core_MDF_Activity_Sub_Type_nm__c" && component.get("v.options") != "") {
            helper.replaceActualLabelwithLocalizedLabel(component);
        }
        
        var rectypeName = component.get("v.recTypeName"); //$A.get("$Label.c.Core_MDF_CCF_RecordType");
        var parId = component.get("v.ParentId");
        var pickLabel = "";
        pickLabel = $A.get("$Label.c.Core_MDF_ActivityPickFields");
        var pickListFields = pickLabel.split(",");

        var isCPLed = component.get("v.CPLed");
        var ctry = component.get("v.Ctry");
        var cps = component.get("v.myoptions").length;
       
        if (isCPLed == true && cps == 0) // SS - Call the channel partner helper method to load CP's if CP enabled for the country
        {
            helper.GetChannelPartners(component, ctry);
        }
        // alert("myopt"+ctry);
        //console.log("GS--->at 56");
        if(rectypeName != '' && parId != '' && 
           ((prgmsForActCategory.includes(rectypedevName) && fldname == 'Core_MDF_ActivityCategory__c') ||
           (prgmsForActType.includes(rectypedevName) && fldname == 'Core_MDF_Activity_Types__c') ||
           (prgmsForTargetAudience.includes(rectypedevName) && fldname == 'Core_MDF_TargetAudience__c') ||
           (prgmsForProductType.includes(rectypedevName) && fldname == 'Core_MDF_ProductType__c') ||
           /*(prgmsForBrands.includes(rectypedevName) && fldname == 'Core_MDF_Brand__c')||*/
           (prgmsForBrands.includes(rectypedevName) && fldname == 'Core_MDF_Brand_nm__c'))){
            //console.log("GS--->inside 63 custompicklist");
            helper.callFetchPickListVal(component);//From Campaign
        }

    },

    //SS - Pick list change event and to call helper method
    handleChange: function (component, event, helper) {
        helper.sendchangedvalue(component);
    },
    validateErrors: function (component, event) {
        var error = component.find("mySelect");
        if(error.length == 1){
            error[0].showHelpMessageIfInvalid();
        }else {
            error.showHelpMessageIfInvalid();
        }
    }    
})