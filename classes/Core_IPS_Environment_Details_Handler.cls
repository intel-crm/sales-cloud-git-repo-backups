public without sharing class Core_IPS_Environment_Details_Handler{
    public static void updateEnvironmentDetailsOnCase(List<Core_IPS_Environment_Details__c> newList){
        Core_IPS_Environment_Details__c envDetail = newList[0];
        Case cs;
        List<Case> caseList = new List<Case>();
        //FLS check added-Venugopal
        if(Case.SObjectType.getDescribe().isAccessible()){
        cs = [select id,(select id,Core_Agent_Only__c,Core_Question__c,Core_Answer__c from Environments__r),Core_Environment_Details__c,Core_IPS_External_Environment_Details__c,Asset.Product2.name from case where id=:envDetail.Core_Case__c];
        }
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName(System.Label.Core_IPS_WriteFieldName); 
        gen.writeStartArray();
        /*US1021248 - 05/26/2021 - Vishal - FLS Check for security vulnerability --*/
      //  if (Schema.sObjectType.Case.fields.Core_Environment_Details__c.isUpdateable()) {
            cs.Core_Environment_Details__c = '<table border="1" width="100%" style="whiteSpace:pre-line;"><tr><th>Question</th><th>Response</th></tr>';
     //   }
      //  if (Schema.sObjectType.Case.fields.Core_IPS_External_Environment_Details__c.isUpdateable()) {
                cs.Core_IPS_External_Environment_Details__c= '<table border="1" width="100%" style="whiteSpace:pre-line;"><tr><th>Question</th><th>Response</th></tr>';
     //   }
        for(Core_IPS_Environment_Details__c env:cs.Environments__r){
            String envDetails = env.Core_Answer__c;
            if(envDetails!=null && envDetails.contains('\r\n')){ 
                envDetails=envDetails.replaceAll('\r\n','<br/>');
            }
            if(env.Core_Agent_Only__c){
                cs.Core_Environment_Details__c+= '<tr style="whiteSpace:pre-line;"><td width="30%"><b>'+env.Core_Question__c+'</b></td>';
                //cs.Core_IPS_External_Environment_Details__c+= '<tr style="whiteSpace:pre-line;"><td width="30%"><b>'+env.Core_Question__c+'</b></td>';
            }
            if(!env.core_agent_only__c){
                cs.Core_Environment_Details__c+= '<tr style="whiteSpace:pre-line;"><td width="30%"><b>'+env.Core_Question__c+'</b></td>';
                cs.Core_IPS_External_Environment_Details__c+= '<tr style="whiteSpace:pre-line;"><td width="30%"><b>'+env.Core_Question__c+'</b></td>';
            }
            if(env.Core_Agent_Only__c){
                if(envDetails!=null && envDetails!=''){
                    cs.Core_Environment_Details__c  += '<td width="50%" valign="middle" style="whiteSpace:pre-line;">'+envDetails+'</td>';
                }else{
                    /*TWC745-112 - 10/08/2021 - Vishal - FLS Check for security vulnerability --*/
               //     if (Schema.sObjectType.Case.fields.Core_Environment_Details__c.isUpdateable()) {
                        cs.Core_Environment_Details__c += '<td width="50%" valign="middle" style="whiteSpace:pre-line;"></td>';
                //    }
                }
                
            }
            if(!env.Core_Agent_Only__c){
                if(envDetails!=null && envDetails!=''){
                    /*TWC745-112 - 12/08/2021 - Vishal - FLS Check for security vulnerability --*/
                //    if (Schema.sObjectType.Case.fields.Core_Environment_Details__c.isUpdateable()) {
                         cs.Core_Environment_Details__c  += '<td width="50%" valign="middle" style="whiteSpace:pre-line;">'+envDetails+'</td>';
                //    }
                //    if (Schema.sObjectType.Case.fields.Core_IPS_External_Environment_Details__c.isUpdateable()) {
                         cs.Core_IPS_External_Environment_Details__c+= '<td width="50%" valign="middle" style="whiteSpace:pre-line;">'+envDetails+'</td>';
                //    }
                    
                }else{
                  //  if (Schema.sObjectType.Case.fields.Core_Environment_Details__c.isUpdateable()) {
                         cs.Core_Environment_Details__c += '<td width="50%" valign="middle" style="whiteSpace:pre-line;"></td>';
                  //  }
                  //  if (Schema.sObjectType.Case.fields.Core_IPS_External_Environment_Details__c.isUpdateable()) {
                         cs.Core_IPS_External_Environment_Details__c+= '<td width="50%" valign="middle" style="whiteSpace:pre-line;"></td>';
                  //  }
                    
                }
                
            }
            /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
         //   if (Schema.sObjectType.Case.fields.Core_Environment_Details__c.isUpdateable()) {
                cs.Core_Environment_Details__c+='</tr>';
          //  }
          //  if (Schema.sObjectType.Case.fields.Core_IPS_External_Environment_Details__c.isUpdateable()) {
                cs.Core_IPS_External_Environment_Details__c+='</tr>';  
         //   }
            gen.writeStartObject(); 
            if(env.Core_Question__c != null)    
            gen.writeStringField(System.Label.Core_IPS_WriteStringfield_Question, env.Core_Question__c);
            if(env.Core_Answer__c != null)
            gen.writeStringField(System.Label.Core_IPS_WriteStringfield_Response, env.Core_Answer__c);
            gen.writeEndObject();
       
        }
        gen.writeEndArray();
        //end of the parent JSON object
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        /*US1021248 - 05/26/2021 - Vishal - FLS Check for security vulnerability --*/
      //  if (Schema.sObjectType.Case.fields.Core_jsonfield__c.isUpdateable()) {
            cs.Core_jsonfield__c = jsonString;
       // }
      //  if (Schema.sObjectType.Case.fields.Core_Environment_Details__c.isUpdateable()) {
            cs.Core_Environment_Details__c += '</table>';
       // }
       // if (Schema.sObjectType.Case.fields.Core_IPS_External_Environment_Details__c.isUpdateable()) {
            cs.Core_IPS_External_Environment_Details__c+= '</table>';
       // }
        //cs.Product_name__c = cs.Asset.Product2.name;
        update cs;
        
    }
}