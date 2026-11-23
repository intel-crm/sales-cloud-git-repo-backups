({
	//Calls the apex side method and constructs the myoptions
	fetchPickListVal: function(component, objName, fieldName, parentId, parfieldName,rTypeName,cvalue) {
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
		
		if(fieldName == 'Core_MDF_TargetAudience__c'){
			targetAudienceFromPFR = component.get("v.options");
			//console.log("line 11 invalues "+JSON.stringify(targetAudienceFromPFR));
		}
		else if(fieldName == 'Core_MDF_ProductType__c'){
			productTypeFromPFR = component.get("v.options");
			//console.log("line 11 invalues "+JSON.stringify(productTypeFromPFR));
		}
		else if(fieldName == 'Core_MDF_Brand__c'){
			brandFromPFR = component.get("v.options");
            //console.log("line 11 invalues for brand "+JSON.stringify(brandFromPFR));
		}
		else if(fieldName == 'Core_MDF_Activity_Types__c'){
			activityTypeFromPFR = component.get("v.options");
			//console.log("line 11 invalues "+JSON.stringify(activityTypeFromPFR));
		}
		else if(fieldName == 'Core_MDF_ActivityCategory__c'){
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

		action.setCallback(this, function(response) {
            
			if (response.getState() == "SUCCESS") {
				var optionMap = new Map();
				optionMap = response.getReturnValue();
               //alert('optionMap.size-->'+optionMap.length);
               // if(optionMap.length > 1){
                    //console.log("optionMap"+JSON.stringify(optionMap));
                    opts.push({
                        class: "optionClass",
                        label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                        value: ""
                    });
                for(var key in optionMap){
                    opts.push({
                        class: "optionClass",
                        label: optionMap[key],
                        value: key
                    });
                }
				
				//console.log("Campaign Values (opts) "+JSON.stringify(opts));
				var updatedopts=[];

				if(fieldName == 'Core_MDF_Country__c'){
					//console.log(" country myopts "+JSON.stringify(opts));
					component.set("v.myoptions",opts);
	                //this.setMyOptionValues(component, countriesPFR, opts);
				}
				else{
					if(fieldName == 'Core_MDF_TargetAudience__c'){
						this.setMyOptionValues(component, targetAudienceFromPFR, opts);
					}
					else if(fieldName == 'Core_MDF_ProductType__c'){
                         this.setMyOptionValues(component, productTypeFromPFR, opts);
                       
						
					}else if(fieldName == 'Core_MDF_Brand__c'){
                         this.setMyOptionValues(component, brandFromPFR, opts);     				
					}else if(fieldName == 'Core_MDF_ActivityCategory__c'){
						this.setMyOptionValues(component, categoryFromPFR, opts);
						
					}else if(fieldName == 'Core_MDF_Activity_Types__c'){
						this.setMyOptionValues(component, activityTypeFromPFR, opts);
					}
				}
			}
		});
		$A.enqueueAction(action);
	},
	// SS - Read channel partners list for the country from custom meta data
	GetChannelPartners: function (component,ctry)
	{
		var channelParts;
		var opts = [];
		var action = component.get("c.fetchCPCtryMetaData");
		action.setParams({
			"ctry": ctry
		});    

		action.setCallback(this, function(response) {
			channelParts = response.getReturnValue(); 
			opts.push({
				class: "optionClass",
				label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
				value: ""
			}); 

			if (channelParts != undefined && channelParts.length > 0)
			{
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
	sendchangedvalue : function(component, event){
       
		var updateEvent = component.getEvent("PicValue");
			updateEvent.setParams({"PicValue": component.get("v.selectedValue") });
			updateEvent.setParams({"PicFieldName": component.get("v.fldName") });
			updateEvent.fire();

	},
    
	// helper called to set values of in Myoption attribute
	setMyOptionValues : function(component, valuefromPFR, myopts){
		var updatedopts=[]; 
        for(var i=0;i<valuefromPFR.length;i++){
			for(var j=0;j<myopts.length;j++){
				if(valuefromPFR[i].value == myopts[j].value){
					updatedopts[j] = myopts[j];
				}

			}
		}
        if(updatedopts.length == 2){
            updatedopts.splice(0,1);
            component.set("v.selectedValue",updatedopts[0].value)
       	}
        component.set("v.myoptions",updatedopts);
      },
    // Functions Called for Replacing label with Localized label
    replaceActualLabelwithLocalizedLabel : function(component){
        var labelapimap = [];
        var optionMap = component.get("v.labelValueMap");
        labelapimap.push({
            class: "optionClass",
            label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
            value: ""
        });
        for(var key in optionMap){
            labelapimap.push({
                class: "optionClass",
                label: optionMap[key],
                value: key
            });
        }
        var opts =[];
        var updatedOpts = [];
        
        var opts = component.get("v.options");
        for(var i = 0; i<opts.length; i++){
            for(var j=0;j<labelapimap.length;j++){
                if(labelapimap[j].value == opts[i].value){
                    updatedOpts[i] = labelapimap[j];
                    break;
                }
            }
        }
        //console.log("updatedopts here --->"+JSON.stringify(updatedOpts));
        component.set("v.ccfoptions",updatedOpts);
    }
})