/*********************************************************************************************************************
Class Name    : PSG_Chatbot_ControllerClass
Version       : 1.0
Created Date  : 6 September 2022

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Ranjit Kumar   	6-9-2022                  Used to Perform specific operation related to Psg chatbot
* *********************************************************************************************************************/



Global class PSG_Chatbot_ControllerClass 
{
     Global class Chatbotinput 
    {
         @InvocableVariable
        Public string Input;
         @InvocableVariable
        Public string Operation;
        @InvocableVariable
        public String sChatKey;
        
    } 
    
    Global class Chatbotouput
    {
         @InvocableVariable
        Public String DPA; 
         @InvocableVariable
        Public String ALN;
         @InvocableVariable
        Public String msg;
        @InvocableVariable
       public String OPNActive; 
         @InvocableVariable
        Public String Quotable;
        @InvocableVariable
        Public String Orderable;
        @InvocableVariable
        Public String ProductType;
         @InvocableVariable
        Public String Productorg;
        @InvocableVariable
        Public String Valid;
        @InvocableVariable
        public String QuoteIsvalid;
        @InvocableVariable
        public String DpaIsvalid;
        @InvocableVariable
        public String FirstName;
        @InvocableVariable
        public String GreetMessage;
        @InvocableVariable
        public String OPNNull;
        @InvocableVariable
        public String Userid;
        @InvocableVariable
        Public String Type;
        @InvocableVariable
        Public String ProductClass;	
        @InvocableVariable
        Public String OperationCode;
        

    }   

    
    
    
    @InvocableMethod(label='Get Chatbot Details')
    public static List<Chatbotouput> getDetails(List<Chatbotinput> Chatbotinput)
    {
        string input=Chatbotinput.get(0).Input;
        string operation=Chatbotinput.get(0).Operation;
        string sChatkey=Chatbotinput.get(0).sChatKey;
        List<Chatbotouput> Dpaalnoutput = new list<Chatbotouput>();
        Chatbotouput loutput = new Chatbotouput();
        If(operation=='Quote')
        {
            list<string> Quoteoutput=PSG_Chatbot_ControllerClass.getuserRegion(input,sChatkey);
            
            loutput.QuoteIsvalid = Quoteoutput[2];
            loutput.DpaIsvalid = Quoteoutput[3];
            
            Dpaalnoutput.add(loutput); 
        }
        else If(operation=='Prechat')
        {
            List<String> prechat=PSG_Chatbot_ControllerClass.getpsgPrechatData();
            list<string> firstname=PSG_Chatbot_ControllerClass.getuserRegion(input,sChatkey);
            loutput.FirstName = firstname[0];
            loutput.GreetMessage = prechat[1];
            loutput.userid=firstname[1];
            Dpaalnoutput.add(loutput); 
            
        }
        else If(operation=='DPA')
        {
            List<String> Dpaaln = PSG_Chatbot_ControllerClass.getdpaaln(input);
            loutput.msg=Dpaaln[0];
            loutput.DPA=Dpaaln[0];
            loutput.ALN=Dpaaln[1];
            Dpaalnoutput.add(loutput); 
            
        }
        else If(operation=='Product')
        {
            List<String> prod = PSG_Chatbot_ControllerClass.getProd(input);
            loutput.OPNNull=prod[0];
            loutput.ProductType=prod[0];
            loutput.OPNActive=prod[1];
            loutput.Orderable=prod[2];
            loutput.Quotable=prod[3];
            loutput.Productorg=prod[4];
            loutput.Valid=prod[5];
            loutput.Type=prod[6];
            loutput.ProductClass=prod[7];
            loutput.OperationCode=prod[8];
            Dpaalnoutput.add(loutput);
            
        }
        system.debug(Dpaalnoutput);
        return Dpaalnoutput;
        
    }
    public static List<string> getProd(string OPN)
    {
        
        List<string> Prodoutput = new list<string>();
             string ProductType;
             string OPNActive;
             string Orderable;
             string Quotable;
             string Productorg;
             string Valid;
             string Type;
             string ProductClass;
             string OperationCode;
        List<Product2> Prodlist=[select Core_Product_Type_Nm__c,IsActive,Core_Item_Orderable_Ind__c,Core_Item_Quotable_Ind__c,Core_Product_Org__c,Core_BU_Operation_Code__c,Core_Product_Type__c,Core_Item_Class_Nm__c from Product2 where (Core_OPN__c =: OPN or Name =:OPN) and IsActive=true and Core_Item_Orderable_Ind__c=true and Core_Item_Quotable_Ind__c=true and Core_Product_Org__c='Sales'];
        If(Prodlist.size()>0)
        {
            for(Product2 Pr :Prodlist)
        {
             ProductType=(Pr.Core_Product_Type_Nm__c==null)?'null':Pr.Core_Product_Type_Nm__c;
             OPNActive=(Pr.IsActive==true)?'Active':'Inactive';
             Orderable=(Pr.Core_Item_Orderable_Ind__c==true)?'Y':'N';
             Quotable=(Pr.Core_Item_Quotable_Ind__c==true)?'Y':'N';
             Productorg=(Pr.Core_Product_Org__c==null)?null:Pr.Core_Product_Org__c;
             Valid=(Pr.Core_Product_Type_Nm__c!=null && Pr.IsActive==true && Pr.Core_Item_Orderable_Ind__c==true && Pr.Core_Item_Quotable_Ind__c==true && (Pr.Core_Product_Org__c=='Sales'))?'Y':'N';
             Type=(Pr.Core_Product_Type__c==null)?'null':Pr.Core_Product_Type__c;
             ProductClass=(Pr.Core_Item_Class_Nm__c==null)?'null':Pr.Core_Item_Class_Nm__c;
             OperationCode=(Pr.Core_BU_Operation_Code__c==null)?'null':Pr.Core_BU_Operation_Code__c;
        }
        
                }
        else
        {
            string OPNNull='Invalid';
            Prodoutput.add(OPNNull); 
            
        }
        
        Prodoutput.add(ProductType);
        Prodoutput.add(OPNActive);
        Prodoutput.add(Orderable);
        Prodoutput.add(Quotable);
        Prodoutput.add(Productorg);
        Prodoutput.add(Valid);
        Prodoutput.add(Type);
        Prodoutput.add(ProductClass);
        Prodoutput.add(OperationCode);

        System.Debug(Prodoutput);
        return Prodoutput;
    }
    
    public static List<string> getdpaaln(string Quotename)
    {
        SBQQ__Quote__c QuoteDetails =[Select Id from SBQQ__Quote__c where Name =: Quotename limit 1];
        List<string> dlist = new list<string>();
        List<string> alist = new list<string>();
        List<string> Dpaalnoutput = new list<string>();
        List<core_cpq_dpa_aln__c> Dpaalndetails = [select id ,name,core_cpq_record_type_identifier__c from core_cpq_dpa_aln__c where core_cpq_active_quote__c =: QuoteDetails.id and core_cpq_ship_end_date_dt__c >= today ];
        
       If(Dpaalndetails.size()>0)
       {
           for(core_cpq_dpa_aln__c Dpa :Dpaalndetails)
        {
            
           If(Dpa.core_cpq_record_type_identifier__c == 'DPA')
            {
                
                dlist.add(Dpa.name);
                
            }
            else if(Dpa.core_cpq_record_type_identifier__c == 'ALN')
            {
               
                alist.add(Dpa.name);
            }
            
        }
           
       }
        else
        {
            string msg='0';
            Dpaalnoutput.add(msg);
            
        }
        
            
        
        string DPA=(dlist.isempty())?'null':String.join(dlist, ',');
        string ALN=(alist.isempty())?'null':String.join(alist, ',');
       // system.debug(DPA);
       // system.debug(ALN);
       
      Dpaalnoutput.add(DPA);
      Dpaalnoutput.add(ALN);
        system.debug(Dpaalnoutput[0]);
        system.debug(Dpaalnoutput[1]);
        system.debug(Dpaalnoutput);
        return Dpaalnoutput;


    }
    
    
    public static List<string> getpsgPrechatData(){
        List<User> UserDetails=[Select id,FirstName from User where Id =:UserInfo.getUserId() limit 1];
        List<string> outputParameters = new List<string>();
        string GreetMessage;
        string FirstName;
        datetime time_0000 = datetime.newInstance( System.Today().year(),System.Today().month(),System.Today().day(),0,0,0);
        datetime time_1159 = datetime.newInstance( System.Today().year(),System.Today().month(),System.Today().day(),11,59,59);
        datetime time_1200 = datetime.newInstance( System.Today().year(),System.Today().month(),System.Today().day(),12,0,0);
        datetime time_1559 = datetime.newInstance( System.Today().year(),System.Today().month(),System.Today().day(),15,59,59);
        datetime time_1600 = datetime.newInstance( System.Today().year(),System.Today().month(),System.Today().day(),16,0,0);
        datetime time_2359 = datetime.newInstance( System.Today().year(),System.Today().month(),System.Today().day(),23,59,59);
        datetime theTime = datetime.now();
        if(theTime>=time_0000 && theTime<=time_1159)
        {
            GreetMessage='Good Morning';
        }
        else if(theTime>=time_1200 && theTime<=time_1559)
        {
            GreetMessage='Good Afternoon';
            
        }
        else if(theTime>=time_1600 && theTime<=time_2359)
        {
          GreetMessage='Good Evening';
        }
        
        outputParameters.add(UserDetails[0].FirstName);
        outputParameters.add(GreetMessage);
        
        return outputParameters;
        
    }
    
    Public static List<string> getuserRegion(string Input,string sChatKey)
    {
        List<string> outputParameters = new List<string>();
        string QuoteIsValid;
        string DpaIsvalid;
        
        if (sChatKey != null && sChatKey != ''){
            System.debug('key>>'+sChatKey);
            List<LiveChatTranscript> transcripts = [SELECT Id, CaseId, ContactId, Username__c FROM LiveChatTranscript WHERE ChatKey = :sChatKey];
            
            if (transcripts.size()>0){
                System.debug('transcripts'+transcripts);
                System.debug('username'+transcripts[0].Username__c);
                list<Contact> con =[select FirstName,(select id,FirstName from users limit 1) from contact where id=:transcripts[0].ContactId];
                system.debug(con);
                system.debug(con[0].FirstName);
                //system.debug(con[0].users[0].id);
                outputParameters.add(con[0].FirstName);
                outputParameters.add(con[0].users[0].id);
                List<SBQQ__Quote__c> QuoteId =[Select Id from SBQQ__Quote__c where Name =: Input limit 1];
                List<core_cpq_dpa_aln__c> DpaId=[select id from core_cpq_dpa_aln__c where name =:Input limit 1];
                
                 for(SBQQ__Quote__c quote:QuoteId)
                 {
                     UserRecordAccess Quoteaccess =[Select HasReadAccess,RecordId  from UserRecordAccess where RecordId =:quote.id and UserId =: con[0].users[0].id  limit 1];
                     
                      if(Quoteaccess.HasReadAccess==true)
                     {
                       QuoteIsValid='True';
                     }
                     else
                    {
                      QuoteIsValid='False';
                    }
                
                     
                 }
                for(core_cpq_dpa_aln__c dpa:DpaId)
                {
                    UserRecordAccess Dpaaccess =[Select HasReadAccess,RecordId  from UserRecordAccess where RecordId =:dpa.id and UserId =: con[0].users[0].id  limit 1];
                    
                    if(Dpaaccess.HasReadAccess==true)
                    {
                      DpaIsvalid='True';
                    }
                    else
                    {
                       DpaIsvalid='False';
                    }
                    
                }
                                    
                outputParameters.add(QuoteIsValid);
                outputParameters.add(DpaIsvalid);
            }
          
        
    
}
        
        
         return outputParameters; 
    
}
    
}