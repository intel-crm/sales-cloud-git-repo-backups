/**
 * @description       : 
 * @author            : Farooq Ahmed
 * @group             : 
 * @last modified on  : 29-07-2021
 * @last modified by  : Farooq Ahmed
 * Modifications Log 
 * Description: 
 * Ver   Date         Author        Modification
 * 1.0   29-07-2021   Farooq Ahmed   Initial Version
**/
public without sharing class Core_IPS_MyIntelDataExport implements Database.Batchable<sObject>,Database.AllowsCallouts{
    public final String query;
    
    public static List<case> caseList = new List<case>();
     public Core_IPS_MyIntelDataExport(string queryString){
        this.query = queryString;
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        List<String> csvRowValues = new List<String>();
        Set<String> contactIds = new Set<String>();
        List<Contact> contactList = new List<Contact>();
        List<Core_IPS_Project_Member__c> projectMemberList = new List<Core_IPS_Project_Member__c>();
        Map<Id,List<Map<String,String>>> projectMemberMap = new Map<Id,List<Map<String,String>>>();
        List<Core_IPS_Case_Interested_Party__c> intrestedPartiesList = new List<Core_IPS_Case_Interested_Party__c>();
        Map<Id,List<Map<String,String>>> intrestedPartiesMap = new Map<Id,List<Map<String,String>>>();
        
        Map<String, List<Map<String,String>>> contactAccountMap = new Map<String, List<Map<String,String>>>();
        caseList = (List<case>)scope;
        
        contactList = [SELECT Id,AccountId,Email,Core_Enterprise_Id__c FROM Contact where AccountId IN (select AccountId from case where Id IN:caseList and Core_IPS_Project_Case__c = null) and Core_IPS_Active__c = true]; 
        
        for(Contact con: contactList){
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
                if(projectMemberMap.get(projectMember.Core_IPS_Project__c) == null){
                    String enterpriseId = (projectMember.Core_IPS_Contact__r.Core_Enterprise_Id__c != null) ? projectMember.Core_IPS_Contact__r.Core_Enterprise_Id__c : '';
                    projectMemberMap.put(projectMember.Core_IPS_Project__c, new List<Map<String,String>>{new Map<String,String>{'emailId' => projectMember.Core_IPS_Contact__r.Email, 'enterpriseId' => enterpriseId}});
                } else {
                    String enterpriseId = (projectMember.Core_IPS_Contact__r.Core_Enterprise_Id__c != null) ? projectMember.Core_IPS_Contact__r.Core_Enterprise_Id__c : '';
                    projectMemberMap.get(projectMember.Core_IPS_Project__c).add(new Map<String,String>{'emailId' => projectMember.Core_IPS_Contact__r.Email, 'enterpriseId' => enterpriseId});
                }
        }
        
        intrestedPartiesList = [Select id,Name,Case__c,Case__r.AccountId,User__c,User__r.ProfileId,Contact__c,Contact__r.Email,Contact__r.Core_Enterprise_Id__c,Agent_Name__c,Active__c,Type__c from 
                                Core_IPS_Case_Interested_Party__c where Case__c IN: caseList];
        
        for(Core_IPS_Case_Interested_Party__c intrestedParties : intrestedPartiesList){
            if(intrestedParties.Contact__r.Email != null){
                if(intrestedPartiesMap.get(intrestedParties.Case__c) == null){
                    String enterpriseId = (intrestedParties.Contact__r.Core_Enterprise_Id__c != null) ? intrestedParties.Contact__r.Core_Enterprise_Id__c : '';
                    intrestedPartiesMap.put(intrestedParties.Case__c, new List<Map<String,String>>{new Map<String,String>{'emailId' => intrestedParties.Contact__r.Email, 'enterpriseId' => enterpriseId}});
                } else{
                    String enterpriseId = (intrestedParties.Contact__r.Core_Enterprise_Id__c != null) ? intrestedParties.Contact__r.Core_Enterprise_Id__c : '';
                    intrestedPartiesMap.get(intrestedParties.Case__c).add(new Map<String,String>{'emailId' => intrestedParties.Contact__r.Email, 'enterpriseId' => ''});
                }
            }
                
        }        
        String csvFile = '';
        String csvColumnHeader = 'caseNumber,caseId,contact1,contact2,contact3,contact4,contact5\n';
        csvFile = csvColumnHeader;
        String allContacts,caseNumber,caseId,subString1,subString2,subString3,subString4,subString5;
        String rowStr;
        List<Map<String,String>> projectProjectMemberMap = new List<Map<String,String>>();
        List<Map<String,String>> casecontactMap = new List<Map<String,String>>();
        List<Map<String,String>> caseIntrestedPartiesMap = new List<Map<String,String>>();
        List<Map<String,String>> caseIntrestedPartiesMapUnique = new List<Map<String,String>>();
        for(case cs: caseList){
            projectProjectMemberMap = new List<Map<String,String>>();
            casecontactMap = new List<Map<String,String>>();
            caseIntrestedPartiesMap = new List<Map<String,String>>();
            caseIntrestedPartiesMapUnique = new List<Map<String,String>>();
            if(!contactAccountMap.isEmpty()){
                if(cs.Core_IPS_Project_Case__c == null)
                    casecontactMap = contactAccountMap.get(cs?.AccountId);
            }
            if(projectMemberMap.get(cs.Core_IPS_Project_Case__c) != null){
                projectProjectMemberMap = projectMemberMap.get(cs.Core_IPS_Project_Case__c);
            }
            if(intrestedPartiesMap.get(cs.Id) != null){
                caseIntrestedPartiesMap = intrestedPartiesMap.get((String)cs.Id);
                if(projectProjectMemberMap.size() > 0){
                    caseIntrestedPartiesMap.addAll(projectProjectMemberMap);
                }
                else if(casecontactMap.size() > 0){
                    caseIntrestedPartiesMap.addAll(casecontactMap);
                }
                
            }
            set<String> key = new set<String>();
            for(Map<String,String> caseIntrestParitesMap : caseIntrestedPartiesMap){
                if(!key.contains(caseIntrestParitesMap.get('emailId'))){
                   caseIntrestedPartiesMapUnique.add(caseIntrestParitesMap); 
                }
                key.add(caseIntrestParitesMap.get('emailId'));
                
            }
            if(!caseIntrestedPartiesMapUnique.isEmpty()){
                    allContacts = JSON.serialize(caseIntrestedPartiesMapUnique);
                }else if(!projectProjectMemberMap.isEmpty()){
                    allContacts = JSON.serialize(projectProjectMemberMap);
                }else if(casecontactMap != null){
                    allContacts = JSON.serialize(casecontactMap);
                }else{
                    allContacts = '';
                }
            caseNumber = cs?.CaseNumber; 
             caseId  = cs?.Id;
             subString5 = (allContacts.length() > 163790) ? allContacts.subString(131032,163790) : (allContacts.length() >= 131032 &&  allContacts.length() < 163790) ? allContacts.substring(131032) : '';
             subString4 = (allContacts.length() > 131032) ? allContacts.subString(98274,131032) : (allContacts.length() >= 98274 &&  allContacts.length() < 131032) ? allContacts.substring(98274) : '';
             subString3 = (allContacts.length() > 98274) ? allContacts.subString(65516,98274) : (allContacts.length() >= 65516 && allContacts.length() < 98274)  ? allContacts.substring(65516) : '';
             subString2 = (allContacts.length() > 65516) ? allContacts.subString(32758,65516) : (allContacts.length() >= 32758 && allContacts.length() < 65516)  ? allContacts.substring(32758) : '';
             subString1 = allContacts.length() > 32758 ? allContacts.substring(0,32758) : allContacts.length() < 32758 ? allContacts.substring(0) : '';
          
            rowStr =  caseNumber+','+caseId+','+subString1.replaceAll(',',';')+','+subString2.replaceAll(',',';')+','+subString3.replaceAll(',',';')+','+subString4.replaceAll(',',';')+','+subString5.replaceAll(',',';');
            csvRowValues.add(rowStr);
   
        }
        csvFile += String.join(csvRowValues,'\n');
        
         Folder myIntelFolder = [SELECT Id, Name FROM Folder WHERE Name = 'Max Linear'];
        Document doc = new Document(Name = 'caseData'+Integer.valueof((Math.random() * 100000)), Body = Blob.valueOf(csvFile), FolderId = myIntelFolder.Id, Type = 'csv', ContentType='application/vnd.ms-excel');
        insert doc;
        
    }
    public void finish(Database.BatchableContext bc){

    }
}