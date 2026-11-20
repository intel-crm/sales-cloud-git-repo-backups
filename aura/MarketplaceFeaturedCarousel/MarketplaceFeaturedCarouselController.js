/* Fuctionality updated by Nikhil on 30-Sep-2019. please merge carefully as this component behaviour is not same as ISG component*/
({
    doInit : function(component, event, helper) {
        
        
        
        var firstLoadLimit = component.get('v.firstLoadLimit');
        
        var secondLoadLimit = parseInt($A.get('$Label.c.PMP_Featured_Offering_Limit'));
         
        if(secondLoadLimit >= firstLoadLimit){
            secondLoadLimit = secondLoadLimit - firstLoadLimit; //we have to exclude first loaded offerings
            
        }else{
            firstLoadLimit = secondLoadLimit;
            secondLoadLimit = 0;
            
        }
        helper.getFeaturedTabs(component).then($A.getCallback(function(){
            
            //onActive function will be called from MarketplaceTabSet component on click of each Tab on the page
            component.set('v.onActive',function(component,index){
                
                
                var currentTab = component.get('v.currentTab'); //MarketplaceTab
                var carousel = currentTab.get('v.body')[0]; //MarketplaceCardCarousel
                
                
                var products = carousel.get('v.featuredProducts');
                if(!products.length){
                    var userLangCode = $A.get("$Locale.langLocale");
                    var action = component.get("c.getFeaturedOfferings");
                    //var action1=component.get("c.getEventOfferings");
                    action.setParams({
                        catId : carousel.get('v.categoryId'),
                        prevLmt : null,
                        currentLmt : firstLoadLimit,  //4
                        langCode: userLangCode
                    });
                    /* action1.setParams({
                        catId : carousel.get('v.categoryId'),
                        prevLmt : null,
                        currentLmt : firstLoadLimit,  //4
                        langCode: userLangCode
                    });*/
                    /* action1.setCallback(this, function(response) {
                           var status = response.getState();
                        if (status === "SUCCESS") {
                            var returnValue = response.getReturnValue();
                        }
                        console.log('first server call ',returnValue)
                            
                            var products = carousel.get('v.featuredProducts');
                            returnValue.forEach(function(prod){
                                products.push(prod);
                     });*/
                    //action.setBackground();
                    action.setCallback(this, function(response) {
                        var status = response.getState();
                        if (status === "SUCCESS") { //first time offerings loaded (4)
                            var returnValue = response.getReturnValue();
                            
                            
                            var products = carousel.get('v.featuredProducts');
                            returnValue.forEach(function(prod){
                                products.push(prod);
                                
                            })
                            carousel.set('v.featuredProducts',products);
                            
                            if(products.length ==firstLoadLimit){
                                setTimeout($A.getCallback(function(){
                                    var nextAction = component.get("c.getFeaturedOfferings");
                                    nextAction.setParams({
                                        catId : carousel.get('v.categoryId'),
                                        prevLmt : firstLoadLimit, //4
                                        currentLmt : secondLoadLimit, 
                                        langCode: userLangCode
                                    });
                                    nextAction.setBackground();
                                    nextAction.setCallback(this,function(response){
                                        var status = response.getState();
                                        if(status =="SUCCESS"){
                                            returnValue = response.getReturnValue();
                                            
                                            
                                            var products = carousel.get('v.featuredProducts');
                                            
                                            returnValue.forEach(function(prod){
                                                products.push(prod);
                                            })
                                            carousel.set('v.featuredProducts',products);
                                            
                                        }else if (status === "INCOMPLETE") {
                                            // do something?
                                        } else if (status === "ERROR") {
                                            var errors = response.getError();
                                            if (errors) {
                                                if (errors[0] && errors[0].message) {
                                                    console.error(errors[0].message);
                                                };
                                            }
                                        } else {
                                            console.log('Unknown error.');
                                        }
                                    })
                                    $A.enqueueAction(nextAction);
                                }))
                                
                            }
                        } else if (status === "INCOMPLETE") {
                            // do something?
                        } else if (status === "ERROR") {
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    console.error(errors[0].message);
                                };
                            }
                        } else {
                            this.reject('Unknown error.');
                        }
                    });
                    $A.enqueueAction(action);
                          //$A.enqueueAction(action1);

                }
                
            })
            //Change End
        }));
        
    },
    
})