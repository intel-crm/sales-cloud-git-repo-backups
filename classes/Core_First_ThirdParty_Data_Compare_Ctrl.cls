/**************************************************************************************
Apex Class Name:  Core_First_ThirdParty_Data_Compare_Ctrl
Version     : 1.0 
Created Date: 10 June 2020
Function    : Controller class for the Core_First_ThirdParty_Data_Compare  VF Page
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh             06/10/2020              Original Version
*************************************************************************************/

public class Core_First_ThirdParty_Data_Compare_Ctrl {
  
    public Account Acct {get;set;}
    Public Boolean RoleIndicator{get;set;}
    
    Public Boolean PartnerSegmentIndicator{get;set;}
    Public Boolean IndustryIndicator{get;set;}
    Public Boolean AddressIndicator{get;set;}
    Public Boolean TelPhoneIndicator{get;set;}
    Public Boolean WebsiteIndicator{get;set;}
    public string matchedvalues{get;set;}
	public string  BillingCountryName{get;set;}
	public string  BillingStateName{get;set;}
    public string unmatchedvalues{get;set;}
    public string matchedSegmentvalues{get;set;}
    public string unmatchedSegmentvalues{get;set;}
    public List<PartnerRoleColorWrapper> firstPartyList{get;set;}
    public List<PartnerRoleColorWrapper> thirdPartyList{get;set;}
    public List<PartnerRoleColorWrapper> firstPartyListSegment{get;set;}
    public List<PartnerRoleColorWrapper> thirdPartyListSegment{get;set;}
    public string firstPartyLastvalue{get;set;}
    public string thirdPartyLastValue{get;set;}
    public string firstPartyLastvalueSegment{get;set;}
    public string thirdPartyLastValueSegment{get;set;}
    
    Public String AccountId;
    
