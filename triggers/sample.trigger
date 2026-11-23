trigger sample on Contact (before insert) {
    for(Contact con :Trigger.new){
        con.Description = 'contact record created succesfully with Trigger';
    }

}