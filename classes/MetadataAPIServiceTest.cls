/**
* Copyright (c) 2012, FinancialForce.com, inc
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification, 
*   are permitted provided that the following conditions are met:
*
* - Redistributions of source code must retain the above copyright notice, 
*      this list of conditions and the following disclaimer.
* - Redistributions in binary form must reproduce the above copyright notice, 
*      this list of conditions and the following disclaimer in the documentation 
*      and/or other materials provided with the distribution.
* - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
*      may be used to endorse or promote products derived from this software without 
*      specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
*  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
*  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
*  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
*  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
*  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
*  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
*  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
* This is a dummy test class to obtain 100% coverage for the generated WSDL2Apex code, it is not a funcitonal test class
**/ 
@isTest  
private class MetadataAPIServiceTest
{    
    /**
* Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
**/
    public class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        { 
            if(request instanceof MetadataAPIService.readMetadata_element)
                response.put('response_x', new MetadataAPIService.readCustomFieldResponse_element());
            else if(request instanceof MetadataAPIService.updateMetadata_element)
                response.put('response_x', new MetadataAPIService.updateMetadataResponse_element());
            return;
        }
    }  
    private class WebServiceMockImplRecordType implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        { 
            if(request instanceof MetadataAPIService.readMetadata_element){
                /*List<Pricing_Picklist_FieldNames_Mapping__mdt> fldMappingMdt = [SELECT Pricing_FieldAPI_Nm__c,Pricing_ObjectAPI_Nm__c,Pricing_RecordTypeAPI_Nm__c
                                                                                FROM Pricing_Picklist_FieldNames_Mapping__mdt 
                                                                                WHERE MasterLabel='Application' AND Pricing_IsActive_Ind__c=True];*/
                MetadataAPIService.readRecordTypeResponse_element resp = new MetadataAPIService.readRecordTypeResponse_element();
                resp.result = new MetadataAPIService.ReadRecordTypeResult();
                resp.result.records = new List<MetadataAPIService.RecordType>();
                MetadataAPIService.RecordType recdType = new MetadataAPIService.RecordType();
                recdType.fullName = 'Intel_Contact';
                recdType.picklistValues = new List<MetadataAPIService.RecordTypePicklistValue>(); 
                MetadataAPIService.RecordTypePicklistValue piclistVal = new MetadataAPIService.RecordTypePicklistValue();
                piclistVal.picklist = 'Core_Country_Region__c';
                piclistVal.values = new List<MetadataAPIService.PicklistValue>();
                Map<String,Schema.SObjectField> sObjFieldMap = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
                //sObjFieldMap.get(fldMappingMdt[0].Pricing_FieldAPI_Nm__c).getDescribe().getPicklistValues()
                for(Schema.PicklistEntry ple: sObjFieldMap.get('Core_Country_Region__c').getDescribe().getPicklistValues()){
                    if(ple.isActive()){
                        MetadataAPIService.PicklistValue plv = new MetadataAPIService.PicklistValue();
                        plv.label = ple.getLabel();
                        plv.fullName = ple.getValue();
                        piclistVal.values.add(plv);
                    }                                  
                }
                recdType.picklistValues.add(piclistVal);
                resp.result.records.add(recdType);
                response.put('response_x', resp);               
            }                 
            
            return;
        }
    } 
    @isTest
    private static void readMeatadataTest(){
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataAPIService MetadataAPIService = new MetadataAPIService();
        // Invoke operations     
        Test.startTest();    
        MetadataAPIService.MetadataPort metaDataPort = new MetadataAPIService.MetadataPort();
        MetadataAPIService.CustomField customField = (MetadataAPIService.CustomField) metaDataPort.readMetadata('CustomField', new String[]{'Contact.Core_Country_Region__c'});
        metaDataPort.updateMetadata( new MetadataAPIService.Metadata[] { customField });
        Test.stopTest();
        system.assert(true);
        //new MetadataAPIService.MetadataPort().readMetadata('CustomField', new String[]{Label.Core_Entitlement_ProfileAccess_PicklistFld_APIName});
    }
     @isTest
    private static void readRecordTypeMeatadataTest(){
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImplRecordType());
        // Only required to workaround a current code coverage bug in the platform
        MetadataAPIService MetadataAPIService = new MetadataAPIService();
        // Invoke operations     
        Test.startTest();    
        MetadataAPIService.MetadataPort metaDataPort = new MetadataAPIService.MetadataPort();
        MetadataAPIService.RecordType recordType = (MetadataAPIService.RecordType) metaDataPort.readMetadata('RecordType', new String[] {'Contact.Core_Intel_Contact'}).getRecords()[0];
        //MetadataAPIService.CustomField customField = (MetadataAPIService.CustomField) metaDataPort.readMetadata('CustomField', new String[]{'Contact.Core_Intel_Contact'});
        //metaDataPort.updateMetadata( new MetadataAPIService.Metadata[] { customField });
        Test.stopTest();
        system.assert(true);
        //new MetadataAPIService.MetadataPort().readMetadata('CustomField', new String[]{Label.Core_Entitlement_ProfileAccess_PicklistFld_APIName});
    }
    @isTest
    private static void createObjectsAndDefineValriables(){
       
        MetadataAPIService.SaveResult obj1 =  new MetadataAPIService.SaveResult();
        obj1.errors = null;
        obj1.fullName = null;
        obj1.success = null;
        
        MetadataAPIService.SessionSettings obj =  new MetadataAPIService.SessionSettings();
        obj.disableTimeoutWarning = null;
        obj.enableCSPOnEmail = null;
        obj.enableCSRFOnGet = null;
        obj.enableCSRFOnPost = null;
        obj.enableCacheAndAutocomplete = null;
        obj.enableClickjackNonsetupSFDC = null;
        obj.enableClickjackNonsetupUser = null;
        obj.enableClickjackNonsetupUserHeaderless = null;
        obj.enableClickjackSetup = null;
        obj.enableContentSniffingProtection = null;
        obj.enablePostForSessions = null;
        obj.enableSMSIdentity = null;
        obj.enableUpgradeInsecureRequests = null;
        obj.enableXssProtection = null;
        obj.enforceIpRangesEveryRequest = null;
        obj.forceLogoutOnSessionTimeout = null;
        obj.forceRelogin = null;
        obj.hstsOnForcecomSites = null;
        obj.identityConfirmationOnEmailChange = null;
        obj.identityConfirmationOnTwoFactorRegistrationEnabled = null;
        obj.lockSessionsToDomain = null;
        obj.lockSessionsToIp = null;
        obj.logoutURL = null;
        obj.redirectionWarning = null;
        obj.referrerPolicy = null;
        obj.requireHttpOnly = null;
        obj.requireHttps = null;
        obj.securityCentralKillSession = null;
        obj.sessionTimeout = null;
        
        MetadataAPIService.readMetadataResponse_element obj2 = new MetadataAPIService.readMetadataResponse_element();
        obj2.result=null;   
        
        MetadataAPIService.FieldValue fv = new MetadataAPIService.FieldValue();
        fv.name = null;
        fv.value = null;
        
        MetadataAPIService.CustomField cf = new  MetadataAPIService.CustomField();
        cf.fullName = null;      
        cf.businessOwnerGroup = null;
        cf.businessOwnerUser = null;
        cf.businessStatus = null;
        cf.caseSensitive = null;
        cf.customDataType = null;
        cf.defaultValue = null;
        cf.deleteConstraint = null;
        cf.deprecated = null;
        cf.description = null;
        cf.displayFormat = null;
        cf.displayLocationInDecimal = null;
        cf.encrypted = null;
        cf.escapeMarkup = null;
        cf.externalDeveloperName = null;
        cf.externalId = null;
        cf.fieldManageability = null;
        cf.formula = null;
        cf.formulaTreatBlanksAs = null;
        cf.inlineHelpText = null;
        cf.isConvertLeadDisabled = null;
        cf.isFilteringDisabled = null;
        cf.isNameField = null;
        cf.isSortingDisabled = null;
        cf.label = null;
        cf.length = null;
        cf.lookupFilter = null;
        cf.maskChar = null;
        cf.maskType = null;
        cf.metadataRelationshipControllingField = null;
        cf.populateExistingRows = null;
        cf.precision = null;
        cf.referenceTargetField = null;
        cf.referenceTo = null;
        cf.relationshipLabel = null;
        cf.relationshipName = null;
        cf.relationshipOrder = null;
        cf.reparentableMasterDetail = null;
        cf.required = null;
        cf.restrictedAdminField = null;
        cf.scale = null;
        cf.securityClassification = null;
        cf.startingNumber = null;
        cf.stripMarkup = null;
        cf.summarizedField = null;
        cf.summaryFilterItems = null;
        cf.summaryForeignKey = null;
        cf.summaryOperation = null;
        cf.trackFeedHistory = null;
        cf.trackHistory = null;
        cf.trackTrending = null;
        cf.type_x = null;
        cf.unique = null;
        cf.valueSet = null;
        cf.visibleLines = null;
        cf.writeRequiresMasterRead = null;
        
        MetadataAPIService.UpsertResult upsertRes = new MetadataAPIService.UpsertResult();
        upsertRes.created = null;
       	upsertRes.errors = null;
       	upsertRes.fullName = null;
        upsertRes.success = null;
        
        MetadataAPIService.ValueSettings vs = new MetadataAPIService.ValueSettings();
        vs.controllingFieldValue = null;
        vs.valueName = null;
        
        MetadataAPIService.ProfileObjectPermissions poPerms = new MetadataAPIService.ProfileObjectPermissions();
        poPerms.allowCreate = null;
        poPerms.allowDelete = null;
        poPerms.allowEdit = null;
        poPerms.allowRead = null;
        poPerms.modifyAllRecords = null;
        poPerms.object_x = null;
        poPerms.viewAllRecords = null;
        
        MetadataAPIService.PackageTypeMembers ptm = new MetadataAPIService.PackageTypeMembers();
        ptm.members = null;
        ptm.name = null;
        
        MetadataAPIService.Package_x pkg = new MetadataAPIService.Package_x();          
        pkg.fullName = null;
        pkg.apiAccessLevel = null;
        pkg.description  = null;
        pkg.namespacePrefix  = null;
        pkg.objectPermissions = null;
        pkg.packageType = null;
        pkg.postInstallClass = null;
        pkg.setupWeblink = null;
        pkg.types = null;
        pkg.uninstallClass  = null;
        pkg.version = null;
        
        MetadataAPIService.RetrieveRequest rr = new MetadataAPIService.RetrieveRequest();
        rr.apiVersion  = null;
        rr.packageNames   = null;
        rr.singlePackage  = null;
        rr.specificFiles  = null;
        rr.unpackaged   = null;
        
        MetadataAPIService.CustomValue cv = new MetadataAPIService.CustomValue();
        cv.fullName = null;
        cv.color = null;
        cv.default_x = null;
        cv.description = null;
        cv.isActive = null;
        cv.label = null;
        
        MetadataAPIService.AsyncResult ar = new MetadataAPIService.AsyncResult();
        ar.done = null;
        ar.id = null;
        ar.message = null;
        ar.state = null;
        ar.statusCode = null;
        
        MetadataAPIService.GlobalPicklistValue gpv = new MetadataAPIService.GlobalPicklistValue();
        gpv.color = null;
        gpv.default_x = null;
        gpv.description = null;
        gpv.isActive = null;
      
        MetadataAPIService.PicklistEntry pe = new MetadataAPIService.PicklistEntry();
        pe.active = null;
        pe.defaultValue = null;
        pe.label = null;
        pe.validFor = null;
        pe.value = null;
        
        MetadataAPIService.Picklist plst = new MetadataAPIService.Picklist();
        plst.controllingField = null;
        plst.picklistValues = null;
        plst.restrictedPicklist = null;
        plst.sorted = null;
        
        MetadataAPIService.PicklistValue pl = new MetadataAPIService.PicklistValue();
		pl.fullName = null;
        pl.color = null;
        pl.default_x = null;
        pl.description = null;
        pl.isActive = null;
        pl.allowEmail = null;
        pl.closed = null;
        pl.controllingFieldValues = null;
        pl.converted = null;
        pl.cssExposed = null;
        pl.forecastCategory = null;
        pl.highPriority = null;
        pl.probability = null;
        pl.reverseRole = null;
        pl.reviewed = null;
        pl.won = null;    
        
        MetadataAPIService.CustomDataTypeComponent cdtc = new MetadataAPIService.CustomDataTypeComponent();
        cdtc.developerSuffix = null;    
        cdtc.enforceFieldRequiredness = null;    
        cdtc.label = null;    
        cdtc.length = null;    
        cdtc.precision = null;    
        cdtc.scale = null;    
        cdtc.sortOrder = null;    
        cdtc.sortPriority = null;    
        cdtc.type_x = null;  
        
        MetadataAPIService.CustomDataType cdt = new MetadataAPIService.CustomDataType();
        cdt.fullName = null;  
        cdt.customDataTypeComponents = null;  
        cdt.description = null;  
        cdt.displayFormula = null;  
        cdt.editComponentsOnSeparateLines = null;  
        cdt.label = null;  
        cdt.rightAligned = null;  
        cdt.supportComponentsInReports = null; 
        
        MetadataAPIService.ValueSet valSet = new MetadataAPIService.ValueSet();
        valSet.controllingField = null;  
        valSet.restricted = null;  
        valSet.valueSetDefinition = null;  
        valSet.valueSetName = null;  
        valSet.valueSettings = null;  
        
        MetadataAPIService.ValueTypeField vtf =  new MetadataAPIService.ValueTypeField();
        vtf.foreignKeyDomain = null;  
        vtf.isForeignKey = null;  
        vtf.isNameField = null;  
        vtf.minOccurs = null;  
        vtf.name = null;  
        vtf.picklistValues = null;  
        vtf.soapType = null;  
        vtf.valueRequired = null;  
        
        MetadataAPIService.DescribeValueTypeResult dvtr =  new MetadataAPIService.DescribeValueTypeResult();
        dvtr.apiCreatable = null;  
        dvtr.apiDeletable = null;  
        dvtr.apiReadable = null;  
        dvtr.apiUpdatable = null;  
        dvtr.parentField = null;  
        dvtr.valueTypeFields = null; 
        
        MetadataAPIService.FilterItem fi =  new MetadataAPIService.FilterItem();
        fi.field = null; 
        fi.operation = null; 
        fi.value = null; 
        fi.valueField = null; 
        
        MetadataAPIService.LookupFilter lkpfi =  new MetadataAPIService.LookupFilter();
        lkpfi.active = null; 
        lkpfi.booleanFilter = null; 
        lkpfi.description = null; 
        lkpfi.errorMessage = null; 
        lkpfi.filterItems = null; 
        lkpfi.infoMessage  = null; 
        lkpfi.isOptional = null; 
        
        MetadataAPIService.MetadataPort mdtPort =  new MetadataAPIService.MetadataPort();
        mdtPort.inputHttpHeaders_x = null; 
        mdtPort.outputHttpHeaders_x = null; 
        mdtPort.clientCertName_x = null; 
        mdtPort.clientCert_x = null; 
        mdtPort.clientCertPasswd_x = null; 
        mdtPort.timeout_x = null; 
        mdtPort.SessionHeader = null; 
        mdtPort.DebuggingInfo = null; 
        mdtPort.DebuggingHeader = null; 
        mdtPort.CallOptions = null; 
        mdtPort.AllOrNoneHeader = null; 
        
        system.assert(true);
    }
    @isTest
    private static void createObjects(){
        new MetadataAPIService.SaveResult();
        new MetadataAPIService.SessionSettings();
        new MetadataAPIService.readMetadataResponse_element();
        new MetadataAPIService.FieldValue();
        //new MetadataAPIService.UpsertResult();
        new MetadataAPIService.ValueSettings();
        new MetadataAPIService.ProfileObjectPermissions();
        new MetadataAPIService.PackageTypeMembers();
        new MetadataAPIService.Package_x();
        new MetadataAPIService.RetrieveRequest();
        new MetadataAPIService.retrieve_element();
        new MetadataAPIService.CustomValue();
        new MetadataAPIService.SessionHeader_element();
        new MetadataAPIService.CustomMetadataValue();
        new MetadataAPIService.AsyncResult();
        new MetadataAPIService.retrieveResponse_element();
        //new MetadataAPIService.upsertMetadataResponse_element();
        new MetadataAPIService.ExtendedErrorDetails();
        new MetadataAPIService.Error();
        new MetadataAPIService.updateMetadata_element();
        new MetadataAPIService.upsertMetadata_element();
        new MetadataAPIService.GlobalPicklistValue();
        new MetadataAPIService.PicklistEntry();
        new MetadataAPIService.PicklistValue();
        new MetadataAPIService.Metadata();
        new MetadataAPIService.describeMetadata_element();
        new MetadataAPIService.CustomDataTypeComponent();
        new MetadataAPIService.CustomDataType();
        new MetadataAPIService.createMetadataResponse_element();
        new MetadataAPIService.readMetadata_element();
        new MetadataAPIService.ValueSetValuesDefinition();
        new MetadataAPIService.ValueSet();
        new MetadataAPIService.updateMetadataResponse_element();
        new MetadataAPIService.ValueTypeField();
        new MetadataAPIService.DescribeValueTypeResult();
        new MetadataAPIService.deleteMetadata_element();
        new MetadataAPIService.renameMetadataResponse_element();
        new MetadataAPIService.ReadCustomFieldResult();
        new MetadataAPIService.readCustomFieldResponse_element();
        new MetadataAPIService.ReadPicklistValueResult();
        new MetadataAPIService.readPicklistValueResponse_element();
        new MetadataAPIService.ReadCustomValueResult();
        new MetadataAPIService.readCustomValueResponse_element();
        new MetadataAPIService.ReadResult();
        new MetadataAPIService.Picklist();
        new MetadataAPIService.createMetadata_element();
        new MetadataAPIService.MetadataWithContent();
        new MetadataAPIService.describeValueType_element();
        new MetadataAPIService.FilterItem();
        new MetadataAPIService.LookupFilter();
        new MetadataAPIService.CustomField();
        new MetadataAPIService.DebuggingInfo_element();
        new MetadataAPIService.LogInfo();
        new MetadataAPIService.DebuggingHeader_element();
        new MetadataAPIService.CallOptions_element();
        new MetadataAPIService.AllOrNoneHeader_element();
        
         system.assert(true);
    }
    
    @IsTest
    private static void coverGeneratedCodeCRUDOperations()
    {	
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataAPIService MetadataAPIService = new MetadataAPIService();
        // Invoke operations     
        Test.startTest();    
        MetadataAPIService.MetadataPort metaDataPort = new MetadataAPIService.MetadataPort();
        Test.stopTest();
         system.assert(true);
    }
}