    public Core_First_ThirdParty_Data_Compare_Ctrl(ApexPages.StandardController stdController){
        
        Acct= (Account)stdController.getRecord();
        AccountId=ApexPages.currentPage().getParameters().get('id');
        System.debug('######AcctId'+AccountId);
        if(String.isNotBlank(Acct.Id)){
            List<Account> Acclist =[Select id,toLabel(Core_IPA_Partner_Role__c),toLabel(Core_bC_Role__c),Industry,Core_bC_Industry__c,Core_IPA_Partner_Segment__c,Core_bC_Partner_Segment__c,Core_User_Defined_Phone_Number__c,Core_bC_Telephone_number__c,Core_User_Defined_Website__c,Core_bC_Website_URL__c,BillingAddress,Core_bC_Address__c,billingstreet,billingcity,billingstate,billingPostalCode,billingCountry,toLabel(BillingCountryCode),toLabel(BillingStateCode) from Account Where id =: Acct.Id ];
            
            String Rolelist=Acclist[0].Core_IPA_Partner_Role__c;
            String BcRolelist=Acclist[0].Core_bC_Role__c;
            
            if( Rolelist !=null && BcRolelist !=null){
                
                Set<String> picklistValuesA = new Set<String>( Rolelist.split(';') );
                Set<String> picklistValuesB = new Set<String>( BcRolelist.split(';') );
                
                Set<String> PicklistAB= new set<string>();
                PicklistAB.addAll(picklistValuesA);
                PicklistAB.addAll(picklistValuesB);
                system.debug('#####Whole Picklist'+PicklistAB);
                 system.debug('#####Whole picklistValuesA'+picklistValuesA);
                system.debug('#####Whole picklistValuesB'+picklistValuesB);
                
                Set<String> commonValues = new Set<String>( picklistValuesA );
                // commonValues.retainAll( picklistValuesB );
                commonValues.retainAll( picklistValuesB );
                System.debug( 'picklists have these common values: ' + commonValues );
                Set<String> uncommonValues = new Set<String>();
                for(string s :PicklistAB){
                    if(!commonValues.contains(s)){
                        uncommonValues.add(s);
                    }
                    
                }
                
                matchedvalues = String.join(new List<String>(commonValues), ',');
                unmatchedvalues = String.join(new List<String>(uncommonValues), ',');
                If(String.isNotBlank(unmatchedvalues)){
                    RoleIndicator=false;
                }else{
                    RoleIndicator=true;
                }
                if(!RoleIndicator){
                    firstPartyList = new List<PartnerRoleColorWrapper>();
                    thirdPartyList = new List<PartnerRoleColorWrapper>();
                    PartnerRoleColorWrapper temp;
                    List<String> tempList = new List<String>();
                    tempList.addAll(picklistValuesA);
                    tempList.sort();
                    for(String st : tempList){
                        temp = new PartnerRoleColorWrapper();
                        temp.picklistValue = st;
                        if(commonValues.contains(st)){
                            temp.colorValue = 'Green';
                        }else{
                            temp.colorValue = 'Red';
                        }
                        firstPartyList.add(temp);
                       
                    }
                    system.debug('firstPartyList'+firstPartyList);
                    firstPartyLastvalue = firstPartyList[firstPartyList.size()-1].picklistValue;
                    
                    tempList.clear();
                    tempList.addAll(picklistValuesB);
                    tempList.sort();
                    for(String st : picklistValuesB){
                        temp = new PartnerRoleColorWrapper();
                        temp.picklistValue = st;
                        if(commonValues.contains(st)){
                            temp.colorValue = 'Green';
                        }else{
                            temp.colorValue = 'Red';
                        }
                        thirdPartyList.add(temp);
                    }
                    thirdPartyLastValue = thirdPartyList[thirdPartyList.size()-1].picklistValue;
                }
                system.debug('###RoleList'+Rolelist);
                system.debug('###matchedvalues'+matchedvalues);
                system.debug('###Unmatchedvalues'+Unmatchedvalues);
                System.debug( 'picklists have these uncommon values: ' + uncommonValues );
                
            }
            
            if( (Rolelist ==null && BcRolelist !=null) || (Rolelist !=null && BcRolelist ==null)){
                
                if( Rolelist !=null){
                    Unmatchedvalues=Rolelist;
                }
                if( BcRolelist !=null){
                    Unmatchedvalues=BcRolelist;
                }
                
                
            }
            
            
            //Partner Segment
            String PartnerSegment = Acclist[0].Core_IPA_Partner_Segment__c;
            String bcPartnerSegment = Acclist[0].Core_bC_Partner_Segment__c;
            system.debug('###partnerSegment'+PartnerSegment);
             system.debug('###bcPartnerSegment'+bcPartnerSegment);
            
            if( PartnerSegment !=null && bcPartnerSegment !=null){
                
                Set<String> PartnerSegmentValues = new Set<String>( PartnerSegment.split(';') );
                Set<String> bcPartnerSegmentValues = new Set<String>( bcPartnerSegment.split(';') );
                
                Set<String>  CombinedValues= new set<string>();
                CombinedValues.addAll(PartnerSegmentValues);
                CombinedValues.addAll(bcPartnerSegmentValues);
                //system.debug('#####Whole Picklist'+CombinedValues);
                
                Set<String> commonSegmentValues = new Set<String>( PartnerSegmentValues );
                // commonValues.retainAll( picklistValuesB );
                commonSegmentValues.retainAll( bcPartnerSegmentValues );
                System.debug( 'picklists have these common values: ' + commonSegmentValues );
                Set<String> uncommonSegmentValues = new Set<String>();
                for(string s :CombinedValues){
                    if(!commonSegmentValues.contains(s)){
                        uncommonSegmentValues.add(s);
                    }
                    
                }
                matchedSegmentvalues = String.join(new List<String>(commonSegmentValues), ',');
                unmatchedSegmentvalues = String.join(new List<String>(uncommonSegmentValues), ',');
                If(String.isNotBlank(unmatchedSegmentvalues)){
                    PartnerSegmentIndicator=false;
                }else{
                    PartnerSegmentIndicator=true;
                }
                    if(!PartnerSegmentIndicator){
                    firstPartyListSegment = new List<PartnerRoleColorWrapper>();
                    thirdPartyListSegment = new List<PartnerRoleColorWrapper>();
                    PartnerRoleColorWrapper tempSegment;
                    List<String> tempListSegment = new List<String>();
                    tempListSegment.addAll(PartnerSegmentValues);
                    tempListSegment.sort();
                    for(String st : tempListSegment){
                        tempSegment = new PartnerRoleColorWrapper();
                        tempSegment.picklistValue = st;
                        if(commonSegmentValues.contains(st)){
                            tempSegment.colorValue = 'Green';
                        }else{
                            tempSegment.colorValue = 'Red';
                        }
                        firstPartyListSegment.add(tempSegment);
                       
                    }
                    system.debug('firstPartyListSegment'+firstPartyListSegment);
                    firstPartyLastvalueSegment = firstPartyListSegment[firstPartyListSegment.size()-1].picklistValue;
                    
                    tempListSegment.clear();
                    tempListSegment.addAll(bcPartnerSegmentValues);
                    tempListSegment.sort();
                    for(String st : bcPartnerSegmentValues){
                        tempSegment = new PartnerRoleColorWrapper();
                        tempSegment.picklistValue = st;
                        if(commonSegmentValues.contains(st)){
                            tempSegment.colorValue = 'Green';
                        }else{
                            tempSegment.colorValue = 'Red';
                        }
                        thirdPartyListSegment.add(tempSegment);
                    }
                    thirdPartyLastValueSegment = thirdPartyListSegment[thirdPartyListSegment.size()-1].picklistValue;
                }
                
                system.debug('Segmentvalues1st'+firstPartyListSegment);
                 system.debug('Segmentvalues3st'+thirdPartyListSegment);
            }
            
            
            if( (PartnerSegment ==null && bcPartnerSegment !=null) || (PartnerSegment !=null && bcPartnerSegment ==null)){
                
                if( PartnerSegment !=null){
                    unmatchedSegmentvalues=PartnerSegment;
                }
                if( bcPartnerSegment !=null){
                    unmatchedSegmentvalues=bcPartnerSegment;
                }
                
                
            }
            
            
            
            if(Acclist !=null && Acclist.size()>0 && (Acclist[0].Core_IPA_Partner_Role__c == Acclist[0].Core_bC_Role__c) ){
                // RoleIndicator =true;
            }else{
                //  RoleIndicator =false;
            }
            
            if(Acclist !=null && Acclist.size()>0 && (Acclist[0].Core_IPA_Partner_Segment__c == Acclist[0].Core_bC_Partner_Segment__c) ){
                //PartnerSegmentIndicator =true;
            }else{
                //PartnerSegmentIndicator =false;
            }
            
            if(Acclist !=null && Acclist.size()>0 && (Acclist[0].Industry == Acclist[0].Core_bC_Industry__c) ){
                IndustryIndicator =true;
            }else{
                IndustryIndicator =false;
            }
            
            if(Acclist !=null && Acclist.size()>0 && (Acclist[0].Core_User_Defined_Phone_Number__c == Acclist[0].Core_bC_Telephone_number__c) ){
                TelPhoneIndicator =true;
            }else{
                TelPhoneIndicator =false;
            }
            
            if(Acclist !=null && Acclist.size()>0 && (Acclist[0].Core_User_Defined_Website__c == Acclist[0].Core_bC_Website_URL__c) ){
                WebsiteIndicator =true;
            }else{
                WebsiteIndicator =false;
            }
			
			
			BillingCountryName=Acclist[0].billingCountryCode;
			BillingStateName=Acclist[0].billingStateCode;
			
			
            string BillingAddressCombine = Acclist[0].billingstreet+ Acclist[0].billingcity + Acclist[0].billingstateCode + Acclist[0].billingPostalCode+ Acclist[0].billingCountryCode;
			String BillingAdress =BillingAddressCombine.remove(',');
           String bcAddresscombine,bcAdress;
            if(Acclist[0].Core_bC_Address__c !=null){
			 bcAddresscombine =Acclist[0].Core_bC_Address__c;
                bcAdress = bcAddresscombine.remove(',');
            }
			
			
			if(Acclist !=null && Acclist.size()>0 && (BillingAddressCombine == bcAdress) ){
                AddressIndicator =true;
            }else{
                AddressIndicator =false;
            }
            system.debug('AddressIndicator'+AddressIndicator);
            system.debug('AddressIndicator 1'+String.valueOf(Acclist[0].BillingAddress));
            system.debug('AddressIndicator 3rd'+String.valueOf(Acclist[0].Core_bC_Address__c));
        }
        
    }
    
    public class PartnerRoleColorWrapper{
        public String picklistValue{get;set;}
        public String colorValue{get;set;}
        
    }
    
}