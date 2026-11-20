/****************************************************************************************************************************************
Apex Class Name:  Core_OpportunityProductController
Version     : 1.0 
Created Date: 06 OCT 2014
Function    : Apex class for "Core_OpportunityProduct" Visualforce page to populate Group and Division details on Opportunity Product
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             06/10/2014              Original Version
******************************************************************************************************************************************/
public with sharing class Core_OpportunityProductController 
{
    // To store opportunity details related opportunity products
    public Opportunity selectedOpportunity { get; set; }
    
    // List of wrapper class to store opportunity products and product related details
    public List<opportunityProductWrapper> lstOpportunityProductsWrapper { get; set; }
    
    // Boolean flag to identify whether opportunity product records are present related to opportunity 
    public Boolean bNoRecords { get; set ;}
    
    public String opportunityURL { get; set; }

    public Core_OpportunityProductController(ApexPages.StandardController controller) 
    {
        opportunityURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        
        bNoRecords = false;
        
        if(!Test.isRunningTest())
            // Adding fields of Opportunity Product object to standard controller
            controller.addFields(new List<String>{'Core_Division_Code__c','Core_Group_Code__c'});
        
        // Fetching the opportunity id from the URL
        String opportunityId = ApexPages.CurrentPage().getParameters().get('oppId');
        
        // Validating the opportunity id
        if(opportunityId != NULL && opportunityId.length() >=15)
        {
            try
            {
                opportunityURL += opportunityId;
                lstOpportunityProductsWrapper = new List<opportunityProductWrapper>();
                List<OpportunityLineItem> lstLineItems = new List<OpportunityLineItem>();
                
                // Fetching the opportunity and related opportunity products
                selectedOpportunity = [SELECT Id,Name,(SELECT Name,Core_Division_Code__c,Core_Group_Code__c,Core_Advanced_Technology__c,Product2Id,Product2.Name,Product2.Core_Division_Code__c,
                                       Product2.Core_Group_Code__c,Product2.Core_Division_Code_Short_Name__c,Product2.Core_Group_Code_Short_Name__c  FROM OpportunityLineItems) 
                                       From Opportunity Where Id =:opportunityId LIMIT 1]; 
                lstLineItems = selectedOpportunity.OpportunityLineItems;
                
                // Checking whether opportunity records are present for opportunity 
                if(!lstLineItems.isEmpty())
                {
                    // Initializing the wrapper class instance to store opportunity product and related product details
                    for(OpportunityLineItem opportunityLineItemInstance : lstLineItems)
                    {
                        lstOpportunityProductsWrapper.add(new opportunityProductWrapper(opportunityLineItemInstance));
                    }
                }
                else
                {
                    bNoRecords = true;
                }
            }
            catch(Exception e)
            {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
            }
        }
        else
            bNoRecords = true;
        
    }
    
    // Wrapper class
    public class opportunityProductWrapper
    {
        // To store opportunity product details related to opportunity
        public OpportunityLineItem opportunityLineItemInstance { get; set; }
        
        // To store the list of division codes 
        public List<SelectOption> divisionCodes { get; set; }
        
        // To store the list of Group codes 
        public List<SelectOption> groupCodes { get; set; }
        
        // To store the list of Division Short Names
        public List<SelectOption> lstDivisionShortNames { get; set; }
        
        // To store the list of Group Short Names
        public List<SelectOption> lstGroupShortNames { get; set; }
        
        // To store the selected division
        public String sSelectedDivision { get; set; }
        
        // To store the selected Group
        public String sSelectedGroup { get; set; }
        
        // Flag to identify whether single division code is present
        public Boolean bIsSingleDivisionCode { get; set; }
        
        // Flag to identify whether single group code is present
        public Boolean bIsSingleGroupCode { get; set; }
        
        // Map to store the divsion code and divison short name
        Map<String,String> mapDivisioncodeDivisionShortName { get; set; }
        
        // Map to store the divsion short name and divison code
        Map<String,String> mapDivisionShortNameDivisioncode { get; set; }
        
        // Map to store the Group code and group short name
        Map<String,String> mapGroupCodeGroupShortName { get; set; }
        
        // Map to store the group short name and group code
        Map<String,String> mapGroupShortNameGroupcode { get; set; }
        
        
        public opportunityProductWrapper(OpportunityLineItem opportunityLineItemInstance)
        {
           
           bIsSingleDivisionCode = false;
           bIsSingleGroupCode = false;
           this.opportunityLineItemInstance = opportunityLineItemInstance;
           
           // To store the division codes from the related product
           divisionCodes = new List<SelectOption>();
           
           // To store the group codes from the related product
           groupCodes = new List<SelectOption>();
           
           // To store the division short names from the related product
           lstDivisionShortNames = new List<SelectOption>();
           
           // To store the group short names from the related product
           lstGroupShortNames = new List<SelectOption>();
           
           // Map to store the division code and division short name
           mapDivisioncodeDivisionShortName = new Map<String,String>();
           
           // Map to store the division short name and division code
           mapDivisionShortNameDivisioncode = new Map<String,String>();
           
           // Map to store the group code and group short name
           mapGroupCodeGroupShortName = new Map<String,String>();
           
           // Map to store the group short name and group code
           mapGroupShortNameGroupcode = new Map<String,String>();
           
           // Storing the previously selected Divsion code on Opportunity product
           sSelectedDivision = opportunityLineItemInstance.Core_Division_Code__c;
           
           // Storing the previously selected Group code on Opportunity product
           sSelectedGroup = opportunityLineItemInstance.Core_Group_Code__c;
           
           // Fetching all the division codes from the product related to opportunity product 
           String sProductDivisions = opportunityLineItemInstance.Product2.Core_Division_Code__c;
           
           // Fetching all the group codes from the product related to opportunity product
           String sProductGroups = opportunityLineItemInstance.Product2.Core_Group_Code__c;
           
           // Fetching all the division short names from the product related to opportunity product
           String sProductDivisionShortNames = opportunityLineItemInstance.Product2.Core_Division_Code_Short_Name__c;
           
           // Fetching all the group short names from the product related to opportunity product
           String sProductGroupShortNames = opportunityLineItemInstance.Product2.Core_Group_Code_Short_Name__c;
           
           // Validating the divsion code and divison short name of the product related to opportunity product
           if(sProductDivisions!= NULL && sProductDivisions != '' && sProductDivisions.IndexOf(';') > 0 && sProductDivisionShortNames!= NULL && 
               sProductDivisionShortNames!= '' && sProductDivisionShortNames.IndexOf(';') > 0)
           {
               // To store the list of Division Codes
               List<String> lstDivisionCodes = new List<String>();
               
               // Splitting the divisions codes present in Product 
               lstDivisionCodes = sProductDivisions.split(';');
               
               // To store the list of Division short names
               List<String> lstDivisionShortName = new List<String>();
               
               // Splitting the divisions short names corresponding to divsion code present in Product 
               lstDivisionShortName = sProductDivisionShortNames.split(';');
               
               // Validating whether for each division code there is corresponding division short name
               if(lstDivisionCodes.size() == lstDivisionShortName.size())
               {
                   for(Integer iDivisionIndex = 0; iDivisionIndex < lstDivisionCodes.size(); iDivisionIndex++ )
                   {
                       mapDivisioncodeDivisionShortName.put(lstDivisionCodes.get(iDivisionIndex),lstDivisionShortName.get(iDivisionIndex));
                       mapDivisionShortNameDivisioncode.put(lstDivisionShortName.get(iDivisionIndex),lstDivisionCodes.get(iDivisionIndex));
                   }
                   
                   // Checking whether division code is already present on Opportunity product record
                   if(sSelectedDivision != NULL && sSelectedDivision != '')
                   {
                       // If divsion short name is alredy present in Opportunity Product then add it the picklist to show the selected as first
                       if(mapDivisioncodeDivisionShortName.containsKey(sSelectedDivision))
                           lstDivisionShortNames.add(new SelectOption(mapDivisioncodeDivisionShortName.get(sSelectedDivision),mapDivisioncodeDivisionShortName.get(sSelectedDivision)));
                   }

                   // Adding None value to dision short name select option
                   lstDivisionShortNames.add(new SelectOption(System.Label.Core_None_Value,System.Label.Core_None_Value));
                   
                   // Sorting the division short name picklist alphabetically
                   lstDivisionShortName.sort();
                   
                   // Populating other picklist valies for divsion short names
                   for(String divisionShortName : lstDivisionShortName)
                   {
                       if(!divisionShortName.equalsIgnoreCase(mapDivisioncodeDivisionShortName.get(sSelectedDivision)))
                           lstDivisionShortNames.add(new SelectOption(divisionShortName,divisionShortName));
                   }
               }   
           }
           // If there is only one division short name then populate that value and also set the flag
           else if(sProductDivisions!= NULL && sProductDivisions!= '')
           {
               
               mapDivisioncodeDivisionShortName.put(sProductDivisions,sProductDivisionShortNames);
               mapDivisionShortNameDivisioncode.put(sProductDivisionShortNames,sProductDivisions);
               
               if(sSelectedDivision != NULL)
               {
               
                   if(mapDivisioncodeDivisionShortName.containsKey(sSelectedDivision))
                   {
                       lstDivisionShortNames.add(new SelectOption(mapDivisioncodeDivisionShortName.get(sSelectedDivision),mapDivisioncodeDivisionShortName.get(sSelectedDivision)));
                       bIsSingleDivisionCode = true;
                   }
                   
               }
               else
               {
                   sSelectedDivision = sProductDivisionShortNames;
                   lstDivisionShortNames.add(new SelectOption(sProductDivisionShortNames,sProductDivisionShortNames));
                   bIsSingleDivisionCode = true;
               }
            }
            else
            {
                   bIsSingleDivisionCode = true;
                   lstDivisionShortNames.add(new SelectOption(System.Label.Core_None_Value,System.Label.Core_None_Value));
            }
           
          
           
           // Validating the group code and group short name of the product related to opportunity product
           if(sProductGroups!= NULL && sProductGroups != '' && sProductGroups.IndexOf(';') > 0 && sProductGroupShortNames != NULL && 
               sProductGroupShortNames != '' && sProductGroupShortNames.IndexOf(';') > 0)
           {
               // To store the list of Group Codes
               List<String> lstGroupCodes = new List<String>();
               
               // Splitting the group codes present in Product 
               lstGroupCodes = sProductGroups.split(';');
               
               // To store the list of Group Short names
               List<String> lstGroupShortName = new List<String>();
               
               // Splitting the group short names present in Product 
               lstGroupShortName = sProductGroupShortNames.split(';');
               
               // Validating whether for each group code there is a corresponding group short name
               if(lstGroupCodes.size() == lstGroupShortName.size())
               {
                   
                   for(Integer iGroupIndex = 0; iGroupIndex < lstGroupCodes.size(); iGroupIndex++ )
                   {
                       mapGroupCodeGroupShortName.put(lstGroupCodes.get(iGroupIndex),lstGroupShortName.get(iGroupIndex));
                       mapGroupShortNameGroupCode.put(lstGroupShortName.get(iGroupIndex),lstGroupCodes.get(iGroupIndex));
                   }
                   
                   // Checking whether group code is already present on Opportunity product record
                   if(sSelectedGroup != NULL && sSelectedGroup != '')
                   {
                       if(mapGroupCodeGroupShortName.containsKey(sSelectedGroup))    
                           lstGroupShortNames.add(new SelectOption(mapGroupCodeGroupShortName.get(sSelectedGroup),mapGroupCodeGroupShortName.get(sSelectedGroup)));
                   }
                   
                   // Adding "--None--" picklist value to group short name picklist
                   lstGroupShortNames.add(new SelectOption(System.Label.Core_None_Value,System.Label.Core_None_Value));
                   
                   // Sorting the group short name
                   lstGroupShortName.sort();
                   
                   
                   for(String groupShortName : lstGroupShortName)
                   {
                       // Adding all the group short names from the related product record
                       if(!groupShortName.equalsIgnoreCase(mapGroupCodeGroupShortName.get(sSelectedGroup)))
                           lstGroupShortNames.add(new SelectOption(groupShortName,groupShortName));
                   }
               }
               
               
           }
           else if(sProductGroups != NULL )
           {
               
               mapGroupCodeGroupShortName.put(sProductGroups,sProductGroupShortNames);
               mapGroupShortNameGroupCode.put(sProductGroupShortNames,sProductGroups);
               
               
               
               if(sSelectedGroup != NULL)
               {
               
                   /* If there is only one Group code and group short name addding it to the picklist and setting 
                      the flag to identify only one group short name is present */
                  if(mapGroupcodeGroupShortName.containsKey(sSelectedGroup))
                  {
                      lstGroupShortNames.add(new SelectOption(mapGroupcodeGroupShortName.get(sSelectedGroup),mapGroupcodeGroupShortName.get(sSelectedGroup)));
                      bIsSingleGroupCode = true;
                  }
                  
              }
              else
              {
                  sSelectedGroup = sProductGroupShortNames;
                  lstGroupShortNames.add(new SelectOption(sProductGroupShortNames,sProductGroupShortNames));
                  bIsSingleGroupCode = true;
              }
              
           }
           else
           {
               bIsSingleGroupCode = true;
               lstGroupShortNames.add(new SelectOption(System.Label.Core_None_Value,System.Label.Core_None_Value));
           }
               
       }
    }
    
     /*
    * Method name  : saveDetails
    * Description  : Method to update the Division code and Group Code on Opportunity Product record
    * Return Type  : VOID
    * Parameter    : PageReference
    */
    public PageReference saveDetails()
    {
        List<OpportunityLineItem> lstOpportunityLineItemUpdate = new List<OpportunityLineItem>();
        
        // Iterating over the list of Opportunity Product records and updating the divsion and group codes
        for(opportunityProductWrapper opportunityProductInstance : lstOpportunityProductsWrapper)
        {
            String sDivisionCode = (opportunityProductInstance.mapDivisionShortNameDivisioncode.containsKey(opportunityProductInstance.sSelectedDivision)?
                                    opportunityProductInstance.mapDivisionShortNameDivisioncode.get(opportunityProductInstance.sSelectedDivision):'');
                                    
            String sGroupCode = (opportunityProductInstance.mapGroupShortNameGroupcode.containsKey(opportunityProductInstance.sSelectedGroup)?
                                 opportunityProductInstance.mapGroupShortNameGroupcode.get(opportunityProductInstance.sSelectedGroup):'');
                                 
            opportunityProductInstance.opportunityLineItemInstance.Core_Division_Code__c = (opportunityProductInstance.sSelectedDivision != System.Label.Core_None_Value?
                                                                                            sDivisionCode:'');
            opportunityProductInstance.opportunityLineItemInstance.Core_Group_Code__c = (opportunityProductInstance.sSelectedGroup != System.Label.Core_None_Value?
                                                                                         sGroupCode:'');
            opportunityProductInstance.opportunityLineItemInstance.Core_Division__c = (opportunityProductInstance.sSelectedDivision != System.Label.Core_None_Value?
                                                                                        opportunityProductInstance.sSelectedDivision:'');
            opportunityProductInstance.opportunityLineItemInstance.Core_Group__c = (opportunityProductInstance.sSelectedDivision != System.Label.Core_None_Value?
                                                                                    opportunityProductInstance.sSelectedGroup:'');
                                                                                    
            lstOpportunityLineItemUpdate.add(opportunityProductInstance.opportunityLineItemInstance);
        }
       
       // Updating the list of Opportunity Product records
       Database.SaveResult[] srList = Database.update(lstOpportunityLineItemUpdate, false);      
       Integer iDatabaseUpdateIndex = 0; 
         
       // Capturing the logs for error records
       for (Database.SaveResult sr : srList) 
       {
            if (!sr.isSuccess()) 
            {
                for(Database.Error err : sr.getErrors()) 
                {                
                    lstOpportunityLineItemUpdate.get(iDatabaseUpdateIndex).addError(err.getMessage());
                    
                    
                }
            }
            iDatabaseUpdateIndex++;
         }
         
         
         // Setting the pagereference for the Save method
         
         PageReference pageRef = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + selectedOpportunity.Id);
         pageRef.setRedirect(true);
         return pageRef;
    }
}