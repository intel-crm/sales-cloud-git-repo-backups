({

	callFetchPickListVal: function (component) {

		this.fetchPickListVal(component, component.get("v.objName"), component.get("v.fldName"),
			component.get("v.ParentId"), component.get("v.ParentfldName"),
			component.get("v.recTypeName"), component.get("v.controllingvalue"));
	},
	//Calls the apex side method and constructs the myoptions
	fetchPickListVal: function (component, objName, fieldName, parentId, parfieldName, rTypeName, cvalue) {
		//alert("inside pickhelper");
		var action;
		//var invalues = [];
		//alert("objName"+component.get("v.objName"));
		var targetAudienceFromPFR = [];
		var productTypeFromPFR = [];
		var brandFromPFR = [];
		var categoryFromPFR = [];
		var activityTypeFromPFR = [];
		var countriesPFR = [];
        

		if (fieldName == 'Core_MDF_TargetAudience__c') {
			targetAudienceFromPFR = component.get("v.options");
			//console.log("line 11 invalues "+JSON.stringify(targetAudienceFromPFR));
		}
		else if (fieldName == 'Core_MDF_ProductType__c') {
			productTypeFromPFR = component.get("v.options");
			//console.log("line 11 invalues "+JSON.stringify(productTypeFromPFR));
		}
		/*else if (fieldName == 'Core_MDF_Brand__c') {
			brandFromPFR = component.get("v.options");
			//console.log("line 11 invalues for brand "+JSON.stringify(brandFromPFR));
		}*/
        
		else if (fieldName == 'Core_MDF_Activity_Types__c') {
			activityTypeFromPFR = component.get("v.options");
			//console.log("line 11 invalues "+JSON.stringify(activityTypeFromPFR));
		}

		else if (fieldName == 'Core_MDF_ActivityCategory__c') {
			categoryFromPFR = component.get("v.options");
			//console.log("line 11 invalues "+JSON.stringify(categoryFromPFR));
		}
        /*else if(fieldName == 'Core_MDF_Country__c'){
            countriesPFR = component.get("v.options");
		}*/
		var opts = [];
		action = component.get("c.getselectOptions");
		action.setParams({
			"objObject": objName,
			"fld": fieldName,
			"parId": parentId,
			"parfldname": parfieldName,
			"recordTypeName": rTypeName,
			"sctrlvalue": cvalue
		});

		action.setCallback(this, function (response) {

			if (response.getState() == "SUCCESS") {
				var optionMap = new Map();
				optionMap = response.getReturnValue();
                //console.log("GS--->at 62"+JSON.stringify(optionMap));
				//alert('optionMap.size-->'+optionMap.length);
				// if(optionMap.length > 1){
				//console.log("optionMap"+JSON.stringify(optionMap));
				opts.push({
					class: "optionClass",
					label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
					value: ""
				});
				for (var key in optionMap) {
					opts.push({
						class: "optionClass",
						label: optionMap[key],
						value: key
					});
				}

				//console.log("Campaign Values (opts) "+JSON.stringify(opts));
				var updatedopts = [];

				/*if (fieldName == 'Core_MDF_Country__c') {
					//console.log(" country myopts "+JSON.stringify(opts));
					component.set("v.myoptions", opts);
					//this.setMyOptionValues(component, countriesPFR, opts);
				}*/
                //else{
					if (fieldName == 'Core_MDF_TargetAudience__c') { 
						this.setMyOptionValues(component, targetAudienceFromPFR, opts, true);
					}
					else if (fieldName == 'Core_MDF_ProductType__c') {
						this.setMyOptionValues(component, productTypeFromPFR, opts, true);


					} 
                        /*else if (fieldName == 'Core_MDF_Brand__c') {
						this.setMyOptionValues(component, brandFromPFR, opts);
					}*/
                        
                        
                        else if (fieldName == 'Core_MDF_ActivityCategory__c') {
						this.setMyOptionValues(component, categoryFromPFR, opts, false);

					} else if (fieldName == 'Core_MDF_Activity_Types__c') {
						this.setMyOptionValues(component, activityTypeFromPFR, opts, false);
					}

                }
               // }
		});
		$A.enqueueAction(action);
	},
	// SS - Read channel partners list for the country from custom meta data
	GetChannelPartners: function (component, ctry) {
		var channelParts;
		var opts = [];
		var action = component.get("c.fetchIndPartnerCtryPgmMapping");
		action.setParams({
			"ctry": ctry
		});

		action.setCallback(this, function (response) {
			channelParts = response.getReturnValue();
            if(component.get("v.isOpalAct")){
                opts.push({
                    class: "optionClass",
                    label: $A.get("$Label.c.Core_MDF_None_Label"),
                    value: $A.get("$Label.c.Core_MDF_None_Label")                    
                }); 
            }else{
                opts.push({
                    class: "optionClass",
                    label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                    value: ""
                });
            }
			

			if (channelParts != undefined && channelParts.length > 0) {
				for (var i = 0; i < channelParts.length; i++) {
					opts.push({
						class: "optionClass",
						label: channelParts[i],
						value: channelParts[i]
					});
				}
			}
			opts.push({
				class: "optionClass",
				label: "Others",
				value: "Others"
			});
			component.set("v.myoptions", opts);
		});
     
		$A.enqueueAction(action);
	},
	// SS - Assign the event parameter values and send the callback to parent control
	sendchangedvalue: function (component, event) {

		var updateEvent = component.getEvent("PicValue");
		updateEvent.setParams({ "PicValue": component.get("v.selectedValue") });
		updateEvent.setParams({ "PicFieldName": component.get("v.fldName") });
		updateEvent.fire();

	},

	// helper called to set values of in Myoption attribute
	setMyOptionValues: function (component, valuefromPFR, myopts, dependentPicklistField) {
        if (!$A.util.isEmpty(myopts) && myopts.length > 0 && myopts != undefined) {
		myopts.sort(this.case_insensitive_sort);
        }
		var updatedopts = [];
		for (var i = 0; i < valuefromPFR.length; i++) {
			for (var j = 0; j < myopts.length; j++) {
				if (valuefromPFR[i].value == myopts[j].value) {
					updatedopts[j] = myopts[j];
				}
				else if (dependentPicklistField == true){
					updatedopts[j] = myopts[j];
				}
            }
		}

		if (updatedopts.length == 2) {
			updatedopts.splice(0, 1);
			component.set("v.selectedValue", updatedopts[0].value)
		}

		component.set("v.myoptions", updatedopts);

		// Set 'None' as selected value if there is no other options in the array for CCF/CCFB programs. As only these programs we get category/type picklists alone from canpaign
		var pfrOldStatus = component.get("v.olPfrStatus");
		var cloneStatus = component.get("v.IsClone");
		var rectypedevName = component.get("v.recTypeDevName");
		var excludeCategoryTypePrgms = $A.get("$Label.c.Core_MDF_exclude_CatType_Programs");

		if (excludeCategoryTypePrgms.includes(rectypedevName) && myopts.length == 1)
		{
			// If clone then set the values from campaign which is empty and set the selected value as None
			// else set the options from PFR to aviod showing the --None-- value on the disabled fields
			if (cloneStatus == true) {
				component.set("v.selectedValue", myopts[0].value);
				component.set("v.myoptions", updatedopts);
			}
			else if ((pfrOldStatus == $A.get("$Label.c.Core_MDF_pfrInprogress") || pfrOldStatus == $A.get("$Label.c.Core_MDF_PFR_Status_Closed"))) { 
				component.set("v.myoptions", valuefromPFR);
			}
		}
		
	},
	// Functions Called for Replacing label with Localized label
	replaceActualLabelwithLocalizedLabel: function (component) {
		var labelapimap = [];
		var optionMap = component.get("v.labelValueMap");
		labelapimap.push({
			class: "optionClass",
			label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
			value: ""
		});
		for (var key in optionMap) {
			labelapimap.push({
				class: "optionClass",
				label: optionMap[key],
				value: key
			});
		}
		var updatedOpts = [];

		var opts = component.get("v.options");
		for (var i = 0; i < opts.length; i++) {
			for (var j = 0; j < labelapimap.length; j++) {
				if (labelapimap[j].value == opts[i].value) {
					updatedOpts[i] = labelapimap[j];
					break;
				}
			}
		}
		//console.log('updatedopts here --->'+JSON.stringify(updatedOpts));
		component.set("v.ccfoptions", updatedOpts);
	},
    	case_insensitive_sort : function (picklistValue1, picklistValue2) {
    		return picklistValue1.label.toLowerCase().localeCompare(picklistValue2.label.toLowerCase());
	}
})