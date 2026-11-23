@isTest
        public class Core_IPS_BES_CaseAttachmentsJSON_Test {
            
            public static TestMethod void tesMethod1(){
                Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
                backendSystem.Name = 'HSDES-PSG01';
                backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
                backendSystem.Core_IPS_SCFT_Backend_Type__c = 'HSDES_SCFT';
                insert backendSystem;
                List<Core_Trigger_Executions__c> triggerExcecutionLst = new List<Core_Trigger_Executions__c>();
                triggerExcecutionLst.add(new Core_Trigger_Executions__c(Core_Active__c=true, Name ='InsertCaseCommentForAttach', Core_Trigger_Events__c = 'After Insert, After update', 
                                                                                              Core_Class_Name__c = 'Core_IPS_CasePromotion_Handler',Core_Description__c= 'test descritpion', Core_Object__c = 'Attachment'));
                 triggerExcecutionLst.add(new Core_Trigger_Executions__c(Core_Active__c=true, Name ='UpdateCaseComntDscptnForAttach', Core_Trigger_Events__c = 'After Insert, After update', 
                                                                                              Core_Class_Name__c = 'Core_IPS_CasePromotion_Handler',Core_Description__c= 'test descritpion', Core_Object__c = 'Attachment'));
                insert triggerExcecutionLst;
                List<Core_IPS_Labels__c> lstCs = new List<Core_IPS_Labels__c>();
               
              Profile dataMigPrf = [select id, name from Profile where name = 'CCP - Core Access' Limit 1];
                  lstCs.add(new Core_IPS_Labels__c(name = 'Data Migration Profile Id', Value__c=dataMigPrf.Id));// Avoid Hardcoding Id Fix - Shipra
        
                // lstCs.add(new Core_IPS_Labels__c(name = 'Data Migration Profile Id', Value__c='00eo0000000f7Gd'));
                lstCs.add(new Core_IPS_Labels__c(name = 'COMPLETE', Value__c='COMPLETE'));
                lstCs.add(new Core_IPS_Labels__c(Name = 'IPS Standard Entitlement', Value__c='IPS Standard Entitlement'));
                lstCs.add(new Core_IPS_Labels__c(Name = 'PRIVATE_TO_INTEL', Value__c = 'Private to Intel'));
                lstCs.add(new Core_IPS_Labels__c(Name = 'Agent', Value__c = 'Agent'));
                lstCs.add(new Core_IPS_Labels__c(Name = 'PUBLIC_TO_CUSTOMERS', Value__c = 'Public to Customers'));
                lstCs.add(new Core_IPS_Labels__c(Name = 'PRIVATE_TO_PARTNERS', Value__c = 'PRIVATE_TO_PARTNERS'));
                lstCs.add(new Core_IPS_Labels__c(Name = 'Backend Integration', Value__c = 'Backend Integration'));
                lstCs.add(new Core_IPS_Labels__c(name = 'Partner', value__c = 'Partner'));
                insert lstCs;
                List<IPS_Case_Attachment_Fields__c> listAttachment = new List<IPS_Case_Attachment_Fields__c>();
                listAttachment.add(new IPS_Case_Attachment_Fields__c(Name = 'Attachment Visibility',Attachment_Field_API_Name__c = 'Core_IPS_Attachment_Visibility__c', Attachment_Field_Type__c = 'Picklist', JSON_Field_Name__c ='attachment_visibility',     Object_Name__c = 'Core_IPS_Case_Attachments__c'));
                listAttachment.add(new IPS_Case_Attachment_Fields__c(Name = 'File URL', Attachment_Field_API_Name__c = 'Core_File_URL__c', Attachment_Field_Type__c = 'URL(255)', JSON_Field_Name__c ='file_url',   Object_Name__c = 'Core_IPS_Case_Attachments__c'));
                listAttachment.add(new IPS_Case_Attachment_Fields__c(Name = 'File Name', Attachment_Field_API_Name__c = 'Core_File_Name__c', Attachment_Field_Type__c = 'Text(255)', JSON_Field_Name__c ='file_name',   Object_Name__c = 'Core_IPS_Case_Attachments__c'));
                insert listAttachment;
                Core_IPS_Backend_Routing__c backendRoutingRule = new Core_IPS_Backend_Routing__c();
                backendRoutingRule.Core_IPS_Backend_Routing_Order__c = 1;
                backendRoutingRule.Core_IPS_Queue__c = 'IPS - Unassigned Cases';
                backendRoutingRule.Core_IPS_Auto_Promote__c = true;
                backendRoutingRule.Core_IPS_New_Backend_System__c = backendSystem.Id;
                insert backendRoutingRule;
                //Case cs = TestUtilities.getCase();
                Case cs = new Case();
                cs.Status = 'New';
                cs.Origin = 'Web';
                cs.Priority = 'High';
                cs.Subject = 'TestSubject';
                cs.Description = 'TestDescription';
                cs.Core_IPS_New_Backend_System__c = backendSystem.Id;
                cs.Core_IPS_BackendID__c = '12121212';
                insert cs;
                List<Id> attachList = new List<Id>();
                Core_IPS_Case_Attachments__c  attach = new Core_IPS_Case_Attachments__c();
                attach.Core_File_Name__c =  'sample file name';
                attach.Core_IPS_Attachment_Visibility__c = 'Public to Customers';
                attach.Core_Case__c = cs.Id;
                attach.Core_File_Description__c = 'sample description';
                attach.Core_File_Size__c = '123.5 kb';
                attach.Core_Upload_Status__c= 'Complete';
                attach.Core_File_URL__c = 'https://esft.intel.com/sftservices/download/IPS_SCFT?FileName=Embedded%20and%20Industrial%20Baytrail%20Pass%20Through%20Messaging%203%203%2017.pdf&AppFileID=c6215817-b11e-4b19-be91-70221da56a56&AppData=caseId-500o000000P09baAAB';
                attach.Core_Type__c = 'Attachment'; 
                insert attach;
                attach.Core_Upload_Status__c= 'Complete';
                update attach;
                attachList.add(attach.Id);
                   List<Core_IPS_BES_Outbound_Message__c> outboundObject = new List<Core_IPS_BES_Outbound_Message__c>();
                    outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
                    insert outboundObject;
                    if(outboundObject.size()>0){
                        outboundObject[0].core_IPS_Outbound_Message_ID__c = '123';
                        outboundObject[0].Core_IPS_Case_ID__c = cs.Id; 
                        outboundObject[0].Core_IPS_Attachment_ID__c = attach.Id;
                        outboundObject[0].Status__c = 'Apigee Success';
                        update outboundObject;
                        Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[0].Id});   
                        Core_IPS_BES_Outbound_Message__c outboundMessage = [SELECT Id,Status__c FROM Core_IPS_BES_Outbound_Message__c WHERE Id = :outboundObject[0].Id];
                        System.assertEquals('Apigee Failed', outboundMessage.Status__c, 'Status should match');
                        
        
                }
                
            } 
            
            
        
        }