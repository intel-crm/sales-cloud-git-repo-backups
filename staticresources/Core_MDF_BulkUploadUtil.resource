window._campaignValidations = (function() {
    return {
        campaignValidations : function(dataToBeChecked,methodName){
            var Handler={};
            
            Handler.IPAAccountRestriction = function(){
                console.log('IPAAccountRestriction method called...');
                console.log('dataToBeChecked...'+dataToBeChecked);
                var countries = dataToBeChecked.split(";");
                var USSelected = false;
                var error;
                for(var k=0;k<countries.length;k++){
    
                    if(countries[k] == 'UNITED STATES'){
                        USSelected = true;
    
                    }
                    if(USSelected == true && countries[k] != 'UNITED STATES'){
                        error = 'No other country can be selected if US is selected.';
    
                    }
    
                }
                return error;
            }
        
            Handler.IPAEndDateRestriction = function(){
                console.log('IPAEndDateRestriction method called...');
                console.log('dataToBeChecked...'+dataToBeChecked);
            }
        
           var camperror = Handler[methodName]();
           console.log('camperror from util:'+camperror);
           return camperror;
        }

    };
}());
