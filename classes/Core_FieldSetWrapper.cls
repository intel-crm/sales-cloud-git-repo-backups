/***********************************************************************************************************************************
Apex Class Name:  Core_GlobalOpportunitySearchController
Version     : 1.0 
Created Date: 10 OCT 2014
Function    : Apex Class (Wrapper class) for Core_GlobalOpportunitySearch Page to store field details from the feild set 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             10/10/2014              Original Version
* Kunal Mehta              10/10/2014              Original Version
************************************************************************************************************************************/
// 
   public class Core_FieldSetWrapper
   {
       // To store data type of field
       public string dataType { get; set; }
       
       // To store search value for text field
       public string textValue { get; set; }
      
       // To store API name of the field
       public string fieldName { get; set; }
       
       // To store label of the field
       public String fieldLabel { get; set; }
       
       // Flag to identify the picklist field
       public Boolean isPicklist { get; set; }
       
       // Flag to identify the multi-select picklist field
       public Boolean isMultiSelectPicklist { get; set; }
       
       // To store picklist values
       public List<SelectOption> picklistValues { get; set; }
       
       // To store selected picklist value
       public string selectedPicklistValue { get; set; }
       
       // To store picklist values for multiselect value
       public List<string> selectedMultipicklistValue { get; set; }
       
       // To store list of all the picklist values
       public List<SelectOption> allOptions;
    
        //property to back the available select list
        public List<String> available {get; set;}
        
        //property to back the chosen select list
        public List<String> chosen {get; set;}
        
        // To store the available options
        public List<SelectOption> availableItems {get; set;}
        
        // To store the chosen options
        public List<SelectOption> chosenItems {get; set;}
        
        // To store all the picklist values
        public Map<String,String> allOptionsMap { get; set; }
        
        // To store the currently request opportunity 
        public Opportunity opportunityInstance { get; set; }
        
        // To store the related object name
        public String relatedObject { get; set; }
        
        // To store the related field name
        public String relatedField { get; set; }
        
        
        // Constructor for fieldset wrapper
        public Core_fieldSetWrapper()
        {
           // Initializing values for all the variables
           textValue = '';
           isPicklist = false;
           isMultiSelectPicklist = false;
           selectedPicklistValue = '';
           available = new List<string>();
           chosen = new List<string>();
           availableItems = new List<SelectOption>();
           chosenItems = new List<SelectOption>();
           allOptions = new List<SelectOption>();
           allOptionsMap = new Map<String,String>();
        }
        
        /*
        * Method name  : add
        * Description  : Method to add chosen picklist values from available list to chosen list
        * Return Type  : None
        * Parameter    : PageReference
        */
        public PageReference add()
        {
            List<SelectOption> availableItemsList = availableItems.clone();
            Integer count = 0;
            
            // Iterating the list of selected values and adding it to chosen list
            for(string selected : available)
            {   
                string picklistValue = allOptionsMap.get(selected);
                chosenItems.add(new selectOption(selected,picklistValue));  
                
                Integer i = 0;
                for(SelectOption options : availableItems)
                {
                    // Removing the select one from available list
                    if(options.getValue().equalsIgnoreCase(selected))
                    {
                        if(count == 0)
                            availableItemsList.remove(i);
                        else
                            availableItemsList.remove(i-count);
                        count++;
                        break;
                    }
                    i++;
                }         
            }
            
            availableItems = availableItemsList;
            
            return null;
        }
        
        /*
        * Method name  : remove
        * Description  : Method to remove chosen picklist values from chosen list and add it to the avaialable list
        * Return Type  : None
        * Parameter    : PageReference
        */
        public PageReference remove()
        {
            List<SelectOption> chosenItemsList = chosenItems.clone();
            Integer count = 0;
            
            // Iterating the list of selected values from the chosen list and adding it to available list
            for(string selected : chosen)
            {
                string picklistValue = allOptionsMap.get(selected);
                availableItems.add(new selectOption(selected,picklistValue));  
                
                Integer i = 0;
                for(SelectOption options : chosenItems)
                {
                    // Removing the select one from chosen list
                    if(options.getValue().equalsIgnoreCase(selected))
                    {
                        if(count == 0)
                            chosenItemsList.remove(i);
                        else
                            chosenItemsList.remove(i-count);
                        count++;
                        break;
                    }
                    i++;
                }         
            }
            
            chosenItems = chosenItemsList;
            availableItems.sort();
            chosenItems .sort();
            return null;
        }
   }