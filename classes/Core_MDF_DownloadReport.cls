/******************************************************************************************************
* Class Name  : Core_MDF_DownloadReport 
* Version     : 1.0 
* Created Date: 27-03-2020
* Modification Log :
* Developer           Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - VD     27-03-2020          Controller class to download report
*******************************************************************************************************/
public without sharing class Core_MDF_DownloadReport {
    public static string userName;
    
    /**********************************/
    /**********************************/
    
    @AuraEnabled
    public  static Boolean getUserDetails (Id userId,Id internalAuditRecId){
        system.debug('##**UserId'+userId);
        
        String loggedInUserType = UserInfo.getUserType();
        
        if(loggedInUserType == Label.Core_MDF_ReleaseHold_PartnerUserType){
            User user = [select id, contactid,contact.AccountId,FirstName,LastName ,contact.Core_Audience__c from User where id=:userId];
            userName = user.FirstName+user.LastName;// - remaining in Flow
            
           //Id userContact = user.contactid;
            
           // Contact cont = [select id,(Select id from Contact_Entitlements__r),() from Contact where Id =: userContact ];
            
            //User usr1 = [Select id,(select id,(Select id from Contact_Entitlements__r) from Contact where Id =: userContact) from User where contactId =:cont.Id];
            
            Map<String,String> abbreviatedNameAndTechProgNameMap = new Map<String,String>();
            Set<String> channelProgTechProgNameSet = new Set<String>();
            
            
            for(Core_MDF_ChannelProgram__mdt channelProgramMdt : [Select Label,Core_MDF_Program_Name__c,Core_MDF_Technical_Program_Name__c from Core_MDF_ChannelProgram__mdt]){
                abbreviatedNameAndTechProgNameMap.put(channelProgramMdt.Core_MDF_Program_Name__c,channelProgramMdt.Core_MDF_Technical_Program_Name__c);
            }
            
            for(String abbreviatedName :abbreviatedNameAndTechProgNameMap.keyset()){
                if(user.contact.Core_Audience__c.contains(abbreviatedName)){
                    channelProgTechProgNameSet.add(abbreviatedNameAndTechProgNameMap.get(abbreviatedName));
                }
            }
            
            Account loggedInUserAcct = [Select id,name from account where id=:user.Contact.AccountId];
            system.debug('**loggedInUserCAcctV'+loggedInUserAcct);
            
            List<Account> allNodeAcctsList = [select id,Core_MDF_Channel_Program__c from account where Core_MDF_CoMarketing_Ultimate_Account__c=:loggedInUserAcct.Id];
            
            List<Core_MDF_Partner_Group_Mapping__c> pgm = [Select id,Core_MDF_Group_Name__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c from Core_MDF_Partner_Group_Mapping__c 
                                                           where Core_MDF_Account__c =:loggedInUserAcct.Id 
                                                           AND Core_MDF_Type_Of_Access__c=:Label.Core_MDF_External_label_for_PGM
                                                           AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c IN : channelProgTechProgNameSet];
            system.debug('PGVDM'+pgm);
            
            List<groupmember> grpMemLst = [select id,Group.developerName,group.name,UserOrGroupId from groupmember where Group.developerName =:pgm[0].Core_MDF_Group_Name__c ];
            
            List<Id> userIdList = new List<Id>();
            
            for(groupmember grpMem : grpMemLst){
                userIdList.add(grpMem.UserOrGroupId);
            }
            
            //getting details of all the users
            List<User> userList = [Select Id,ContactId,LastName,FirstName,Email,IsActive,Country from User where Id IN : userIdList];
            system.debug('VuserListD'+userList);
            List<Id> contIdList = new List<Id>();
                        
            for(User usr : userList){
                contIdList.add(usr.ContactId);
            }
            
            //List<Contact> contList = [select id,AccountId, (select Core_Entitlement_Id__r.Name,Core_Status_Change_Date_Time__c,Core_Selected__c from Contact_Entitlements__r) from Contact where id IN : contId];
            //List<User> usrList = [select contactid,contact.AccountId,FirstName,LastName from User where contactId IN : contList];
            
            Integer listOfAUSize ;
            Integer entitlementSize ;
            //getting all the account user info of all the users
            List<Core_MDF_Partner_Node_User_Mapping__c> listOfAU = [Select id,Core_MDF_User__c,Core_MDF_Account__c,Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name,Core_MDF_Account__r.Name from Core_MDF_Partner_Node_User_Mapping__c 
                                                                    where Core_MDF_User__c IN : userList and Core_MDF_Account__c IN : allNodeAcctsList];           
            listOfAUSize = listOfAU.size();
                        
            List<Core_Contact_Entitlement__c> contEntitlements = [Select Core_Entitlement_Id__r.Name,Core_Status_Change_Date_Time__c,Core_Selected__c from Core_Contact_Entitlement__c where Core_Contact_Id__c IN : contIdList];
            entitlementSize = contEntitlements.size();
            //system.debug('contEntitlementVDs'+contEntitlements);
            
            //List<Core_MDF_Partner_Node_User_Mapping__c> listOfAUs = new List<Core_MDF_Partner_Node_User_Mapping__c>();
            
            
            /*if(usrList != Null && usrList.size() > 0 && allNodeAcctsList != Null && allNodeAcctsList.size()>0){
               listOfAUs = [Select id,Core_MDF_User__c,Core_MDF_User__r.ContactId,Core_MDF_User__r.LastName, Core_MDF_User__r.FirstName,Core_MDF_User__r.Email,Core_MDF_User__r.IsActive,
                            Core_MDF_User__r.Country,Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name, Core_MDF_Account__r.Name 
                            from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_User__c IN : usrList and Core_MDF_Account__c IN : allNodeAcctsList]; 
                listOfAUsSize = listOfAUs.size();
            }            
            
            system.debug('VlistOfAUsD'+listOfAUs);*/
            
            string reportHeader = 'ContactId' +Core_MDF_PaymentUtility.tab +'Last Name'+Core_MDF_PaymentUtility.tab +'First Name' + Core_MDF_PaymentUtility.tab +'Email Address' +Core_MDF_PaymentUtility.tab +'Active' + Core_MDF_PaymentUtility.tab +'User Country' + Core_MDF_PaymentUtility.tab + 'Program Name' +Core_MDF_PaymentUtility.tab +'User Accounts Access' +Core_MDF_PaymentUtility.tab + Core_MDF_PaymentUtility.newline;
            string reportHeader1 = 'ContactId' +Core_MDF_PaymentUtility.tab +'Last Name'+Core_MDF_PaymentUtility.tab +'First Name' + Core_MDF_PaymentUtility.tab +'Email Address' +Core_MDF_PaymentUtility.tab +'Active' + Core_MDF_PaymentUtility.tab +'User Country' + Core_MDF_PaymentUtility.tab + Core_MDF_PaymentUtility.newline;
            string reportHeader2 = 'Program Name' +Core_MDF_PaymentUtility.tab +'User Accounts Access' +Core_MDF_PaymentUtility.tab + Core_MDF_PaymentUtility.newline;
            string reportHeader3 = 'User Role Name'+Core_MDF_PaymentUtility.tab +'Role Assigned/Removed'+Core_MDF_PaymentUtility.tab + 'Role Assignment/Removal date'+ Core_MDF_PaymentUtility.tab  + Core_MDF_PaymentUtility.newline;
            
            //Integer count1 = 0;
            //Integer count2 = 0;
            
            /*if(listOfAUs!=Null && listOfAUs.size()>0){
                for(Core_MDF_Partner_Node_User_Mapping__c auRec : listOfAUs){
                    List<string> line1 = new List<string>();
                    line1.add(auRec.Core_MDF_User__r.ContactId);
                    line1.add(auRec.Core_MDF_User__r.LastName);
                    line1.add(auRec.Core_MDF_User__r.FirstName);
                    line1.add(auRec.Core_MDF_User__r.Email);
                    line1.add(String.valueOf(auRec.Core_MDF_User__r.IsActive));
                    line1.add(auRec.Core_MDF_User__r.Country);
                    line1.add(auRec.Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name);
                    line1.add(auRec.Core_MDF_Account__r.Name);  
                    //line1.add(auRec.Core_MDF_User__r.Contact.);  
                    //line1.add(auRec.Core_MDF_User__r.Name);  
                    //line1.add(auRec.Core_MDF_User__r.Name);
                    string toAddNewLine = Core_MDF_Payment_FileHelper.fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline;
                    reportHeader = reportHeader + toAddNewLine;    
                }
            }*/
            
           /* if(userList!=Null && userList.size()>0){
                for(User usr : userList) {
                    List<string> line1 = new List<string>();
                    line1.add(usr.ContactId);
                    line1.add(usr.LastName);
                    line1.add(usr.FirstName);
                    line1.add(usr.Email);
                    line1.add(String.valueOf(usr.IsActive));
                    line1.add(usr.Country);                        
                    /*if(listOfAU!=Null && listOfAU.size()>0) {
                        for(Integer i=0;i<listOfAU.size();i++){
                            //count1++;
                            if(listOfAUSize < 2){
                                line1.add(listOfAU[i].Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name);
                                line1.add(listOfAU[i].Core_MDF_Account__r.Name);  
                                string toAddNewLine = Core_MDF_Payment_FileHelper.fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline;
                                reportHeader = reportHeader + toAddNewLine; 
                            }
                            else{
                                if(i==0){
                                    line1.add(listOfAU[i].Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name);
                                    system.debug('sffgjk'+listOfAU[i].Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name);
                                    line1.add(listOfAU[i].Core_MDF_Account__r.Name);   
                                    system.debug('asdfffghjkl'+listOfAU[i].Core_MDF_Account__r.Name);
                                }
                                List<String> line = new List<String>();
                                line.add(' ');
                                line.add(' ');
                                line.add(' ');
                                line.add(' ');
                                line.add(' ');
                                line.add(' '); 
                                line.add(listOfAU[i].Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name);
                                line.add(listOfAU[i].Core_MDF_Account__r.Name);
                                string toAddNewLine = Core_MDF_Payment_FileHelper.fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline + Core_MDF_Payment_FileHelper.fileLineItemToString(line);
                                reportHeader = reportHeader + toAddNewLine; 
                            }                            
                        } 
                    }
                   string toAddNewLine = Core_MDF_Payment_FileHelper.fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline;
                   reportHeader = reportHeader + toAddNewLine;                                           
                }
            }*/
            
            string toAddNewTab;
            string toAddNewTab2;
            string toAddNewLine;
            string reportHeaders;
            system.debug('UserLiVDst'+userList);
            system.debug('listOfAUVDst'+listOfAU);
            system.debug('contEntitlementsVDst'+contEntitlements);
            
            if(userList!=Null && userList.size()>0){
                //for(User usr : userList){
                for(Integer i=0;i<userList.size();i++){
                    List<string> line1 = new List<string>();
                    line1.add(userList[i].ContactId);
                    line1.add(userList[i].LastName);
                    line1.add(userList[i].FirstName);
                    line1.add(userList[i].Email);
                    line1.add(String.valueOf(userList[i].IsActive));
                    line1.add(userList[i].Country);  
                    
                    /*if(i < (userList.size()-1)){
                        toAddNewTab = Core_MDF_Payment_FileHelper.fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline;
                        reportHeader = reportHeader + toAddNewTab; 
                    }                                        
                    else if(i==(userList.size()-1)){
                        toAddNewTab = Core_MDF_Payment_FileHelper.fileLineItemToString(line1);
                        reportHeader = reportHeader + toAddNewTab; 
                    }
                    system.debug('V1toAddNewTab'+reportHeader);
                    //toAddNewTab = Core_MDF_Payment_FileHelper.fileLineItemToString(line1);*/
                    
                    Integer counter = 0;
                    
                    if(listOfAU != Null && listOfAU.size() > 0) {
                        for(Integer j=0; j<listOfAU.size(); j++){                            
                            if(userList[i].Id == listOfAU[j].Core_MDF_User__c){
                                counter++;
                                if(counter == 1){
                                    line1.add(listOfAU[j].Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name);
                                    line1.add(listOfAU[j].Core_MDF_Account__r.Name);
                                }
                                else{
                                    List<string> line = new List<string>();
                                    line.add(' ');
                                    line.add(' ');
                                    line.add(' ');
                                    line.add(' ');
                                    line.add(' ');
                                    line.add(' '); 
                                    line.add(listOfAU[j].Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name);
                                    line.add(listOfAU[j].Core_MDF_Account__r.Name);
                                }                                                                
                            }
                            /*List<string> line2 = new List<string>();
                            line2.add(listOfAU[j].Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name);
                            line2.add(listOfAU[j].Core_MDF_Account__r.Name); 
                            
                            // toAddNewTab2 = Core_MDF_Payment_FileHelper.fileLineItemToString(line2) + Core_MDF_PaymentUtility.tab;
                            if(j < (listOfAU.size()-1)){
                                toAddNewTab2 = Core_MDF_Payment_FileHelper.fileLineItemToString(line2)+ Core_MDF_PaymentUtility.newline;
                                reportHeader2 = reportHeader2 + toAddNewTab2;   
                            }                                        
                            else if(j==(listOfAU.size()-1)){
                                toAddNewTab2 = Core_MDF_Payment_FileHelper.fileLineItemToString(line2);
                                reportHeader2 = reportHeader2 + toAddNewTab2; 
                            }                    
                            system.debug('VtoAddNew2Tab'+reportHeader2);   */                 
                        }                
                    }
                    
                }                
            }
            //reportHeader = reportHeader + Core_MDF_PaymentUtility.tab; 
            system.debug('V2toAddNewTab'+reportHeader);
            
            //Integer count = listOfAU.size();
            /*if(listOfAU != Null && listOfAU.size() > 0) {
                for(Integer i=0; i<listOfAU.size(); i++){
                    List<string> line1 = new List<string>();
                    line1.add(listOfAU[i].Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name);
                    line1.add(listOfAU[i].Core_MDF_Account__r.Name); 
                    
                   // toAddNewTab2 = Core_MDF_Payment_FileHelper.fileLineItemToString(line1) + Core_MDF_PaymentUtility.tab;
                    if(i < (listOfAU.size()-1)){
                        toAddNewTab2 = Core_MDF_Payment_FileHelper.fileLineItemToString(line1)+ Core_MDF_PaymentUtility.newline;
                        reportHeader2 = reportHeader2 + toAddNewTab2;   
                    }                                        
                    else if(i==(listOfAU.size()-1)){
                        toAddNewTab2 = Core_MDF_Payment_FileHelper.fileLineItemToString(line1);
                        reportHeader2 = reportHeader2 + toAddNewTab2; 
                    }                    
                    system.debug('VtoAddNew2Tab'+reportHeader2);                    
                }                
            }*/
            //reportHeader2 = reportHeader2 + Core_MDF_PaymentUtility.tab; 
            system.debug('VtoAdd3NeewTab2'+reportHeader2);
            
            if(contEntitlements!=Null && contEntitlements.size()>0){
                for(Integer i=0; i<contEntitlements.size(); i++){
                    List<string> line1 = new List<string>();
                    line1.add(contEntitlements[i].Core_Entitlement_Id__r.Name);
                    line1.add(String.valueOf(contEntitlements[i].Core_Status_Change_Date_Time__c)); 
                    line1.add(String.valueOf(contEntitlements[i].Core_Selected__c));
                    toAddNewLine = Core_MDF_Payment_FileHelper.fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline;
                    reportHeader3 = reportHeader3 + toAddNewLine;
                    
                   /* if(i==(contEntitlements.size()-2)){
                        toAddNewLine = Core_MDF_Payment_FileHelper.fileLineItemToString(line1) + Core_MDF_PaymentUtility.tab;
                        reportHeader2 = reportHeader2 + toAddNewLine; 
                    }*/                    
                    system.debug('VtoAddNssewLine'+reportHeader3);
                }                
            }
            //reportHeader3 = reportHeader3 + Core_MDF_PaymentUtility.tab;
            system.debug('VtoAddNwerewLine'+reportHeader3);
            reportHeaders = reportHeader + Core_MDF_PaymentUtility.tab+ reportHeader2 + Core_MDF_PaymentUtility.tab + reportHeader3; 
            system.debug('reportHeaderCFs'+reportHeaders);
            
            
            //String fileType = 'xls';
            //File Types
            string fileType = 'XLS';
            //Create content file
            Id contentDocId = createContentFile(fileType, reportHeaders,internalAuditRecId);
            //Id contentDocId2 = createContentFile(fileType, reportHeader2,internalAuditRecId);
            //Id contentDocId3 = createContentFile(fileType, reportHeader3,internalAuditRecId);
            
            //String url = 'https://crmdevccp-intelcloudcrm.cs17.force.com/Partnercenter/sfc/servlet.shepherd/version/download/'+contentDocId;            
            return true;
        }
        else{
            //String hasAccess = 'false';
            return false;
        }       
    }
    
    /**********************************/
    /**********************************/
    
    public static Id createContentFile(String fileType, string content,Id internalAuditRecId){
        
        string pRunBinary;
        blob payRunBlob = Blob.valueOf(content);
        //convert BLOB file into base64 format
        pRunBinary = EncodingUtil.base64Encode(payRunBlob);
        system.debug('pRunBVDinary'+pRunBinary);
        
        ContentVersion contentDocId = createContentVersion(fileType, pRunBinary);
        system.debug('contentDocIdVD*'+contentDocId);
        
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = internalAuditRecId,
            ContentDocumentId = contentDocId.ContentDocumentId,
            shareType = 'V',
            Visibility = 'AllUsers'
        );        
        database.insert(contentDocumentLink); 
        
        Map<Id,ContentDocument> conDocMap = new Map<Id,ContentDocument>([SELECT Id,OwnerId FROM ContentDocument 
                                                                            WHERE Id =: contentDocId.ContentDocumentId]);
        if(conDocMap !=null & conDocMap.size()>0){
            for(ContentDocument conDoc : conDocMap.values())
            {
                conDoc.OwnerId = '005g0000007ACZg'; 
            } 
            Database.update(conDocMap.values());
        }
        return contentDocId.Id;
    }
    
     /**********************************/
    /**********************************/
    
    public static ContentVersion createContentVersion(String fileType, String binaryStringInput){

        String fileExtn = fileType.toLowerCase();
        ContentVersion conVersion = new ContentVersion();
        conVersion.ContentLocation = 'S';
        conVersion.PathOnClient = generateFileName()+'.'+fileExtn;
        conVersion.Title = generateFileName();
        conVersion.ReasonForChange = Label.Core_MDF_ContentVersion_ReasonForChange;
        conVersion.VersionData = EncodingUtil.base64Decode(binaryStringInput);
        database.insert(conVersion);       
        
        ContentVersion contVer = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: conVersion.Id];
        system.debug('ContVersionObjField1'+contVer);
        system.debug('ContVersionObjField2'+conVersion);
        system.debug('ContVersionObjFieldContentDocumentId'+contVer.ContentDocumentId);
        return contVer;
    }
    
         /**********************************/
    /**********************************/
    
    public static string generateFileName(){
        string fileName = userName+'_'+'UserReport';
        return fileName;
    }
}