({
    //Get product info-Gireesh:US519754
    getProductInfo: function(component,helper){
        
        var userLangCode = $A.get("$Locale.langLocale");
        var action = component.get("c.getProductInformation"); 
        var params = {
            // IPA2.0 + US TWC4497-1631
            // offeringId: component.get("v.recordId"),
            langCode: userLangCode
        };
        action.setParams(params);
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log("marquee-response-1", resp);
                if(resp){
                    var productDetails=resp[0];
                    if(productDetails != null){
                        /*let allAttributes=productDetails.attributes;
                        let newAttributes=[];
                    
                        //replace Categories, Industry and Application into approriate format "{name:Category,type:[]... name:Industry,type:[]...name:Application,type:[]...}"
                        for (let key of Object.keys(allAttributes)) {
                            if(key==$A.get("$Label.c.PMP_Search_Categories_Filter") || key==$A.get("$Label.c.PMP_Industry")|| key==$A.get("$Label.c.PMP_application")){                        
                                let attributes=new Object();
                                attributes.name=key;
                                attributes.types=allAttributes[key];
                                newAttributes.push(attributes);
                            }
                        } */
                        //productDetails.attributes=newAttributes;
                        component.set("v.productInfo",productDetails);
                        console.log('#a-productDetails', productDetails);
                    }
                }
            }else{
                var errors = response.getError();
                if(errors){
                console.log("##Error message: " + errors);
                }
            }
        });
        $A.enqueueAction(action);
    },
    // IPA2.0 + US TWC4497-1631
    // getOffering: function(component, id) {
    //     //Shahrukh : Fix for data update after edit offering
    //     // let action = isPreview ?component.get("c.previewOfferingDetails"):component.get("c.fetchOfferingDetail");
        
    //     var urlString = window.location.href;

    //     var action = component.get("c.getOfferingDetail");
        
    //     if(urlString.includes('?Lang=NA')){
    //         action = component.get("c.getOfferingDetailProductDetails");
    //     }
    //         //Added by Abhishek to fetch language from URL
    //     var language = this.getJsonFromUrl().Lang;
    //     //Sandhya : US592842
    //     var isPreview = component.get('v.previewMode');
    //     if (!isPreview){
    //         action.setStorable();
    //     }
	// 	//In preview mode, if language parameter is not present, then data should appear in base language
    //     if (!language && component.get('v.previewMode')) {
    //         language='NA';
    //     }
    //     const userLangCode = $A.get("$Locale.langLocale"); //Gireesh: US664733: to support for anonymous user
    //     console.log('##userLangCodel3:',userLangCode);
    //     action.setParams({
    //         offeringId: component.get("v.recordId"),
    //         bEditOffering: false,
    //         bViewOffering: true,
    //         bCompareOffering: false,
    //         language: language,
    //         langCode: userLangCode, //Gireesh: US664733: to support for anonymous user
    //         isPreview:isPreview
            
    //     });

    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //                 var resp = response.getReturnValue();
    //                 console.log("#l3l", JSON.stringify(resp.objectData));
    //                 if(resp && resp.objectData!=undefined && resp.objectData && resp.objectData.OfferingDetail){
    //                 console.log("#l3l2", resp.objectData);    
    //                     component.set("v.product", resp.objectData.OfferingDetail);
    //                     var windowUrl = window.location.href;
    //                     var companylink = windowUrl.split("/offering/");
    //                     companylink = companylink[0].concat("/partner/");
    //                     companylink = companylink.concat(resp.objectData.OfferingDetail[0].PMP_Company_Id__r.Id);
    //                     component.set("v.product.partnerLink",companylink);
    //                     component.set("v.isPublished",component.get("v.product[0].PMP_Partner_Offering_Lifecycle_Status_Nm__c")=="Published");
                    
    //                     if (resp.objectData.OfferingDetail[0].PMP_Offering_Status_Update_Dt__c){
    //                         component.set(
    //                             "v.lastUpdatedDate",
    //                             resp.objectData.OfferingDetail[0].PMP_Offering_Status_Update_Dt__c
    //                         );
    //                     }
    //                 }
                
    //         } else if (state === "INCOMPLETE") {
    //             console.log("INCOMPLETE##");
    //             // do something
    //         } else if (state === "ERROR") {
    //             console.log("error##");
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     console.log("Error message: " + errors[0].message);
    //                 }
    //             } else {
    //                 console.log("Unknown error");
    //             }
    //         }
    //     });
    //     $A.enqueueAction(action);
        
        
        
    // },
    
    getPartner: function(component, id) {
        var userLangCode = $A.get("$Locale.langLocale");
        var action = component.get("c.getPartnerData");
        var params = {
            recordId: component.get("v.recordId"),
            langCode: userLangCode
        };
        action.setParams(params);
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.partner", returnValue);
                console.log('Published status : ' , returnValue.publishedStatus);
                component.set(
                    "v.showEditPencil",
                    returnValue.hasAccess && !returnValue.isGuest
                );
            } else if (status === "INCOMPLETE") {
                // do something?
            } else if (status === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                    }
                }
            } else {
                this.reject("Unknown error.");
            }
        });
        $A.enqueueAction(action);
        
    },
    
    setLabels: function(component) {
        component.set("v.bookmarkLabel", $A.get("$Label.c.PMP_L3_Marquee_Bookmark"));
        component.set("v.bookmarkCopiedTooltip", $A.get("$Label.c.PMP_L3_Marquee_Bookmark_Tooltip"));
        component.set("v.byLabel", $A.get("$Label.c.PMP_L3_Marquee_By"));
        component.set("v.moreLabel", $A.get("$Label.c.PMP_L3_Marquee_More"));
        component.set("v.closeLabel", $A.get("$Label.c.PMP_L3_Marquee_Close"));
        component.set("v.lastupdatedLabel", $A.get("$Label.c.PMP_L3_Marquee_Last_Updated"));
    },
    getJsonFromUrl: function() {
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            result[item[0]] = decodeURIComponent(item[1]);
        });
        return result;
    },
    
    gotoTermsAndCondition: function(component) {
    	
        var action = component.get("c.checkLegalAgreementForAllLocations");
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log(':::checkLegalAgreementForAllLocations:::', returnValue);
                if(returnValue == false) {
                    window.location.href = $A.get("$Label.c.PMP_IPA_Home_LoggedIn");
                }
            } else if (status === "INCOMPLETE") {
            } else if (status === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                    }
                }
            } else {
                this.reject("Unknown error.");
            }
        });
        $A.enqueueAction(action);
	},
});