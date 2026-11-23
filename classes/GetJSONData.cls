public class GetJSONData {
    public static List<case> caseList = new List<case>();
    public static void getJSON(){
        List<String> csvRowValues = new List<String>();
        List<String> contactIds = new List<String>();
        List<Contact> contactList = new List<Contact>();
        List<Core_IPS_Project_Member__c> projectMemberList = new List<Core_IPS_Project_Member__c>();
        Map<Id,List<Map<String,String>>> projectMemberMap = new Map<Id,List<Map<String,String>>>();
        List<Core_IPS_Case_Interested_Party__c> intrestedPartiesList = new List<Core_IPS_Case_Interested_Party__c>();
        Map<Id,List<Map<String,String>>> intrestedPartiesMap = new Map<Id,List<Map<String,String>>>();
        
        Map<String, List<Map<String,String>>> contactAccountMap = new Map<String, List<Map<String,String>>>();
        caseList = [select id,casenumber,subject,Product.Name,Core_ConEmail__c,Core_IPS_Project_Case__c,Core_IPS_Product_name__c, Status,CreatedDate, LastModifiedDate, AccountId, ContactId, Core_CaseType__c, ContactEmail,
                               Contact.Core_Enterprise_Id__c,Core_IPS_Customer_Visible__c  from case where CreatedDate > 2020-06-07T00:00:00Z and CreatedDate < 2021-06-07T00:00:00Z];
        
        contactList = [SELECT Id,AccountId,Email,Core_Enterprise_Id__c FROM Contact where AccountId IN (select AccountId from case where Id IN:caseList) and Core_IPS_Active__c = true]; 
        
        for(Contact con: contactList){
            contactIds.add(con.Email);
            if(contactAccountMap.get(con.AccountId) == null){
                String enterpriseId = (con.Core_Enterprise_Id__c != null) ? con.Core_Enterprise_Id__c : '';
                contactAccountMap.put(con.AccountId, new List<Map<String,String>>{new Map<String,String>{'emailId' => con?.Email, 'enterpriseId' => enterpriseId}});
            }else{
                String enterpriseId = (con.Core_Enterprise_Id__c != null) ? con.Core_Enterprise_Id__c : '';
                contactAccountMap.get(con.AccountId).add(new Map<String,String>{'emailId' => con?.Email, 'enterpriseId' => enterpriseId});
            }
        }
        
        projectMemberList = [SELECT Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE 
                             Core_IPS_Project__c IN (select Core_IPS_Project_Case__c from case where id IN: caseList) and Core_Status__c ='Active'];
        
        for(Core_IPS_Project_Member__c projectMember : projectMemberList){
            
            if(!contactIds.contains(projectMember.Core_IPS_Contact__r.Email)){
                if(projectMemberMap.get(projectMember.Core_IPS_Project__c) == null){
                    String enterpriseId = (projectMember.Core_IPS_Contact__r.Core_Enterprise_Id__c != null) ? projectMember.Core_IPS_Contact__r.Core_Enterprise_Id__c : '';
                    projectMemberMap.put(projectMember.Core_IPS_Project__c, new List<Map<String,String>>{new Map<String,String>{'emailId' => projectMember.Core_IPS_Contact__r.Email, 'enterpriseId' => enterpriseId}});
                } else{
                    String enterpriseId = (projectMember.Core_IPS_Contact__r.Core_Enterprise_Id__c != null) ? projectMember.Core_IPS_Contact__r.Core_Enterprise_Id__c : '';
                    projectMemberMap.get(projectMember.Core_IPS_Project__c).add(new Map<String,String>{'emailId' => projectMember.Core_IPS_Contact__r.Email, 'enterpriseId' => enterpriseId});
                }
            }
            contactIds.add(projectMember.Core_IPS_Contact__r.Email);
        }
        
        
        intrestedPartiesList = [Select id,Name,Case__c,Case__r.AccountId,User__c,User__r.ProfileId,Contact__c,Contact__r.Email,Contact__r.Core_Enterprise_Id__c,Agent_Name__c,Active__c,Type__c from 
                                Core_IPS_Case_Interested_Party__c where Case__c IN: caseList];
        
        for(Core_IPS_Case_Interested_Party__c intrestedParties : intrestedPartiesList){
            
            if(!contactIds.contains(intrestedParties.Contact__r.Email)){
                if(intrestedPartiesMap.get(intrestedParties.Case__c) == null){
                    
                    String enterpriseId = (intrestedParties.Contact__r.Core_Enterprise_Id__c != null) ? intrestedParties.Contact__r.Core_Enterprise_Id__c : '';
                    intrestedPartiesMap.put(intrestedParties.Case__c, new List<Map<String,String>>{new Map<String,String>{'emailId' => intrestedParties.Contact__r.Email, 'enterpriseId' => enterpriseId}});
                } else{
                    
                    String enterpriseId = (intrestedParties.Contact__r.Core_Enterprise_Id__c != null) ? intrestedParties.Contact__r.Core_Enterprise_Id__c : '';
                    intrestedPartiesMap.get(intrestedParties.Case__c).add(new Map<String,String>{'emailId' => intrestedParties.Contact__r.Email, 'enterpriseId' => ''});
                }
            }
        }
        List<Map<String,String>> projectProjectMemberMap = new List<Map<String,String>>();
        List<Map<String,String>> casecontactMap = new List<Map<String,String>>();
        List<Map<String,String>> caseIntrestedPartiesMap = new List<Map<String,String>>();
        String csvFile = '';
        System.debug('caseListsize'+caseList.size());
        String csvColumnHeader = 'operation, subject, caseProductName, caseStatus, createdDate, lastModifiedDate, caseURL, caseNumber, accountId, contactId, org, contactEmail, caseType, enterpriseId, isCustomerVisible, allContacts\n';
        csvFile = csvColumnHeader;
        for(case cs: caseList){
            if(!contactAccountMap.isEmpty()){
                casecontactMap = contactAccountMap.get(cs?.AccountId);
            }
            if(projectMemberMap.get(cs.Core_IPS_Project_Case__c) != null){
                projectProjectMemberMap = projectMemberMap.get(cs.Core_IPS_Project_Case__c);
                if(casecontactMap!=null){
                    casecontactMap.addAll(projectProjectMemberMap);
                }
                
            }
            
            if(intrestedPartiesMap.get(cs.Id) != null){
                caseIntrestedPartiesMap = intrestedPartiesMap.get((String)cs.Id);
                if(caseIntrestedPartiesMap!=null){
                    caseIntrestedPartiesMap.addAll(projectProjectMemberMap);
                }
                if(casecontactMap!=null){
                    casecontactMap.addAll(caseIntrestedPartiesMap);
                }
                    
            }
            
            
            String operation = 'Create';
            String subject = String.isNotBlank(cs?.Subject) ? cs.Subject :'';
            String caseProductName = cs.Product.Name;
            String caseStatus = String.isNotBlank(cs?.Status) ? cs?.Status : '';
            String createdDate = cs.CreatedDate.format('M/d/yyyy h:mm:ss a z');
            String lastModifiedDate = cs.LastModifiedDate.format('M/d/yyyy h:mm:ss a z');
            String caseURL = Label.Core_MyIntel_Case_URL+cs.Id;
            String caseNumber = cs?.CaseNumber;
            String accountId = cs.accountId;
            String contactId = cs?.ContactId;
            String org = 'IPS';
            String contactEmail = cs?.Core_ConEmail__c;
            String caseType = String.isNotBlank(cs?.Core_CaseType__c) ? cs?.Core_CaseType__c : '-';
            String enterpriseId = String.isNotBlank(cs?.Contact?.Core_Enterprise_Id__c) ? cs?.Contact?.Core_Enterprise_Id__c : '';
            Boolean isCustomerVisible = cs?.Core_IPS_Customer_Visible__c;
            String allContacts = JSON.serialize(casecontactMap).replaceAll(',',';');
           
            String rowStr = operation + ',' + subject + ',' + caseProductName + ',' + caseStatus + ','+ createdDate + ',' + lastModifiedDate + ',' + caseURL + ','+ caseNumber+','+accountId+','+contactId+','+org+','+contactEmail+','+caseType+','+enterpriseId+','+isCustomerVisible+','+allContacts;
            csvRowValues.add(rowStr);
            csvFile = String.join(csvRowValues,'\n');
           
        }
        Folder myIntelFolder = [SELECT Id, Name FROM Folder WHERE Name = 'Shared Documents'];
        Document doc = new Document(Name = 'MyIntel_3_0_1_Year_Case_Data', Body = Blob.valueOf(csvFile), FolderId = myIntelFolder.Id, Type = 'csv', ContentType='application/vnd.ms-excel');
        insert doc;
        
    }
}