({
    doInit: function (component, event, helper) {
        console.log('CompactLayout-Aura ', component.get("v.objAPIName"));
        component.set("v.showLoading", true);
        //var siteURL = window.location.origin;
        var portalBaseURL = $A.get("$Label.c.Core_MDF_PFRCommunityLink");
        var communityURLSection = $A.get("$Label.c.Core_MDF_CommunityURLSection");
        var ViewType = component.get("v.isCompactLayout") == 'Yes' ? 'Compact Layout' : 'Detail Layout';
        console.log('#### ', ViewType);
        helper.call(component.get("c.getObjectFields"), {
            recordId: component.get("v.recordId"),
            objAPIName: component.get("v.objAPIName"),
            fieldAPIName: component.get("v.fieldAPIName"),
            fieldAPIoperator: component.get("v.fieldAPIoperator"),
            fieldView: ViewType
        }).then(function (result) {
            if (result != null) {
                //this.isShow = true;
                var hiddenFieldDetailsMap = new Map();
                var objProperties = [];
                let index = 1;
                let fieldRecord;
                var formatter = new Intl.NumberFormat('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });
                for (var key in result) {
                    if (key == 'Internal User') {
                        component.set("v.isInternalUser", true);
                    } else if (key == 'External User') {
                        component.set("v.isExternalUser", true);
                    }
                    for (let i = 0; i < result[key].length; i++) {
                        let record = {};
                        let type;
                        if (result[key][i].fieldValue != '' && result[key][i].fieldValue != null && !result[key][i].isHiddenFromUI) {
                            if (result[key][i].fieldType == 'REFERENCE') {
                                var hasCustomUrl = !!result[key][i].lookupCustomUrlInd;
                                if (key == 'Internal User') {                                    
                                    record.url = hasCustomUrl ? `/lightning/n/${result[key][i].lookupCustomUrlValue}?c__recordId=${result[key][i].fieldValue}` : `/lightning/r/${result[key][i].parentObjectName}/${result[key][i].fieldValue}/view`;
                                } else {                                    
                                    record.url = hasCustomUrl ? portalBaseURL +'s/'+ result[key][i].lookupCustomUrlValue + '?recordId=' + result[key][i].fieldValue : portalBaseURL + communityURLSection + result[key][i].fieldValue;
                                }
                                record.urlName = result[key][i].fieldValueName;
                                record.parentObjectId = result[key][i].fieldValue;
                                record.parentObjectName = result[key][i].parentObjectName;
                                record.index = index;
                                record.tabIcon = result[key][i].tabIcon != '' ? result[key][i].tabIcon : '';
                                index = index + 1;
                                type = 'REFERENCE';
                            } else if (result[key][i].fieldType == 'DATE') {
                                var date = new Date(result[key][i].fieldValue);
                                let month = '' + (date.getMonth() + 1);
                                let day = '' + date.getDate();
                                let year = date.getFullYear();
                                result[key][i].fieldValue = [month, day, year].join('/');
                                type = 'STRING';
                            } else if (result[key][i].fieldType == 'BOOLEAN') {
                                record.booleanFieldValue = result[key][i].fieldValue == 'true' ? true : false;
                                type = 'BOOLEAN';
                            } else if (result[key][i].fieldType == 'CURRENCY') {
                                result[key][i].fieldValue = formatter.format(result[key][i].fieldValue);
                                type = 'STRING';
                            } else if (result[key][i].fieldType == 'DOUBLE') {
                                result[key][i].fieldValue = Number(result[key][i].fieldValue.slice(0, result[key][i].fieldValue.lastIndexOf('.') + 0)).toLocaleString('en-US') + '.' + result[key][i].fieldValue.slice(result[key][i].fieldValue.lastIndexOf('.') + 1);
                                type = 'STRING';
                            }
                            else {
                                type = 'STRING';
                            }
                        } else {
                            type = 'STRING';
                            hiddenFieldDetailsMap.set(result[key][i].fieldLabel,result[key][i].fieldValue);
                        }
                        fieldRecord = result[key][i].fieldValue != '' ? record : '';
                        var noOfCol = 12 / result[key][i].noOfColumns;                        
                        if(!result[key][i].isHiddenFromUI ){
                            //Added for cogtm check 
                            if(result[key][i].fieldValue == $A.get("$Label.c.Core_MDF_Co_GTM_program_name")){
                                component.set("v.isCoGtm",true);
                            }
                        objProperties.push({
                            'label': result[key][i].fieldLabel,
                            'value': type != 'STRING' ? fieldRecord : result[key][i].fieldValue,
                            'isreferenceField': result[key][i].fieldType == 'REFERENCE' ? true : false,
                            'isbooleanField': result[key][i].fieldType == 'BOOLEAN' ? true : false,
                            'istextField': type == 'STRING' ? true : false,
                            'position': result[key][i].fieldPosition,
                            'isAccessible': result[key][i].isAccessible,
                            'helpText': result[key][i].helpText,
                            'section': result[key][i].section,
                            'noOfColumns': noOfCol
                        });
                    }
                }
                }
                component.set("v.hiddenFieldsMap", hiddenFieldDetailsMap);
                console.log('objProperties -- Aura', objProperties);
                component.set("v.compactLayoutFields", objProperties);
            } else {
                component.set("v.showLoading", false);
            }
        }).catch((error) => {
            console.log('Error in loading. Error : ', error);
        });
		var userId = $A.get("$SObjectType.CurrentUser.Id");
        helper.call(component.get("c.getObjActions"), {
            recordId: component.get("v.recordId"),
            objAPIName: component.get("v.objAPIName"),
            fieldAPIName: component.get("v.fieldAPIName"),
            fieldView: ViewType,
            fieldAPIoperator: component.get("v.fieldAPIoperator")
        }).then(function (result) {
            if (result != null) {
                var quickActionsButtons = [];
                var quickActionsHideButtons = [];
                var recordDetails = [];
                for (var key in result) {
                    recordDetails = key.split("$%@#");
                    component.set("v.cmptLayoutIcon", recordDetails[0]);
                    component.set("v.objLabel", recordDetails[1]);
                    component.set("v.title", recordDetails[2]);
                    var quickActionCount = 0;
                    for (let i = 0; i < result[key].length; i++) {
                        if(result[key][i].label != 'Sharing' || (result[key][i].label == 'Sharing' && (recordDetails[3] == userId || recordDetails[4] == 'System Administrator' || recordDetails[4] == 'IT Admin'))){
                            if (quickActionCount < 3) {
                                quickActionsButtons.push(result[key][i]);
                            } else {
                                quickActionsHideButtons.push({
                                    'label': result[key][i].label,
                                    'type': result[key][i].orgLabel + ',' + result[key][i].type
                                });
                            }
                        }
                        quickActionCount = quickActionCount + 1;
                    }
                }
                if (quickActionCount > 3) {
                    component.set("v.buttonMenu", true);
                }
                component.set("v.quickActionsButtons", quickActionsButtons);
                component.set("v.quickActionsHideButtons", quickActionsHideButtons);
                component.set("v.showLoading", false);
            } else {
                component.set("v.showLoading", false);
            }
        }).catch((error) => {
            console.log('Error in loading for QuickAction. Error : ', error);
        });
    },

    /* Handle Mouse Over*/
    handleMouseover: function (component, event, helper) {
        var index = event.getSource().get("v.title");
        const toolTipDiv = document.querySelector('[data-id="' + index + '"]');
        toolTipDiv.style.opacity = 1;
        toolTipDiv.style.display = "block";
    },

    /* Handle Mouse Out*/
    handleMouseout: function (component, event, helper) {
        var index = event.getSource().get("v.title");
        const toolTipDiv = document.querySelector('[data-id="' + index + '"]');
        toolTipDiv.style.opacity = 0;
        toolTipDiv.style.display = "none";
    },

    /* Handle On Click Function For Buttons*/
    handleOnClick: function (component, event, helper) {
         var buttonDetails = [];
        buttonDetails = event.target.value.split(",");
        helper.quickActionFunction(component, event.target.getAttribute("data-id"), buttonDetails[0]);
    },

    /* Handle On Select Function For Button Menu*/
    handleOnselect: function (component, event, helper) {
        var ev = event.getParam("value");;
        var buttonDetails = [];
        buttonDetails = ev.split(",");
        helper.quickActionFunction(component, buttonDetails[0], buttonDetails[1]);
    },

    closeModal: function (component, event, helper) {
        component.set("v.openModalForUpdateButton", false);
        component.set("v.openModalForLtCmp", false);
        component.set("v.isNotifyOwner", false);
        component.set("v.isDefaultQuickAction", false);
        component.set("v.errorMessage", '');
    },

    saveModal: function (component, event, helper) {
        console.log('FieldValue---> ', component.get("v.fieldValue"));
        component.set("v.isSpinner", true);
        helper.call(component.get("c.updateCampRecord"), {
            recordId: component.get("v.recordId"),
            campStatus: component.get("v.fieldValue")
        }).then(function (result) {
            console.log('result: ', result);
            if(result == 'sucess'){
                component.set("v.isSpinner", false);
                component.set("v.openModalForUpdateButton", false);

                const isCampaign = component.get("v.recordId").startsWith('701');  //Roshan
                var toastMessage;
                if(isCampaign) {
                    toastMessage = component.get("v.fieldValue") == 'Cancelled' ? $A.get("$Label.c.Core_MDF_Campaign_has_been_cancelled") : $A.get("$Label.c.Core_MDF_CampaignSaveToast") + ' ' + $A.get("$Label.c.Core_MDF_CampaignToast");
                } else {
                    toastMessage = $A.get("$Label.c.Core_MDF_ClaimWasSaved");
                }
                
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        mode: 'dismissable',
                        type: 'success',
                        message: toastMessage
                    });
                    toastEvent.fire();
                    setTimeout(function () {
                        window.location.reload();
                    }, 2500);
            } else {
                component.set("v.isSpinner", false);
                component.set("v.errorMessage", result);
            }
        }).catch((error) => {
            console.log('Error in loading for QuickAction. Error : ', error);
        });
    },
    
    confirmAction : function(component, event, helper) {        
        var action = component.get("c.notifyPartner");
        action.setParams({
             recordId: component.get("v.recordId")
        });
        component.set("v.openModalForUpdateButton", false);
        $A.enqueueAction(action);
        location.reload();        
     },

    closeModalAndDisplayErrorMsg: function(component, event, helper) {
        let errorMessage = event.getParam('errorLog');
        let objName = component.get("v.objAPIName");
        helper.logErrors(component, errorMessage, objName);
    },    
})