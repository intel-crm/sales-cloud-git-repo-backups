trigger Core_SalesLead on Lead (before insert) {
    
    for(Lead slead: trigger.new){
       // slead.LeadSource ='Social Selling';
        //permission set: LinkedIn Sales Navigator Standard User
        //only sales lead
    }

}