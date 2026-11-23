public class Core_MDF_RedirectToAuraComp {
    public List<PartnerFundClaim> pfcList;
	//public String claimIds;
	 /**This is the list which will be passed to Visualforce Page and in turn passed to Flow from Visualforce**/
    public static List <PartnerFundClaim> selectedClaims {
        get;
        set;
    }
    public static Set <Id> setOfClaims {
        get;
        set;
    }
    
        //= new Set<Id>();
    //public string[] setOfClaims{get;set;} 
     // Constructor
      public Core_MDF_RedirectToAuraComp(ApexPages.StandardSetController cntlr){
           pfcList = cntlr.getSelected(); //get selected records from claim list view
          //setOfClaims = new String[]{};
          setOfClaims = new Set<Id>();
          // claimIds = '';  
           for(PartnerFundClaim pfc : pfcList){
               setOfClaims.add(pfc.id);
               //claimIds += pfc.Id + ','; //build list of ids string concatenated with comma                         
            }
          
          System.debug('Set of Claims Inside Con' +setOfClaims);
           /**Querying on the Selected records and fetching fields which are required in Flow **/
           selectedClaims = [select Id,title,Core_MDF_Claim_Ref_Number__c,Core_MDF_AccountCompany__c,Core_MDF_Program__c,Core_MDF_Bank_Doc_Hold_Ind__c from PartnerFundClaim where id in: setOfClaims];
  			System.debug('Inside Constructor' +selectedClaims);
           //claimIds = claimIds.removeEnd(','); 
      }
    @AuraEnabled(cacheable=true)
    public static List<PartnerFundClaim> getClaims(String ids){
         /**Querying on the Selected records and fetching fields which are required in Flow **/
          //List<Id> selectedClaimIds = new List<Id>((List<Id>)ids);
         List<PartnerFundClaim> selectedClaims1 = new List<PartnerFundClaim>();
        System.debug('setOfClaims from constructot' +ids);
        //String selClaims = covertKeySet(ids);
        //List<Id> selectedClaimIds = (List<Id>)JSON.deserialize(JSON.serialize(ids), List<Id>.class); 
        /*for(String s : ids){
            Id claimId = Id.valueOf(s);
            selectedClaimIds.add(claimId);
        }*/
        //System.debug('Inside Aura method' +selectedClaimIds);
		String pfc =ids.removeStart('[');
        String pfc1= pfc.removeEnd(']');
        String pfc2 = pfc1.deleteWhitespace();
        List<String> claimIds = pfc2.split(',');
        System.debug('Claim ids after assinging' +claimIds);
        //Set<String> setClaims = new Set<String>(claimIds);
        //System.debug('Set of claims' +setClaims);
         List<PartnerFundClaim> pfcFinalList = [select title,Core_MDF_Claim_Ref_Number__c,Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_AccountCompany__c,Core_MDF_Program__c 
                                             from PartnerFundClaim where Id IN : claimIds];
               //selectedClaims1.add(pfcFinalList);}
     	System.debug('Selected Claims From VF' +pfcFinalList);
        return pfcFinalList;
    }	
     
   /* public static String covertKeySet(List<String> values){
       String name='';
        for(String s : values){
            name +='\''+s+'\',';
        } 
        name=name.lastIndexOf(',')	> 0 ? '(' +name.substring(0,name.lastIndexOf(',')) +')' : name;
      // System.debug('final Value' + name); 
        return name;
    }
   /* public PageReference redirectToLC(){
        String returnUrl = '/lightning/cmp/c__ProcessListView?c__listofclaims='+claimIds;
        PageReference pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
        return pgReturnPage;
    }*/
    public PageReference releaseHold(){
        List<PartnerFundClaim> updateClaims = new List<PartnerFundClaim>();
       // PageReference pg = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        for(PartnerFundClaim pfcToUpdate : pfcList){
            pfcToUpdate.Core_MDF_Bank_Doc_Hold_Ind__c = false;
            updateClaims.add(pfcToUpdate);
        }
        Database.update(updateClaims);
        return null;
    }
    
}