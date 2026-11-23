public class core_IPS_InterestedParties {
   // Method to insert a record in InterestedParties using Intel Support Team
public static void interestedParties_IntelSupportTeam(List<Core_IPS_Intel_Support_Team__c> newList,Map<Id,Core_IPS_Intel_Support_Team__c> oldMap) {
  
     Map<id,id> cpMap=new Map<id,id>();
     Map<id,case> cistMap=new Map<id,case>();
     List<Core_IPS_Case_Interested_Party__c> cipListToBeInserted = new List<Core_IPS_Case_Interested_Party__c>();    
     if(newList.size()>0){ 
         
      for(Core_IPS_Intel_Support_Team__c cp:newList){       
       cpMap.put(cp.id,cp.Core_IPS_Project__c);    
      }
     }
   
    if(cpMap.size()>0){
       List<case> cistList=[select id,CaseNumber,Core_IPS_Project_Case__c,Core_IPS_Project_Case__r.name,Core_IPS_Project_Case__r.Core_IPS_Enable_ISTasInterested_Parties__c,Core_IPS_Project_Case__r.Core_IPS_EnableMemberasInterestedParties__c from case where Core_IPS_Project_Case__c In:cpMap.Values() and status!='closed'];      
        if(cistList.size()>0){          
          for(case cisList:cistList){              
           cistMap.put(cisList.id,cisList);
          }  
        } 
    } 
  
   if(newList.size()>0){ 
      for(Core_IPS_Intel_Support_Team__c cp:newList){
        for(ID c:cistMap.keySet()){    
          System.debug('before comparision'+cistMap.get(c).Core_IPS_Project_Case__r.Core_IPS_Enable_ISTasInterested_Parties__c);  
           if(cistMap.get(c).Core_IPS_Project_Case__r.Core_IPS_Enable_ISTasInterested_Parties__c==true && cistMap.get(c).Core_IPS_Project_Case__c==cp.Core_IPS_Project__c){
            Core_IPS_Case_Interested_Party__c cip=new Core_IPS_Case_Interested_Party__c();
            cip.User__c=cp.Core_IPS_User__c;
            cip.Case__c=cistMap.get(c).id;
            cipListToBeInserted.add(cip); 
               

          }   
        } 
      }
   }
  if(cipListToBeInserted.size() > 0){
       insert cipListToBeInserted;
  }
    
}
// Method to insert a record in InterestedParties using SupportProjectMembers
 public static void interestedParties_SupportProjectMembers(List<Core_IPS_Project_Member__c> newList,Map<Id,Core_IPS_Project_Member__c> oldMap) {  
     Map<id,id> cipmMap=new Map<id,id>();
     Map<id,case> cistMap=new Map<id,case>();
     List<Core_IPS_Case_Interested_Party__c> cipListToBeInserted = new List<Core_IPS_Case_Interested_Party__c>();     
     if(newList.size()>0){    
      for(Core_IPS_Project_Member__c cp:newList){         
       cipmMap.put(cp.id,cp.Core_IPS_Project__c);    
      }
     }
    
    if(cipmMap.size()>0){       
       List<case> cistList=[select id,CaseNumber,Core_IPS_Project_Case__c,Core_IPS_Project_Case__r.name,Core_IPS_Project_Case__r.Core_IPS_Enable_ISTasInterested_Parties__c,Core_IPS_Project_Case__r.Core_IPS_EnableMemberasInterestedParties__c from case where Core_IPS_Project_Case__c In:cipmMap.Values() and status!='closed'];        
        if(cistList.size()>0){           
          for(case cisList:cistList){               
           cistMap.put(cisList.id,cisList);
          }  
        } 
    } 
   
   if(newList.size()>0){       
      for(Core_IPS_Project_Member__c cp:newList){
        for(ID c:cistMap.keySet()){    
          System.debug('before comparision'+cistMap.get(c).Core_IPS_Project_Case__r.Core_IPS_EnableMemberasInterestedParties__c);  
           if(cistMap.get(c).Core_IPS_Project_Case__r.Core_IPS_EnableMemberasInterestedParties__c==true && cistMap.get(c).Core_IPS_Project_Case__c==cp.Core_IPS_Project__c){
            Core_IPS_Case_Interested_Party__c cip=new Core_IPS_Case_Interested_Party__c();
            cip.Contact__c=cp.Core_IPS_Contact__c;
            cip.Case__c=cistMap.get(c).id;
            cipListToBeInserted.add(cip); 

          }   
        } 
      }
   }   
    if(cipListToBeInserted.size() > 0){
        insert cipListToBeInserted;
    }
 
 }   
 //Method to delete interested parties record based on checkbox uncheck 

 public static void deleteRecord_InterestedParties(List<Core_IPS_Project__c> newList,Map<Id,Core_IPS_Project__c> oldMap){
  Map<id,Core_IPS_Project__c> cipMap=new Map<id,Core_IPS_Project__c>();
  Map<id,Core_IPS_Project__c> cipMapForIST=new Map<id,Core_IPS_Project__c>(); 
  if(newList.size()>0){   
    for(Core_IPS_Project__c cip:newList){   
      if(oldMap.get(cip.Id).Core_IPS_EnableMemberasInterestedParties__c!=cip.Core_IPS_EnableMemberasInterestedParties__c && cip.Core_IPS_EnableMemberasInterestedParties__c==false){ 
        cipMap.put(cip.id,cip);
      }
      if(oldMap.get(cip.Id).Core_IPS_Enable_ISTasInterested_Parties__c!=cip.Core_IPS_Enable_ISTasInterested_Parties__c && cip.Core_IPS_Enable_ISTasInterested_Parties__c==false){   
         cipMapForIST.put(cip.id,cip); 
      }
    }
    if(cipMap.size()>0){       
      //core_IPS_InterestedParties.deleteRecord_Enable_InterestedParties(cipMap);
    }
    if(cipMapForIST.size()>0){
      //core_IPS_InterestedParties.deleteRecord_Enable_InterestedParties(cipMapForIST);
    }
  
  }
  

 } 
 /*public static void deleteRecord_Enable_InterestedParties(Map<id,Core_IPS_Project__c> eipMap){   
   integer enableMemberCount=0;
   integer ips_enableSupportTeamCount=0;
   if(eipMap.size()>0){    
    Map<id,case> caseMap=new Map<id,case>([select id,Core_IPS_Project_Case__c,Core_IPS_Project_Case__r.Core_IPS_Enable_ISTasInterested_Parties__c,Core_IPS_Project_Case__r.Core_IPS_EnableMemberasInterestedParties__c from case where Core_IPS_Project_Case__c iN:eipMap.keySet()]);     
    List<Core_IPS_Case_Interested_Party__c> interestedPartiesList=new List<Core_IPS_Case_Interested_Party__c>();
    List<Core_IPS_Case_Interested_Party__c> IPSinterestedPartiesList=new List<Core_IPS_Case_Interested_Party__c>();
    if(caseMap.size()>0) {      
        for(ID id:caseMap.keySet()){
            if(caseMap.get(id).Core_IPS_Project_Case__r.Core_IPS_EnableMemberasInterestedParties__c==false){
                enableMemberCount++;
            }
            if(caseMap.get(id).Core_IPS_Project_Case__r.Core_IPS_Enable_ISTasInterested_Parties__c==false){
                ips_enableSupportTeamCount++;
            }
        }  
        if(enableMemberCount>0){
          interestedPartiesList=[select id from Core_IPS_Case_Interested_Party__c where Case__c IN :caseMap.keySet() and user__c=null]; 
          if(interestedPartiesList.size()>0){            
            delete interestedPartiesList;
          }
        }
        if(ips_enableSupportTeamCount>0){
         IPSinterestedPartiesList=[select id from Core_IPS_Case_Interested_Party__c where Case__c IN :caseMap.keySet() and contact__c=null]; 
          if(IPSinterestedPartiesList.size()>0){           
            delete IPSinterestedPartiesList;
          } 
        
        }
       
        
    }
   
   }
  
 }

 }*/
 
 //Add interested Party using case
 
    public static void case_Edit_projectDetails(List<case> newList,Map<id,case> oldMap)  {  
    Map<id,id> editCaseDetailsMap=new Map<id,id>();	
    Map<id,case> CaseDetailsMap=new Map<id,case>();
    System.debug('started');    
	if(newList.size()>0){
	 for(case caseProjectChange:newList){
         System.debug('in for 1');
	  if(oldMap.get(caseProjectChange.id).Core_IPS_Project_Case__c!=caseProjectChange.Core_IPS_Project_Case__c){
          System.debug('after comparision');
	     editCaseDetailsMap.put(caseProjectChange.id,caseProjectChange.Core_IPS_Project_Case__c);
         caseDetailsMap.put(caseProjectChange.id,caseProjectChange); 
	  }	  	 
	 }
      System.debug('before delete');  
	 if(editCaseDetailsMap.size()>0){
        System.debug('if delete');       
	    delete [SELECT Id FROM Core_IPS_Case_Interested_Party__c WHERE 
            Case__c IN :editCaseDetailsMap.keySet()];
	  }
	  List<Core_IPS_Project_Member__c> premierSupportMembers_List=[select id,Core_IPS_Contact__c,Core_IPS_Project__c,Core_IPS_Project__r.name,Core_IPS_Project__r.Core_IPS_EnableMemberasInterestedParties__c from Core_IPS_Project_Member__c where Core_IPS_Project__c IN:editCaseDetailsMap.Values()];	  
	  List<Core_IPS_Intel_Support_Team__c> intelTeamMembers_List=[select id,Core_IPS_User__c,Core_IPS_Project__c,Core_IPS_Project__r.name,Core_IPS_Project__r.Core_IPS_Enable_ISTasInterested_Parties__c from Core_IPS_Intel_Support_Team__c where Core_IPS_Project__c IN:editCaseDetailsMap.Values()];
	  System.debug('after list');
	  if(premierSupportMembers_List.size()>0 && caseDetailsMap.size()>0){
          System.debug('calling method');
	     core_IPS_InterestedParties.create_IntrestedParties_ProjectMembers(premierSupportMembers_List,caseDetailsMap);
	  }
	  if(intelTeamMembers_List.size()>0 && caseDetailsMap.size()>0){
	    core_IPS_InterestedParties.create_IntrestedParties_IntelSupportTeam(intelTeamMembers_List,caseDetailsMap);
	  }
	}
  
  }
  
  public static void create_IntrestedParties_ProjectMembers(List<Core_IPS_Project_Member__c> premierSupportMembers_List,Map<id,case> editCaseDetailsMap){
    List<Core_IPS_Case_Interested_Party__c> InterestedParty_List=new List<Core_IPS_Case_Interested_Party__c>();
    System.debug('In method');  
	for(ID cs:editCaseDetailsMap.keySet()){ 
     for(Core_IPS_Project_Member__c projectMembers:premierSupportMembers_List){
         System.debug('in for 2');
	   if(projectMembers.Core_IPS_Project__r.Core_IPS_EnableMemberasInterestedParties__c==true && editCaseDetailsMap.get(cs).Core_IPS_Project_Case__c==projectMembers.Core_IPS_Project__c){	   
           System.debug('before insert');
	     Core_IPS_Case_Interested_Party__c case_InterestedParty=new Core_IPS_Case_Interested_Party__c();
            case_InterestedParty.Contact__c=projectMembers.Core_IPS_Contact__c;
            case_InterestedParty.Case__c=editCaseDetailsMap.get(cs).id;
	     InterestedParty_List.add(case_InterestedParty); 
	   }	   	 
	 }
	} 
    System.debug('check size');  
    if(InterestedParty_List.size()>0){
        System.debug('pass');  
	   insert InterestedParty_List;
	}
  }
  
  public static void create_IntrestedParties_IntelSupportTeam(List<Core_IPS_Intel_Support_Team__c> intelTeamMembers_List,Map<id,case> editCaseDetailsMap){
    List<Core_IPS_Case_Interested_Party__c> InterestedParty_List=new List<Core_IPS_Case_Interested_Party__c>();
	for(ID cs:editCaseDetailsMap.keySet()){ 
     for(Core_IPS_Intel_Support_Team__c intelMembers:intelTeamMembers_List){
	   if(intelMembers.Core_IPS_Project__r.Core_IPS_Enable_ISTasInterested_Parties__c==true && editCaseDetailsMap.get(cs).Core_IPS_Project_Case__c==intelMembers.Core_IPS_Project__c){	   
	     Core_IPS_Case_Interested_Party__c case_InterestedParty=new Core_IPS_Case_Interested_Party__c();
            case_InterestedParty.User__c=intelMembers.Core_IPS_User__c;
            case_InterestedParty.Case__c=editCaseDetailsMap.get(cs).id;
	     InterestedParty_List.add(case_InterestedParty); 
	   }	   	 
	 }
	} 
    if(InterestedParty_List.size()>0){
	   insert InterestedParty_List;
	}
  }
    
    
}