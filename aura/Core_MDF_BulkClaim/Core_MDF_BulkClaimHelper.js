({
    /* This method fetches the User Language 
       and The Template Details on Component Initialization  
    */
    fetchBulkClaimTemplate: function (component, event, helper) {
        var recTypeDevloperName = component.get("v.programLabel");
        var action = component.get("c.fetchUserAndTemplateDetails");
        console.log(component.get("v.recordTypeMap"));
        action.setParams
        ({
            programName: component.get("v.recordTypeMap")[recTypeDevloperName]
        })//selected recordtype value 
        action.setCallback(this, function (response) {
            var downloadTemplateLink = component.find("downloadTemplate");
            var templateNotAvailable = component.find("noTemplateAvailable");
            this.toggleSpinner(component, event);
            var state = response.getState();
            //alert(state);
            if (component.isValid() && state === "SUCCESS") {
                var userAndTemplateDataList = response.getReturnValue();
                console.log('userAndTemplateDataList = '+ userAndTemplateDataList);
                if (userAndTemplateDataList != null && userAndTemplateDataList.length > 1) { 
                    component.set("v.fileId", userAndTemplateDataList[0]);
                    console.log('field---'+userAndTemplateDataList[0]);
                    if (userAndTemplateDataList[1] == $A.get("$Label.c.Core_MDF_Partner_User_Type")) {
                        component.set("v.isPortal", true);
                    }
                    this.toggleSpinner(component, event);
                    $A.util.addClass(downloadTemplateLink, "slds-show");
                    $A.util.removeClass(downloadTemplateLink, "slds-hide");
                    $A.util.removeClass(templateNotAvailable, "slds-show");
                    $A.util.addClass(templateNotAvailable, "slds-hide");
                } else {
                    this.toggleSpinner(component, event);
                    $A.util.removeClass(downloadTemplateLink, "slds-show");
                    $A.util.addClass(downloadTemplateLink, "slds-hide");
                    $A.util.addClass(templateNotAvailable, "slds-show");
                    $A.util.removeClass(templateNotAvailable, "slds-hide");
                }
            } else if (state === "ERROR") {
                this.toggleSpinner(component, event);
                this.showToast(component,event,'Error', $A.get("$Label.c.Core_MDF_Error"), $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
            }
        });
        $A.enqueueAction(action);
    },
    
    /* This method validates the file uploaded by the User
       stores the content and the file details  
    */
    handleUploadFinished: function (component, event, helper) {
        var reader = new FileReader();
        if ((this.checkUIValidations(component, event, helper))) {
            this.toggleSpinner(component, event);
            var files = component.get("v.fileToBeUploaded");
            if (files && files.length > 0) {
                var file = files[0][0];
                component.set("v.file", file);
                reader.onloadend = function () {
                    var dataURL = reader.result;
                    var content = dataURL.match(/,(.*)$/)[1];
                    component.set("v.content", content);
                    helper.toggleSpinner(component, event);
                    //helper.showToast(component, event, 'Info', $A.get("$Label.c.Core_MDF_BulkClaimUploadFileSuccessMsg"));
                    helper.showToast(component, event,'Info', $A.get("$Label.c.Core_MDF_Info"), $A.get("$Label.c.Core_MDF_File")+' "'+component.get("v.file").name +'" '+$A.get("$Label.c.Core_MDF_BulkClaimUploadFileSuccessMsg"));
                }
                reader.readAsDataURL(file);
            } else {
                this.toggleSpinner(component, event);
                this.showToast(component, event,'Error', $A.get("$Label.c.Core_MDF_Error"), $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
            }
        }
    },
    /* This method calls the parseFile method of the Server
       to parse the uploaded file  
    */
    parsefile: function (component, event, helper) {
        if ((this.checkUIValidations(component, event, helper))) {
            // call Server method to send the file
            this.toggleSpinner(component, event);
            var file = component.get("v.file");
            var action = component.get("c.parseFile");
            action.setParams({
                base64Data: component.get("v.content"),
                fileName: file.name,
                channelProgramId: component.get("v.programId")
            });
            action.setCallback(this, function (response) {
                if (response.getState() == "SUCCESS" && response.getReturnValue() != null && !response.getReturnValue().startsWith('Exception')
                    && !response.getReturnValue().startsWith('UIException')) {
                    this.toggleSpinner(component, event);
                    this.showToast(component, event,'Success', $A.get("$Label.c.Core_MDF_Success"), $A.get("$Label.c.Core_MDF_Bulk_claim_success_msg"));
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": response.getReturnValue()
                    });
                    navEvt.fire();
                }
                else if (response.getState() == "SUCCESS" && response.getReturnValue() != null && response.getReturnValue().startsWith('UIException')) {
                    this.toggleSpinner(component, event);
                    var returnMsg = response.getReturnValue().replace('UIException', '');
                    var validationMessages = returnMsg.split('\n');
                    var errorMessageLength = validationMessages.length - 1;
                    var errorMsg = '';
                    if (errorMessageLength > $A.get("$Label.c.Core_MDF_Error_Message_Count")) {
                        errorMsg = $A.get("$Label.c.Core_MDF_bulk_claim_generic_error_message");
                        this.showToast(component, event,'Error', $A.get("$Label.c.Core_MDF_Error"), errorMsg);
                    } else {
                        errorMsg = '';
                        var eachLine;
                        for (eachLine in validationMessages) {
                            if(eachLine != null){
                            errorMsg = errorMsg + validationMessages[eachLine] + '\n';
                            }
                        }
                        console.log('errorMsg', errorMsg);
                        this.showToast(component, event,'Error', $A.get("$Label.c.Core_MDF_Error"), errorMsg);
                    }
                } else {
                    this.toggleSpinner(component, event);
                    this.showToast(component, event,'Error', $A.get("$Label.c.Core_MDF_Error"), $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
                }
            });
            $A.enqueueAction(action);
        }
    },
    /* This method is used to hide/show the spinner 
    */
    toggleSpinner: function (component, event) {
        console.log('came in toggle');
        var spinner = component.find("fileprogressBar");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    /* This method is used to check all the front End Validations
        And Returns True/False based on the results
    */
    checkUIValidations: function (component, event, helper) {
        var validationError = true;
        // Check if the Channel Program entered is Not Null
        if (component.get("v.programId") == '') {
            var programIdComponent = component.find("programInputHelpMsg");
            $A.util.removeClass(programIdComponent, "slds-hide");
            $A.util.addClass(programIdComponent, "slds-show");
            validationError = false;
        }
        // Check if the File is Uploaded by the User
        var files = component.get("v.fileToBeUploaded");
        var fileUploadComponent = component.find("fileInputHelpMsg");
        if (files == null) {
            $A.util.removeClass(fileUploadComponent, "slds-hide");
            $A.util.addClass(fileUploadComponent, "slds-show");
            validationError = false;
        } else {
            $A.util.removeClass(fileUploadComponent, "slds-show");
            $A.util.addClass(fileUploadComponent, "slds-hide");
        }
        // Check if the File Uploaded by the User is in expected format and its size is less than 1 MB
        if (files && files.length > 0) {
            var file = files[0][0];
            var fileName = file.name;
            var fileExtension = fileName.substr(fileName.lastIndexOf('.') + 1).toLowerCase();
            if (fileExtension != 'csv') {
                validationError = false;
                this.showToast(component, event,'Error', $A.get("$Label.c.Core_MDF_Error"), $A.get("$Label.c.Core_MDF_Please_Upload_CSV_File"));
            }
            if (file.size >= 1000000) {
                validationError = false;
                this.showToast(component, event,'Error', $A.get("$Label.c.Core_MDF_Error"), $A.get("$Label.c.Core_MDF_Bulk_Claim_File_Size_Big"));
            }
        }
        return validationError;
    },
    /* This method is used to show the Error / Success toast message
        based on the type and the message passed in it
    */
    showToast: function (component, event, type, title, message) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "type": type,
            "title": title,
            "message": message,
            "duration": 6000,
            "mode": 'sticky'
        });
        resultsToast.fire();
    },
    /* This method is used to fetch RecordType Matadata in order to load the correct 
    * template based on the Program selected by the User
    */
    fetchRecordTypeMetaData: function (component) {
        var action = component.get("c.fetchRecordTypeMetaData");
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS" && response.getReturnValue() != null) {
                var recTypeMap = response.getReturnValue();
                component.set('v.recordTypeMap', recTypeMap);                               
            }            
            else { this.showToast(component, event,'Error', $A.get("$Label.c.Core_MDF_Error"), $A.get("$Label.c.Core_MDF_ApplicationErrorMessage")); }
        });
        $A.enqueueAction(action);
    },
    /* This method is used to show the active available Activity Sub type values
        based on the record types
    */
    fetchAvailActSubTypeValues: function (component, event, helper) {
        var action = component.get("c.fetchAvailActSubTypeValues");
        action.setParams
        ({
            programName: component.get("v.programLabel")
        })
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS" && response.getReturnValue() != null) {
                var picklistval = response.getReturnValue();
                component.set('v.activitySubTypes', picklistval);
            }            
            else {component.set('v.loadSpinner',false);
                this.showToast(component, event,'Error', $A.get("$Label.c.Core_MDF_Error"), $A.get("$Label.c.Core_MDF_ApplicationErrorMessage")); }
        });
        $A.enqueueAction(action);
    },
    
    /* This method is used to show the country values*/
    fetchAvailCountries: function (component, event, helper) {
        var action = component.get("c.fetchAvailCountries");        
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS" && response.getReturnValue() != null) {
                var picklistval = response.getReturnValue();
                component.set('v.countryList', picklistval);
            }            
            else {component.set('v.loadSpinner',false);
                this.showToast(component, event,'Error', $A.get("$Label.c.Core_MDF_Error"), $A.get("$Label.c.Core_MDF_ApplicationErrorMessage")); }
        });
        $A.enqueueAction(action);
    },
    
    /* This method is used to show the currency values*/
    fetchAvailCurrencies: function (component, event, helper) {
        var action = component.get("c.fetchAvailCurrencies"); 
        var picklistResult = [];
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS" && response.getReturnValue() != null) {
                component.set('v.currencyColumns', [
                    {label: $A.get("$Label.c.Core_MDF_BulkClaimCurrencyName"), fieldName: 'currencyName', type: 'text'},
                    {label: $A.get("$Label.c.Core_MDF_BulkClaimSuppCurrencyCode"), fieldName: 'currencyCode', type: 'text'}]);
                component.set('v.currencyData',response.getReturnValue());
                component.set('v.loadSpinner',false);
            }            
            else {component.set('v.loadSpinner',false);
                this.showToast(component, event,'Error', $A.get("$Label.c.Core_MDF_Error"), $A.get("$Label.c.Core_MDF_ApplicationErrorMessage")); }
        });
        $A.enqueueAction(action);
    },

    /*This method is to decide the mandatory fields and guidelines to be displayed conditionally based on program */
    displayMandatoryFieldsBasedOnProgram: function(component, programName) {
        if(programName.toLowerCase() == $A.get("$Label.c.Core_MDF_Retail_Program_Name").toLowerCase()) {
            component.set("v.showMetricsGuideline", true);
            component.set("v.showVatOptinAsMandatoryField", true);
            component.set("v.vatOptInMandatory", $A.get("$Label.c.Core_MDF_RMF_Vat_Required"));
            component.set("v.bankMandatory", $A.get("$Label.c.Core_MDF_RMF_Bank_Required_Message"));
        } else if(programName.toLowerCase() == $A.get("$Label.c.Core_MDF_CCF_Program_Name").toLowerCase()) {
            component.set("v.showMetricsGuideline", true);
            component.set("v.showTaxAsMandatoryField", true);
            component.set("v.bankMandatory", $A.get("$Label.c.Core_MDF_CCF_Bank_Required_Message"));
            component.set("v.taxMandatory", $A.get("$Label.c.Core_MDF_CCF_Tax_Required_Message"));
        } else if (programName.toLowerCase() == $A.get("$Label.c.Core_MDF_Non_Localized_DCF_Program_Name").toLowerCase()) {
            component.set("v.showMetricsGuideline", true);
            component.set("v.showTaxAsMandatoryField", true);
            component.set("v.bankMandatory", $A.get("$Label.c.Core_MDF_DCF_Bank_Required_Message"));
            component.set("v.taxMandatory", $A.get("$Label.c.Core_MDF_DCF_Tax_Required_Message"));
        }
    },

    //display the info message 
    displayInfoMessage: function(component,event,helper) {
        var action =component.get("c.displayInfoMessage");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.infoMessageInd",response.getReturnValue());
            }
            console.log('v.infoMessageInd',v.infoMessageInd);
        });
        $A.enqueueAction(action);
    }
})